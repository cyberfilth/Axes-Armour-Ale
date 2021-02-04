(* Strong enemy that hunts by scent *)

unit cave_bear;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, map, smell;

(* Create a cave rat *)
procedure createCaveBear(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Use smell map to find the player *)
procedure sniffOutPlayer(id, spx, spy: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Combat *)
procedure combat(id: smallint);

implementation

uses
  entities, globalutils, ui, los;

procedure createCaveBear(uniqueid, npcx, npcy: smallint);
begin
  // Add a cave rat to the list of creatures
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'cave bear';
    description := 'a large bear';
    glyph := 'b';
    maxHP := randomRange(7, 10);
    currentHP := maxHP;
    attack := randomRange(4, 7);
    defense := randomRange(4, 6);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 4;
    NPCsize := 4;
    trackingTurns := 0;
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

procedure takeTurn(id, spx, spy: smallint);
begin
  (* Reset target coordinates if already at this location *)
  if (spx = entityList[id].targetX) and (spy = entityList[id].targetY) then
  begin
    entityList[id].targetX := 0;
    entityList[id].targetY := 0;
  end;
  (* Can the NPC see the player *)
  if (los.inView(spx, spy, entityList[0].posX, entityList[0].posY,
    entityList[id].visionRange) = True) then
  begin
    entityList[id].targetX := entityList[0].posX;
    entityList[id].targetY := entityList[0].posY;
    (* if they are next to player, they attack *)
    if (isNextToPlayer(spx, spy) = True) then
    begin
      ui.bufferMessage('The cave bear growls');
      combat(id);
    end
    else
      (* If too far away they chase the player *)
      chasePlayer(id, spx, spy);
  end
  else if (entityList[id].targetX <> 0) and (entityList[id].targetY <> 0) then
    (* If the player cannot be seen, sniff them out *)
    sniffOutPlayer(id, spx, spy)
  else
    wander(id, spx, spy);
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

procedure sniffOutPlayer(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  (* Get new coordinates to chase the player *)
  smell.sniff;
  newX := spx;
  newY := spy;
  (* Check N S E W smell map *)
  if (sniffNorth(entityList[id].posY, entityList[id].posX) = True) and
    (canMove(entityList[id].posX, entityList[id].posY - 1)) then
  begin
    newX := entityList[id].posX;
    newY := entityList[id].posY - 1;
  end
  else if (sniffSouth(entityList[id].posY, entityList[id].posX) = True) and
    (canMove(entityList[id].posX, entityList[id].posY + 1)) then
  begin
    newX := entityList[id].posX;
    newY := entityList[id].posY + 1;
  end
  else if (sniffEast(entityList[id].posY, entityList[id].posX) = True) and
    (canMove(entityList[id].posX + 1, entityList[id].posY)) then
  begin
    newX := entityList[id].posX + 1;
    newY := entityList[id].posY;
  end
  else if (sniffWest(entityList[id].posY, entityList[id].posX) = True) and
    (canMove(entityList[id].posX - 1, entityList[id].posY)) then
  begin
    newX := entityList[id].posX - 1;
    newY := entityList[id].posY;
  end;

  (* Check if the tile contains another entity *)
  if (map.isOccupied(newX, newY) = True) then
  begin
    if (map.canSee(newX, newY) = True) then
      ui.bufferMessage('The cave bear bumps into ' + getCreatureName(newX, newY));
    entities.moveNPC(id, spx, spy);
  end
  (* if map is unoccupied, move to that tile *)
  else if (map.isOccupied(newX, newY) = False) then
    entities.moveNPC(id, newX, newY)
  else
    wander(id, spx, spy);
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
      combat(id);
    end
    (* Else if tile does not contain player, check for another entity *)
    else if (map.isOccupied(newX, newY) = True) then
    begin
      ui.bufferMessage('The cave bear bumps into ' + getCreatureName(newX, newY));
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
var
  dx, dy: smallint;
  distance: double;
begin
  Result := False;
  dx := entityList[0].posX - spx;
  dy := entityList[0].posY - spy;
  distance := sqrt(dx ** 2 + dy ** 2);
  if (round(distance) = 0) then
    Result := True;
end;

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) -
    entities.entityList[0].defense;
  if (damageAmount > 0) then
  begin
    entities.entityList[0].currentHP :=
      (entities.entityList[0].currentHP - damageAmount);
    if (entities.entityList[0].currentHP < 1) then
    begin
      if (killer = 'empty') then
        killer := entityList[id].race;
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.bufferMessage('The cave bear slightly wounds you')
      else
        ui.bufferMessage('The cave bear mauls you, inflicting ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
    ui.bufferMessage('The cave bear attacks but misses');
end;

end.
