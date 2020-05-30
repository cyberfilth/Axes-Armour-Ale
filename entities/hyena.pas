(* Weak enemy with simple AI, no pathfinding
    will attack and drain health *)

unit hyena;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, map;

(* Create a hyena *)
procedure createHyena(uniqueid, npcx, npcy: smallint);
(* check to see if entity can move to a square *)
function checkSpaceFree(x, y: smallint): boolean;
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Combat *)
procedure combat(idOwner, idTarget: smallint);

implementation

uses
  entities, globalutils, ui, los;

function checkSpaceFree(x, y: smallint): boolean;
begin
  (* Set boolean to false *)
  Result := False;
  (* Check that not blocked by map tiles *)
  if (map.canMove(x, y) = True) and
    (* Check not occupied by player *)
    (x <> entities.entityList[0].posX) and (y <> entities.entityList[0].posY) and
    (* Check that not occupied by another entity *)
    (map.isOccupied(x, y) = False) then
    Result := True;
end;

procedure takeTurn(id, spx, spy: smallint);
begin
  (* Can the NPC see the player *)
  if (los.inView(spx, spy, entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[id].visionRange) = True) then
  begin
    (* Reset move counter *)
    entities.entityList[id].moveCount := entities.entityList[id].trackingTurns;
    (* If NPC has low health... *)
    if (entities.entityList[id].currentHP < 2) then
    begin
      if (entities.entityList[id].abilityTriggered = False) and
        (isNextToPlayer(spx, spy) = True) then
      begin
        ui.bufferMessage('The hyena howls');
        entities.entityList[id].abilityTriggered := True;
        entities.entityList[id].attack := entities.entityList[id].attack + 2;
        entities.entityList[id].defense := entities.entityList[id].defense - 2;
      end
      else if (entities.entityList[id].abilityTriggered = True) and
        (isNextToPlayer(spx, spy) = True) then
      begin
        ui.bufferMessage('The hyena snarls');
        combat(id, 0);
      end
      else
        chasePlayer(id, spx, spy);
    end
    else
      chasePlayer(id, spx, spy);
  end
  (* Cannot see the player *)
  else if (entities.entityList[id].moveCount > 0) then
  begin    (* The NPC is still in pursuit *)
    Dec(entities.entityList[id].moveCount);
    chasePlayer(id, spx, spy);
  end
  else
    wander(id, spx, spy);
end;

procedure createHyena(uniqueid, npcx, npcy: smallint);
begin
  // Add a Hyena to the list of creatures
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'blood hyena';
    description := 'a drooling, blood hyena';
    glyph := 'h';
    maxHP := randomRange(3, 5);
    currentHP := maxHP;
    attack := randomRange(2, 3);
    defense := randomRange(3, 5);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 5;
    NPCsize := 2;
    trackingTurns := 3;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    abilityTriggered := False;
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    posX := npcx;
    posY := npcy;
  end;
   (* Occupy tile *)
  map.occupy(npcx, npcy);
end;

procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  attempts := 0;
  repeat
    // Reset values after each failed loop so they don't keep dec/incrementing
    testx := spx;
    testy := spy;
    direction := random(6);
    // limit the number of attempts to move so the game doesn't hang if NPC is stuck
    Inc(attempts);
    if attempts > 10 then
    begin
      entities.moveNPC(id, spx, spy);
      exit;
    end;
    case direction of
      0: Dec(testy);
      1: Inc(testy);
      2: Dec(testx);
      3: Inc(testx);
      4: testx := spx;
      5: testy := spy;
    end
  until (map.canMove(testx, testy) = True) and (map.isOccupied(testx, testy) = False);
  entities.moveNPC(id, testx, testy);
end;

