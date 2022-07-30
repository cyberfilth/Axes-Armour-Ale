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
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Decision tree for Hostile state *)
procedure decisionHostile(id: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(id, spx, spy: smallint): boolean;
(* NPC attacks another entity *)
procedure combat(npcID, enemyID: smallint);

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

procedure decisionNeutral(id: smallint);
begin
  (* The wolf is sleeping *)
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionHostile(id: smallint);
begin
  (* Wake up *)
  if (entityList[id].description = 'a sleeping wolf') then
  begin
    entityList[id].description := 'a fierce Crypt Wolf';
    ui.displayMessage('the Crypt Wolf angrily wakes up');
  end;
  { If next to the player }
  if (isNextToPlayer(id, entityList[id].posX, entityList[id].posY) = True) then
    { Attack the Player }
    combat(id, 0)
  else
    chasePlayer(id, entityList[id].posX, entityList[id].posY);
end;

procedure chasePlayer(id, spx, spy: smallint);
var
  newX, newY, dx, dy, i, x: smallint;
  distance: double;
begin
  newX := 0;
  newY := 0;
  i := 0;
  (* Check if the player is in sight *)
  if (los.inView(entityList[id].posX, entityList[id].posY, entityList[0].posX,
    entityList[0].posY, entityList[id].visionRange) = True) then
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
        combat(id, 0);
      end
      (* Else if tile does not contain player, check for another entity *)
      else if (map.isOccupied(newX, newY) = True) then
      begin
        combat(id, getCreatureID(newX, newY));
        entities.moveNPC(id, spx, spy);
      end
      (* if map is unoccupied, move to that tile *)
      else if (map.isOccupied(newX, newY) = False) then
        entities.moveNPC(id, newX, newY);
    end;
  end
  else
  begin
    (* Player is not in sight, sniff them out *)
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
      if (entityList[id].smellPath[i].X = entityList[0].posX) and (entityList[id].smellPath[i].Y = entityList[0].posY) then
        exit;
    end;
    (* Check if the next step on the path is valid *)
    if (map.canMove(entityList[id].smellPath[i + 1].X, entityList[id].smellPath[i + 1].Y) = True) then
      entities.moveNPC(id, entityList[id].smellPath[i + 1].X, entityList[id].smellPath[i + 1].Y)
    else
      (* If the path is blocked, generate a new one *)
    begin
      (* Get path to player *)
      entityList[id].smellPath := smell.pathFinding(id);
      (* Set flags *)
      entityList[id].hasPath := True;
      entityList[id].destinationReached := False;
      if (map.canMove(entityList[id].smellPath[2].X, entityList[id].smellPath[2].Y) = True) then
        entities.moveNPC(id, entityList[id].smellPath[2].X, entityList[id].smellPath[2].Y);
    end;
  end;
end;

function isNextToPlayer(id, spx, spy: smallint): boolean;
var
  dx, dy: smallint;
  distance: double;
begin
  Result := False;
  entityList[id].destinationReached := True;
  entityList[id].hasPath := False;
  dx := entityList[0].posX - spx;
  dy := entityList[0].posY - spy;
  distance := sqrt(dx ** 2 + dy ** 2);
  if (round(distance) = 0) then
    Result := True;
end;

procedure combat(npcID, enemyID: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entityList[npcID].attack) -
    entityList[enemyID].defence;
  (* If damage is done *)
  if (damageAmount > 0) then
  begin
    entityList[enemyID].currentHP := (entityList[enemyID].currentHP - damageAmount);
    (* If the enemy is killed *)
    if (entityList[enemyID].currentHP < 1) then
    begin
      if (enemyID = 0) then
        (* If the enemy is the player *)
      begin
        killer := 'a ' + entityList[npcID].race;
        exit;
      end
      else
        (* If the enemy is an NPC *)
        killEntity(enemyID);
    end
    else
    begin
      if (damageAmount = 1) then
      begin
        if (enemyID = 0) then
          (* If the player is slightly wounded *)
          ui.displayMessage('The Crypt Wolf slightly wounds you')
        else
          (* If an NPC is slightly wounded *)
          ui.displayMessage('The Crypt Wolf slightly wounds the ' +
            entityList[enemyID].race);
      end
      else
        (* If significant damage is done *)
      begin
        if (enemyID = 0) then
          (* To the player *)
        begin
          ui.displayMessage('The Crypt Wolf bites you, inflicting ' +
            IntToStr(damageAmount) + ' damage');
          (* Update health display to show damage *)
          ui.updateHealth;
        end
        else
          (* To an NPC *)
          ui.displayMessage('The Crypt Wolf bites the ' + entityList[enemyID].race);
      end;
    end;
  end
  else
    (* If no damage is done *)
  begin
    if (enemyID = 0) then
    begin
      ui.displayMessage('The Crypt Wolf snaps but misses');
      combat_resolver.spiteDMG(npcID);
    end
    else
      ui.displayMessage('The Crypt Wolf nips at the ' + entityList[enemyID].race +
        ', but misses');
  end;
end;

end.
