(* Starts off as a corpse, wakes up as a zombie *)

unit corpse_zombie;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, smell, universe, combat_resolver, player_stats,
  items, ale_tankard, wine_flask;

(* Create a Zombie *)
procedure createZombie(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);
(* Creature death *)
procedure death(id: smallint);
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Decision tree for Hostile state *)
procedure decisionHostile(id: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase enemy *)
procedure chaseTarget(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Combat *)
procedure combat(id: smallint);
(* Sniff out the player *)
procedure followScent(id: smallint);

implementation

uses
  entities, globalutils, ui, los, map;

procedure createZombie(uniqueid, npcx, npcy: smallint);
begin
  (* Add a zombie to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Corpse';
    intName := 'corpseZombie';
    article := True;
    description := 'a rotting corpse';
    glyph := '%';
    glyphColour := 'green';
    maxHP := randomRange(6, 9) + universe.currentDepth;
    currentHP := maxHP;
    attack := randomRange(5, 7) + player_stats.playerLevel;
    defence := randomRange(7, 9) + player_stats.playerLevel;
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 8;
    (* Counts number of turns the NPC is in pursuit *)
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := undeadFaction;
    state := stateNeutral;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    stsDrunk := False;
    stsPoison := False;
    stsBewild := False;
    stsFrozen := False;	
    tmrDrunk := 0;
    tmrPoison := 0;
    tmrBewild := 0;
    tmrFrozen := 0;
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
  if (entityList[id].state <> stateNeutral) then
  begin
    { Bewildered }
    if (entityList[id].stsBewild = True) then
    begin
      Dec(entityList[id].tmrBewild);
      if (entityList[id].inView = True) and (entityList[0].moveCount div 2 = 0) then
        ui.displayMessage(entityList[id].race + ' seems bewildered')
      else if (entityList[id].inView = True) then
      begin
        ui.displayMessage(entityList[id].race + ' bites itself');
        Dec(entityList[id].currentHP);
      end;
      wander(id, entityList[id].posX, entityList[id].posY);
      if (entityList[id].tmrBewild <= 0) then
        entityList[id].stsBewild := False;
    end;
  end;

  if (entityList[id].stsBewild <> True) then
  begin
    case entityList[id].state of
      stateNeutral: decisionNeutral(id);
      stateHostile: decisionHostile(id);
    end;
  end;
end;

procedure death(id: smallint);
var
  (* Chance of dropping an item *)
  chance: smallint;
begin
  chance := 0;
  Inc(deathList[25]);
  chance := randomRange(0, 2);
  if (chance = 2) then
  begin
    (* Check if there is already an item on the floor here *)
    if (items.containsItem(entityList[id].posX, entityList[id].posY) = False) then
    begin
      { Place item on the game map }
      SetLength(itemList, Length(itemList) + 1);
      chance := randomRange(1, 2);
      if (chance = 1) then
      begin
        ale_tankard.createAleTankard(entityList[id].posX, entityList[id].posY);
        ui.displayMessage('The zombie drops a tankard of ale');
      end
      else
      begin
        wine_flask.createWineFlask(entityList[id].posX, entityList[id].posY);
        ui.displayMessage('The zombie drops a flask of wine');
      end;
    end;
  end;
end;

procedure decisionNeutral(id: smallint);
begin
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionHostile(id: smallint);
begin
  {------------------------------- If NPC can see the player }
  if (los.inView(entityList[id].posX, entityList[id].posY, entityList[0].posX,
    entityList[0].posY, entityList[id].visionRange) = True) then
  begin
    entityList[id].moveCount := 5;
    {------------------------------- If next to the player }
    if (isNextToPlayer(entityList[id].posX, entityList[id].posY) = True) then
      {------------------------------- Attack the Player }
      combat(id)
    else
      {------------------------------- Chase the player }
      chaseTarget(id, entityList[id].posX, entityList[id].posY);
  end

  { If not injured and player not in sight, smell them out }
  else if (entityList[id].moveCount > 0) then
  begin
    (* Randomly display a message that you are being chased *)
    if (randomRange(1, 5) = 3) then
      ui.displayMessage('You hear shuffling sounds');
    followScent(id);
  end

  else
    {------------------------------- Wander }
    wander(id, entityList[id].posX, entityList[id].posY);
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

procedure chaseTarget(id, spx, spy: smallint);
var
  newX, newY, dx, dy, choice: smallint;
  distance: double;
begin
  newX := 0;
  newY := 0;
  choice := 0;
  choice := randomRange(1, 3);
  if (choice = 2) then
  begin
    (* Get new coordinates to chase the player *)
    dx := entityList[0].posX - spx;
    dy := entityList[0].posY - spy;
    if (dx = 0) and (dy = 0) then
    begin
      newX := spx;
      newy := spy;
    end
    else
    begin
      distance := sqrt(dx ** 2 + dy ** 2);
      dx := round(dx / distance);
      dy := round(dy / distance);
      newX := spx + dx;
      newY := spy + dy;
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
        ui.bufferMessage('The zombie bumps into ' + getCreatureName(newX, newY));
        entities.moveNPC(id, spx, spy);
      end
      (* if map is unoccupied, move to that tile *)
      else if (map.isOccupied(newX, newY) = False) then
        entities.moveNPC(id, newX, newY);
    end
    else
      wander(id, spx, spy);
  end
  else
    wander(id, spx, spy);
end;

{$I nextto}

procedure combat(id: smallint);
var
  damageAmount, chance: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) -
    entities.entityList[0].defence;
  if (damageAmount > 0) then
  begin
    entities.entityList[0].currentHP :=
      (entities.entityList[0].currentHP - damageAmount);
    if (entities.entityList[0].currentHP < 1) then
    begin
      killer := 'a ' + entityList[id].race;
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.displayMessage('The zombie grabs you')
      else
        ui.displayMessage('The zombie squeezes you, inflicting ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
  begin
    chance := randomRange(1, 4);
    if (chance = 1) then
      ui.displayMessage('The zombie lurches towards you')
    else if (chance = 2) then
      ui.displayMessage('The zombie groans');
    combat_resolver.spiteDMG(id);
  end;
end;

procedure followScent(id: smallint);
var
  smellDir: char;
begin
  Dec(entityList[id].moveCount);
  smellDir := scentDirection(entities.entityList[id].posY, entities.entityList[id].posX);
  case smellDir of
    'n':
    begin
      if (map.canMove(entities.entityList[id].posX,
        (entities.entityList[id].posY - 1)) and
        (map.isOccupied(entities.entityList[id].posX,
        (entities.entityList[id].posY - 1)) = False)) then
        entities.moveNPC(id, entities.entityList[id].posX,
          (entities.entityList[id].posY - 1));
    end;
    'e':
    begin
      if (map.canMove((entities.entityList[id].posX + 1),
        entities.entityList[id].posY) and (map.isOccupied(
        (entities.entityList[id].posX + 1), entities.entityList[id].posY) = False)) then
        entities.moveNPC(id, (entities.entityList[id].posX + 1),
          entities.entityList[id].posY);
    end;
    's':
    begin
      if (map.canMove(entities.entityList[id].posX,
        (entities.entityList[id].posY + 1)) and
        (map.isOccupied(entities.entityList[id].posX,
        (entities.entityList[id].posY + 1)) = False)) then
        entities.moveNPC(id, entities.entityList[id].posX,
          (entities.entityList[id].posY + 1));
    end;
    'w':
    begin
      if (map.canMove((entities.entityList[id].posX - 1),
        entities.entityList[id].posY) and (map.isOccupied(
        (entities.entityList[id].posX - 1), entities.entityList[id].posY) = False)) then
        entities.moveNPC(id, (entities.entityList[id].posX - 1),
          entities.entityList[id].posY);
    end
    else
      entities.moveNPC(id, entities.entityList[id].posX, entities.entityList[id].posY);
  end;
end;

end.
