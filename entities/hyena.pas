(* Weak enemy with simple AI, no pathfinding
    will attack and drain health *)

unit hyena;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, map;

(* Create a hyena *)
procedure createHyena(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Combat *)
procedure combat(id: smallint);

implementation

uses
  entities, player, globalutils, ui, los;

procedure takeTurn(id, spx, spy: smallint);
begin
  (* Can the NPC see the player *)
  if (los.inView(spx, spy, ThePlayer.posX, ThePlayer.posY,
    entities.entityList[id].visionRange) = True) then
  begin
    (* If NPC has low health... *)
    if (entities.entityList[id].currentHP < 2) then
    begin
      if (entities.entityList[id].abilityTriggered = False) and (isNextToPlayer(spx, spy) = True) then
      begin
        ui.bufferMessage('The hyena howls');
        entities.entityList[id].abilityTriggered := True;
        entities.entityList[id].attack := entities.entityList[id].attack + 2;
        entities.entityList[id].defense := entities.entityList[id].defense - 2;
      end
      else if (entities.entityList[id].abilityTriggered = True) and (isNextToPlayer(spx, spy) = True) then
      begin
        ui.bufferMessage('The hyena snarls');
        combat(id);
      end
      else
        chasePlayer(id, spx, spy);
    end
    else
      chasePlayer(id, spx, spy);
  end
  (* Cannot see the player *)
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
    race := 'hyena';
    description := 'a hyena';
    glyph := 'h';
    maxHP := randomRange(3, 5);
    currentHP := maxHP;
    attack := randomRange(2, 3);
    defense := randomRange(2, 4);
    xpReward := maxHP;
    visionRange := 5;
    inView := False;
    discovered := False;
    isDead := False;
    abilityTriggered := False;
    posX := npcx;
    posY := npcy;
  end;
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
  until (map.canMove(testx, testy) = True) and (map.isOccupied(testx, testy) = False) and
    (testx <> ThePlayer.posX) and (testy <> ThePlayer.posY);
  entities.moveNPC(id, testx, testy);
end;

procedure chasePlayer(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to chase the player *)
  if (spx > player.ThePlayer.posX) and (spy > player.ThePlayer.posY) then
  begin
    newX := spx - 1;
    newY := spy - 1;
  end
  else if (spx < player.ThePlayer.posX) and (spy < player.ThePlayer.posY) then
  begin
    newX := spx + 1;
    newY := spy + 1;
  end
  else if (spx < player.ThePlayer.posX) then
  begin
    newX := spx + 1;
    newY := spy;
  end
  else if (spx > player.ThePlayer.posX) then
  begin
    newX := spx - 1;
    newY := spy;
  end
  else if (spy < player.ThePlayer.posY) then
  begin
    newX := spx;
    newY := spy + 1;
  end
  else if (spy > player.ThePlayer.posY) then
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
      combat(id);
    end
    (* Else if tile does not contain player, check for another entity *)
    else if (map.isOccupied(newX, newY) = True) then
    begin
      //ui.bufferMessage('cave rat bumps into Rat ' +
      //  IntToStr(entities.getCreatureID(newX, newY)));
      (* Remain on original tile *)
      entities.moveNPC(id, spx, spy);
    end
    (* if map is unoccupied, move to that tile *)
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
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

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) -
    player.ThePlayer.defense;
  if (damageAmount > 0) then
  begin
    player.ThePlayer.currentHP := (player.ThePlayer.currentHP - damageAmount);
    if (player.ThePlayer.currentHP < 1) then
    begin   { TODO : Create player.playerDeath function that handles this }
      ui.displayMessage('You are dead!');
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.bufferMessage('The hyena slightly wounds you')
      else
        ui.bufferMessage('The hyena bites you, inflicting ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
    ui.bufferMessage('The hyena attacks but misses');
end;

end.