procedure chasePlayer(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to chase the player *)
  if (spx > entities.entityList[0].posX) and (spy > entities.entityList[0].posY) then
  begin
    newX := spx - 1;
    newY := spy - 1;
  end
  else if (spx < entities.entityList[0].posX) and
    (spy < entities.entityList[0].posY) then
  begin
    newX := spx + 1;
    newY := spy + 1;
  end
  else if (spx < entities.entityList[0].posX) then
  begin
    newX := spx + 1;
    newY := spy;
  end
  else if (spx > entities.entityList[0].posX) then
  begin
    newX := spx - 1;
    newY := spy;
  end
  else if (spy < entities.entityList[0].posY) then
  begin
    newX := spx;
    newY := spy + 1;
  end
  else if (spy > entities.entityList[0].posY) then
  begin
    newX := spx;
    newY := spy - 1;
  end;
  (* New coordinates set. Check if they are walkable *)
  if (map.canMove(newX, newY) = True) then
  begin
    (* Do they contain the player *)
    if (map.hasPlayer(newX, newY) = True) then
    begin
      (* Remain on original tile and attack *)
      entities.moveNPC(id, spx, spy);
      combat(id, 0);
    end
    (* Else if tile does not contain player, check for another entity *)
    else if (map.isOccupied(newX, newY) = True) then
    begin
      if (entities.entityList[entities.getCreatureID(newX, newY)].NPCsize <
        entities.entityList[id].NPCsize) then
      begin
        combat(id, entities.getCreatureID(newX, newY));
        ui.bufferMessage('Hyena attacks ' + entities.getCreatureName(newX, newY));
      end
      else
        ui.bufferMessage('Hyena bumps into a ' + entities.getCreatureName(newX, newY));
      (* Remain on original tile *)
      entities.moveNPC(id, spx, spy);
    end
    (* if map is unoccupied, move to that tile *)
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  // wall hugging code
  else if (spx < entities.entityList[0].posX) and
    (checkSpaceFree(spx + 1, spy) = True) then
    entities.moveNPC(id, spx + 1, spy)
  else if (spx > entities.entityList[0].posX) and
    (checkSpaceFree(spx - 1, spy) = True) then
    entities.moveNPC(id, spx - 1, spy)
  else if (spy < entities.entityList[0].posY) and
    (checkSpaceFree(spx, spy + 1) = True) then
    entities.moveNPC(id, spx, spy + 1)
  else if (spy > entities.entityList[0].posY) and
    (checkSpaceFree(spx, spy - 1) = True) then
    entities.moveNPC(id, spx, spy - 1)
  else
    wander(id, spx, spy);
end;

function isNextToPlayer(spx, spy: smallint): boolean;
begin
  Result := False;
  if (map.hasPlayer(spx, spy - 1) = True) then // NORTH
    Result := True;
  if (map.hasPlayer(spx + 1, spy - 1) = True) then // NORTH EAST
    Result := True;
  if (map.hasPlayer(spx + 1, spy) = True) then // EAST
    Result := True;
  if (map.hasPlayer(spx + 1, spy + 1) = True) then // SOUTH EAST
    Result := True;
  if (map.hasPlayer(spx, spy + 1) = True) then // SOUTH
    Result := True;
  if (map.hasPlayer(spx - 1, spy + 1) = True) then // SOUTH WEST
    Result := True;
  if (map.hasPlayer(spx - 1, spy) = True) then // WEST
    Result := True;
  if (map.hasPlayer(spx - 1, spy - 1) = True) then // NORTH WEST
    Result := True;
end;

procedure combat(idOwner, idTarget: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[idOwner].attack) -
    entities.entityList[idTarget].defense;
  if (damageAmount > 0) then
  begin
    entities.entityList[idTarget].currentHP :=
      (entities.entityList[idTarget].currentHP - damageAmount);
    if (entities.entityList[idTarget].currentHP < 1) then
    begin
      if (idTarget = 0) then
      begin
        if (killer = 'empty') then
          killer := entityList[idOwner].race;
        exit;
      end
      else
      begin
        ui.displayMessage('The hyena kills the ' + entities.entityList[idTarget].race);
        entities.killEntity(idTarget);
        (* The Hyena levels up *)
        Inc(entities.entityList[idOwner].xpReward, 2);
        Inc(entities.entityList[idOwner].attack, 2);
        ui.bufferMessage('The hyena appears to grow stronger');
        exit;
      end;
    end
    else
    begin // if attack causes slight damage
      if (damageAmount = 1) then
      begin
        if (idTarget = 0) then // if target is the player
        begin
          ui.writeBufferedMessages;
          ui.displayMessage('The hyena slightly wounds you');
        end
        else
        begin
          ui.writeBufferedMessages;
          ui.displayMessage('The hyena slightly wounds the ' +
            entities.entityList[idTarget].race);
        end;
      end
      else  // if attack causes more damage
      begin
        if (idTarget = 0) then // if target is the player
        begin
          ui.bufferMessage('The hyena bites you, inflicting ' +
            IntToStr(damageAmount) + ' damage');
        end
        else
          ui.bufferMessage('The hyena bites the ' + entities.entityList[idTarget].race);
      end;
    end;
  end
  else
    ui.bufferMessage('The hyena attacks but misses');
end;

end.
