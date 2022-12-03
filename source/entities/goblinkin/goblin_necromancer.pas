(* Enemy that casts necrotic magick *)

unit goblin_necromancer;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, smell, globalUtils, universe, combat_resolver, player_stats, items,
  necro_axe, dlgInfo;

(* Create a Goblin Necromancer *)
procedure createNecromancer(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);
(* Creature death *)
procedure death(id: smallint);
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Decision tree for Hostile state *)
procedure decisionHostile(id: smallint);
(* Decision tree for Escape state *)
procedure decisionEscape(id: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase enemy *)
procedure chaseTarget(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Run from player *)
procedure escapePlayer(id, spx, spy: smallint);
(* Combat *)
procedure combat(id: smallint);
(* Sniff out the player *)
procedure followScent(id: smallint);
(* Fire magick at player *)
procedure fireMagick(id: smallint);

implementation

uses
  entities, ui, los, map;

procedure createNecromancer(uniqueid, npcx, npcy: smallint);
begin
  (* Add a redcap to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Goblin necromancer';
    intName := 'GobNecro';
    article := True;
    description := 'a Goblin in magenta robes';
    glyph := 'g';
    glyphColour := 'lightMagenta';
    maxHP := randomRange(6, 8) + universe.currentDepth;
    currentHP := maxHP;
    attack := randomRange(7, 9) + player_stats.playerLevel;
    defence := randomRange(5, 7) + player_stats.playerLevel;
    weaponDice := 0;
    (* Weapon Adds are used in place of ammo *)
    weaponAdds := 3;
    xpReward := maxHP;
    visionRange := 5;
    (* Counts number of turns the NPC is in pursuit *)
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := redcapFaction;
    state := stateHostile;
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

  { Poison }
  if (entityList[id].stsPoison = True) then
  begin
    Dec(entityList[id].currentHP);
    Dec(entityList[id].tmrPoison);
    if (entityList[id].inView = True) and (entityList[0].moveCount div 2 = 0) then
      ui.displayMessage(entityList[id].race + ' looks sick');
    if (entityList[id].tmrPoison <= 0) then
      entityList[id].stsBewild := False;
  end;
  { Bewildered }
  if (entityList[id].stsBewild = True) then
  begin
    Dec(entityList[id].tmrBewild);
    if (entityList[id].inView = True) and (entityList[0].moveCount div 2 = 0) then
      ui.displayMessage(entityList[id].race + ' seems bewildered')
    else if (entityList[id].inView = True) then
    begin
      ui.displayMessage(entityList[id].race + ' zaps themself');
      Dec(entityList[id].currentHP);
    end;
    wander(id, entityList[id].posX, entityList[id].posY);
    if (entityList[id].tmrBewild <= 0) then
      entityList[id].stsBewild := False;
  end;

  if (entityList[id].stsBewild <> True) then
  begin
    case entityList[id].state of
      stateNeutral: decisionNeutral(id);
      stateHostile: decisionHostile(id);
      stateEscape: decisionEscape(id);
    end;
  end;
end;

procedure death(id: smallint);
var
  i: smallint;
begin
  Inc(deathList[24]);
  (* Necromancer raises the dead *)
  dlgInfo.dialogType := dlgNecro;
  for i := 1 to High(entityList) do
    if (entityList[i].race = 'Corpse') then
    begin
      entityList[i].race := 'Zombie rotter';
      entityList[i].description := 'a walking corpse';
      entityList[i].glyph := 'z';
      entityList[i].state := stateHostile;
    end;
  (* Check if there is already an item on the floor here *)
  if (items.containsItem(entityList[id].posX, entityList[id].posY) = False) then
  begin
    { Place item on the game map }
    SetLength(itemList, Length(itemList) + 1);
    necro_axe.createNecroAxe(entityList[id].posX, entityList[id].posY);
    ui.displayMessage('The necromancer drops an axe');
  end;
end;

procedure decisionNeutral(id: smallint);
var
  stopAndSmellFlowers: byte;
begin
  stopAndSmellFlowers := globalutils.randomRange(1, 2);
  if (stopAndSmellFlowers = 1) then
    { Either wander randomly }
    wander(id, entityList[id].posX, entityList[id].posY)
  else
    { or stay in place }
    entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionHostile(id: smallint);
begin
  {------------------------------- If NPC can see the player }
  if (los.inView(entityList[id].posX, entityList[id].posY, entityList[0].posX,
    entityList[0].posY, entityList[id].visionRange) = True) then
  begin
    entityList[id].moveCount := 3;
    {------------------------------- If next to the player }
    if (isNextToPlayer(entityList[id].posX, entityList[id].posY) = True) then
      {------------------------------- Attack the Player }
      combat(id)
    else
      {------------------------------- Get within firing range }
      chaseTarget(id, entityList[id].posX, entityList[id].posY);
  end


  { If not injured and player not in sight, smell them out }
  else if (entityList[id].moveCount > 0) then
  begin
    (* Randomly display a message that you are being chased *)
    if (randomRange(1, 8) = 3) then
      ui.displayMessage('You hear sounds of pursuit');
    followScent(id);
  end

  {------------------------------- If health is below 50%, escape }
  else if (entityList[id].currentHP < (entityList[id].maxHP div 2)) then
  begin
    entityList[id].state := stateEscape;
    escapePlayer(id, entityList[id].posX, entityList[id].posY);
  end

  else
    {------------------------------- Wander }
    wander(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionEscape(id: smallint);
begin
  { Check if player is in sight }
  if (los.inView(entityList[id].posX, entityList[id].posY, entityList[0].posX,
    entityList[0].posY, entityList[id].visionRange) = True) then
    { If the player is in sight, run away }
    escapePlayer(id, entityList[id].posX, entityList[id].posY)

  { If the player is not in sight }
  else
  begin
    { Heal if health is below 50% }
    if (entityList[id].currentHP < (entityList[id].maxHP div 2)) then
      Inc(entityList[id].currentHP, 3)
    else
      { Reset state to Neutral and wander }
      wander(id, entityList[id].posX, entityList[id].posY);
  end;
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
    (* If in range of the player *)
    if (round(distance) = 4) and (entityList[id].weaponAdds > 0) then
    begin
      fireMagick(id);
    end
    (* If too close to the player *)
    else if (round(distance) < 3) then
    begin
      escapePlayer(id, spx, spy);
      exit;
    end
    else
      (* If too far from the player *)
    begin
      dx := round(dx / distance);
      dy := round(dy / distance);
      newX := spx + dx;
      newY := spy + dy;
    end;
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
      ui.bufferMessage('The goblin bumps into ' + getCreatureName(newX, newY));
      entities.moveNPC(id, spx, spy);
    end
    (* if map is unoccupied, move to that tile *)
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  else
    wander(id, spx, spy);
end;

{$I nextto}

procedure escapePlayer(id, spx, spy: smallint);
var
  newX, newY, dx, dy: smallint;
  distance: single;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to escape the player *)
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
    if (dx > 0) then
      dx := -1;
    if (dx < 0) then
      dx := 1;
    dy := round(dy / distance);
    if (dy > 0) then
      dy := -1;
    if (dy < 0) then
      dy := 1;
    newX := spx + dx;
    newY := spy + dy;
  end;
  if (map.canMove(newX, newY) = True) then
  begin
    if (map.hasPlayer(newX, newY) = True) then
    begin
      entities.moveNPC(id, spx, spy);
      combat(id);
    end
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  else
    wander(id, spx, spy);
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
        ui.displayMessage('The goblin slightly wounds you')
      else
        ui.displayMessage('The goblin claws you, dealing ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
  begin
    chance := randomRange(1, 4);
    if (chance = 1) then
      ui.displayMessage('The goblin screams curses')
    else if (chance = 2) then
      ui.displayMessage('The goblin yells');
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
        entities.entityList[id].posY) and
        (map.isOccupied((entities.entityList[id].posX + 1),
        entities.entityList[id].posY) = False)) then
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
        entities.entityList[id].posY) and
        (map.isOccupied((entities.entityList[id].posX - 1),
        entities.entityList[id].posY) = False)) then


        entities.moveNPC(id, (entities.entityList[id].posX - 1),
          entities.entityList[id].posY);
    end
    else
      entities.moveNPC(id, entities.entityList[id].posX, entities.entityList[id].posY);
  end;
