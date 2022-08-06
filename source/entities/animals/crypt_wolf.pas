(* Sleeping when first encountered, chases the player when awake *)

unit crypt_wolf;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Math, smell, globalUtils, universe, ui, los, combat_resolver;

(* Create a Crypt Wolf *)
procedure createCryptWolf(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);
(* Creature death *)
procedure death;
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Decision tree for Hostile state *)
procedure decisionHostile(id: smallint);
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
  entities, map;

procedure createCryptWolf(uniqueid, npcx, npcy: smallint);
begin
  (* Add a crypt wolf to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Crypt Wolf';
    intName := 'crptWolf';
    article := True;
    description := 'a sleeping wolf';
    glyph := 'd';
    glyphColour := 'white';
    maxHP := randomRange(4, 6) + universe.currentDepth;
    currentHP := maxHP;
    attack := randomRange(6, 9) + universe.currentDepth;
    defence := randomRange(7, 8) + universe.currentDepth;
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 6;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := animalFaction;
    state := stateNeutral;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    hasPath := False;
    destinationReached := False;
    entities.initPath(uniqueid);
    posX := npcx;
    posY := npcy;
    entities.initPath(uniqueid);
  end;
  (* Occupy tile *)
  map.occupy(npcx, npcy);
end;

procedure takeTurn(id: smallint);
begin
  case entityList[id].state of
    stateNeutral: decisionNeutral(id);
    stateHostile: decisionHostile(id);
    else
      decisionNeutral(id);
  end;
end;

procedure death;
begin
  Inc(deathList[16]);
end;

procedure decisionNeutral(id: smallint);
begin
  (* The wolf is sleeping *)
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
    begin
      combat(id);
    end
    else
      {------------------------------- Chase the player }
    begin
      chaseTarget(id, entityList[id].posX, entityList[id].posY);
    end;
  end

  { If player not in sight, smell them out }
  else
  begin
    (* Randomly display a message that you are being chased *)
    if (randomRange(1, 5) = 3) then
      ui.displayMessage('You hear sounds of pursuit');
    followScent(id);
  end;
end;

procedure chaseTarget(id, spx, spy: smallint);
var
  newX, newY, dx, dy: smallint;
  distance: double;
begin
  newX := 0;
  newY := 0;
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
      ui.bufferMessage('The hob bumps into ' + getCreatureName(newX, newY));
      entities.moveNPC(id, spx, spy);
    end
    (* if map is unoccupied, move to that tile *)
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end;
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
        ui.displayMessage('The Crypt Wolf slightly wounds you')
      else
        ui.displayMessage('The Crypt Wolf claws you, dealing ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
  begin
    chance := randomRange(1, 4);
    if (chance = 1) then
      ui.displayMessage('The Crypt Wolf snaps but misses')
    else if (chance = 2) then
      ui.displayMessage('The Crypt Wolf pounces at you');
    combat_resolver.spiteDMG(id);
  end;
end;

procedure followScent(id: smallint);
var
  i: smallint;
begin
  if (entityList[id].hasPath = False) then
  begin
    (* Get path to player *)
    entityList[id].smellPath := smell.pathFinding(id);
    (* Set flags *)
    entityList[id].hasPath := True;
    entityList[id].destinationReached := False;
  end;
  (* Follow scent to player. Pathfinding is essentially stateless so we have
       to search for NPC's current position in the path first *)
  for i := 1 to 30 do
  begin
    if (entityList[id].smellPath[i].X = entityList[0].posX) and
      (entityList[id].smellPath[i].Y = entityList[0].posY) then
      exit;
  end;
  (* Check if the next step on the path is valid *)
  if (map.canMove(entityList[id].smellPath[i + 1].X,
    entityList[id].smellPath[i + 1].Y) = True) then
    entities.moveNPC(id, entityList[id].smellPath[i + 1].X,
      entityList[id].smellPath[i + 1].Y)
  else
    (* If the path is blocked, generate a new one *)
  begin
    (* Get path to player *)
    entityList[id].smellPath := smell.pathFinding(id);
    (* Set flags *)
    entityList[id].hasPath := True;
    entityList[id].destinationReached := False;
    if (map.canMove(entityList[id].smellPath[2].X, entityList[id].smellPath[2].Y) =
      True) then
      entities.moveNPC(id, entityList[id].smellPath[2].X,
        entityList[id].smellPath[2].Y);
  end;
end;

end.
