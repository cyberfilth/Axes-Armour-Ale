(* Simple enemy with no AI, moves in a pattern to act as a barrier
   It's called a 'small' hornet, but only in relation to Giant insects *)

unit small_hornet;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, combat_resolver;

(* Create a hornet *)
procedure createSmallHornet(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);
(* Creature death *)
procedure death;
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Player Combat *)
procedure combat(id: smallint);
(* NPC attacks another entity *)
procedure infighting(npcID, enemyID: smallint);

implementation

uses
  entities, globalutils, ui, map, player_stats;

procedure createSmallHornet(uniqueid, npcx, npcy: smallint);
begin
  (* Add a small hornet to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Hornet';
    intName := 'smallHornet';
    article := True;
    description := 'a buzzing hornet';
    glyph := chr(157);
    glyphColour := 'yellow';
    maxHP := randomRange(3, 5) + player_stats.playerLevel;
    currentHP := maxHP;
    attack := randomRange(7, 9);
    defence := randomRange(5, 7);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 4;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := animalFaction;
    state := stateHostile;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    stsDrunk := False;
    stsPoison := False;
    stsBewild := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    tmrBewild := 0;
    hasPath := False;
    destinationReached := False;
    entities.initPath(uniqueid);
    posX := npcx;
    posY := npcy;
  end;
  (* Occupy tile *)
  map.occupy(npcx, npcy);
end;

procedure takeTurn(id: smallint);
begin
    (* Check for status effects *)

  { Poison }
  if (entityList[id].stsPoison = True) then
  begin
    Dec(entityList[id].currentHP);
    Dec(entityList[id].tmrPoison);
    if (entityList[id].inView = True) and (entityList[0].moveCount DIV 2 = 0) then
      ui.displayMessage(entityList[id].race + ' looks sick');
    if (entityList[id].tmrPoison <= 0) then
      entityList[id].stsBewild := False;
  end;

  if (isNextToPlayer(entityList[id].posX, entityList[id].posY) = True) then
    { Attack the Player }
    combat(id)
  else if (Odd(entityList[0].moveCount)) then
    { Move in a random direction }
    wander(id, entityList[id].posX, entityList[id].posY)
  else
    { or stay in place }
    entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

procedure death;
begin
  Inc(deathList[12]);
end;

procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  attempts := 0;
  testx := 0;
  testy := 0;
  direction := 0;
  repeat
    (* Reset values after each failed loop so they don't keep dec/incrementing *)
    testx := spx;
    testy := spy;
    direction := random(6);
    (* limit the number of attempts to move so the game doesn't hang if NPC is stuck *)
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

function isNextToPlayer(spx, spy: smallint): boolean;
begin
  Result := False;
  if (map.hasPlayer(spx, spy - 1) = True) then { NORTH }
    Result := True;
  if (map.hasPlayer(spx + 1, spy - 1) = True) then { NORTH EAST }
    Result := True;
  if (map.hasPlayer(spx + 1, spy) = True) then { EAST }
    Result := True;
  if (map.hasPlayer(spx + 1, spy + 1) = True) then { SOUTH EAST }
    Result := True;
  if (map.hasPlayer(spx, spy + 1) = True) then { SOUTH }
    Result := True;
  if (map.hasPlayer(spx - 1, spy + 1) = True) then { SOUTH WEST }
    Result := True;
  if (map.hasPlayer(spx - 1, spy) = True) then { WEST }
    Result := True;
  if (map.hasPlayer(spx - 1, spy - 1) = True) then { NORTH WEST }
    Result := True;
end;

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entityList[id].attack) -
    entityList[0].defence;
  if (damageAmount > 0) then
  begin
    entityList[0].currentHP := (entityList[0].currentHP - damageAmount);
    if (entityList[0].currentHP < 1) then
    begin
      killer := 'a ' + entityList[id].race;
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.displayMessage('The hornet slightly wounds you')
      else
        ui.displayMessage('The hornet stings you, inflicting ' + IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
  begin
    ui.displayMessage('The hornet strikes but misses');
    combat_resolver.spiteDMG(id);
  end;
end;

procedure infighting(npcID, enemyID: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entityList[npcID].attack) -
    entityList[enemyID].defence;
  if (damageAmount > 0) then
  begin
    entityList[enemyID].currentHP := (entityList[enemyID].currentHP - damageAmount);
    if (entities.entityList[enemyID].currentHP < 1) then
    begin
      killEntity(enemyID);
      ui.displayMessage('The hornet kills the ' + entityList[enemyID].race);
    end
    else
      ui.displayMessage('The hornet attacks the ' + entityList[enemyID].race);
  end;
end;

end.