end;

procedure fireMagick(id: smallint);
var
  damageAmount, yell: smallint;
begin
  yell := 0;
  yell := randomRange(1, 6);
  case yell of
    1: ui.displayMessage('The necromancer screams "Die!"');
    2: ui.displayMessage('The necromancer yells "Take dis!"');
    3: ui.displayMessage('The necromancer screeches in anger');
    4: ui.displayMessage('The necromancer draws runes in the air');
    5: ui.displayMessage('The goblin crackles with necromantic energy');
    else
      ui.displayMessage('The necromancer yells "For the dead!"');
  end;
  los.firingLine('necro', id, entityList[id].posX, entityList[id].posY,
    entityList[0].posX, entityList[0].posY);
  (* Check if bolt has hit the player, Dwarves have some magickal resistance *)
  if (player_stats.playerRace = 'Dwarf') then
    damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) -
      entities.entityList[0].defence
  else
    damageAmount := globalutils.randomRange(1, entities.entityList[id].attack + 3) -
      entities.entityList[0].defence;
  if (damageAmount > 0) then
  begin
    entities.entityList[0].currentHP :=
      (entities.entityList[0].currentHP - damageAmount);
    if (entities.entityList[0].currentHP < 1) then
    begin
      killer := 'a ' + entityList[id].race;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.displayMessage('The blast slightly wounds you')
      else
        ui.displayMessage('The blast hits you, dealing ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
    ui.displayMessage('The blast zaps past you');
  (* Remove a spell from arsenal *)
  Dec(entityList[id].weaponAdds);
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

end.
