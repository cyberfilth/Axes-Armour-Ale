(* Mushroom person - slow but can poison the player *)

unit mushroom_person;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, ai_animal, globalUtils, combat_resolver;

(* Create a mushroom person *)
procedure createMushroomPerson(uniqueid, npcx, npcy: smallint);
(* The NPC takes their turn in the game loop *)
procedure takeTurn(id: smallint);
(* Creature death *)
procedure death;
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Decision tree for Hostile state *)
procedure decisionHostile(id: smallint);
(* Decision tree for Escape state *)
procedure decisionEscape(id: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;

implementation

uses
  entities, universe, los, map;

procedure createMushroomPerson(uniqueid, npcx, npcy: smallint);
var
  mood: byte;
begin
  (* Detemine hostility *)
  mood := randomRange(1, 2);
  (* Add a Mushroom Person to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Mushroom Person';
    intName := 'Matango';
    article := True;
    description := 'a giant shambling fungus';
    glyph := 'F';
    glyphColour := 'lightGreen';
    maxHP := randomRange(5, 8) + universe.currentDepth;
    currentHP := maxHP;
    attack := randomRange(entityList[0].attack, entityList[0].attack + 2);
    defence := randomRange(entityList[0].defence + 2, entityList[0].defence + 4);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 4;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := fungusFaction;
    if (mood = 1) then
      state := stateNeutral
    else
      state := stateHostile;
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
  end;
  (* Occupy tile *)
  map.occupy(npcx, npcy);
end;


procedure takeTurn(id: smallint);
begin
  case entityList[id].state of
    stateNeutral: decisionNeutral(id);
    stateHostile: decisionHostile(id);
    stateEscape: decisionEscape(id);
  end;
end;

procedure death;
begin
  Inc(deathList[6]);
end;

procedure decisionNeutral(id: smallint);
var
  stopAndSmellFlowers: byte;
begin
  stopAndSmellFlowers := globalutils.randomRange(1, 4);
  if (stopAndSmellFlowers = 1) then
    { Either wander randomly }
    ai_animal.wander(id, entityList[id].posX, entityList[id].posY)
  else
    { or stay in place }
    entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionHostile(id: smallint);
begin
  { If health is below 25%, escape }
  if (entityList[id].currentHP < (entityList[id].maxHP div 4)) then
  begin
    entityList[id].state := stateEscape;
    ai_animal.escapePlayer(id, entityList[id].posX, entityList[id].posY);
  end

  { If NPC can see the player }
  else if (los.inView(entityList[id].posX, entityList[id].posY,
    entityList[0].posX, entityList[0].posY, entityList[id].visionRange) = True) then
  begin
    { If next to the player }
    if (isNextToPlayer(entityList[id].posX, entityList[id].posY) = True) then
      { Attack the Player }
      ai_animal.combat(id)
    else
      { Chase the player }
      ai_animal.chasePlayer(id, entityList[id].posX, entityList[id].posY);
  end

  { If not injured and player not in sight }
  else
    ai_animal.wander(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionEscape(id: smallint);
begin
  { Check if player is in sight }
  if (los.inView(entityList[id].posX, entityList[id].posY, entityList[0].posX,
    entityList[0].posY, entityList[id].visionRange) = True) then
    { If the player is in sight, run away }
    ai_animal.escapePlayer(id, entityList[id].posX, entityList[id].posY)

  { If the player is not in sight }
  else
  begin
    { Heal if health is below 50% }
    if (entityList[id].currentHP < (entityList[id].maxHP div 2)) then
      Inc(entityList[id].currentHP, 5)
    else
      { Reset state to Neutral and wander }
      ai_animal.wander(id, entityList[id].posX, entityList[id].posY);
  end;
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

end.
