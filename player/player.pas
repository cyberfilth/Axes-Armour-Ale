(* Player creation and movement *)
unit player;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, player_inventory, player_stats, plot_gen, combat_resolver, items,
  island, scrOverworld, file_handling, globalUtils, video, scrGame, camera, universe;

(* Create player character *)
procedure createPlayer;
(* Moves the player on the overworld map *)
procedure movePlayerOW(dir: word);
(* Moves the player on the map *)
procedure movePlayer(dir: word);
(* Process status effects *)
procedure processStatus;
(* Check if tile is occupied by an NPC *)
function combatCheck(x, y: smallint): boolean;
(* Pick up an item from the floor *)
procedure pickUp;
(*Increase Health, no more than maxHP *)
procedure increaseHealth(amount: smallint);
(* Increase health without messages *)
procedure levelupHealth(amount: smallint);
(* Regenerate Magickal power *)
procedure regenMagick;

implementation

uses
  map, fov, ui, entities, main;

procedure createPlayer;
begin
  { Add Player to the list of creatures }
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[0] do
  begin
    npcID := 0;
    (* race is used for the player name, actual race is stored in player stats unit *)
    race := plot_gen.playerName;
    description := plot_gen.playerTitle;
    glyph := '@';
    glyphColour := 'yellow';
    (* Elf stats *)
    if (player_stats.playerRace = 'Elf') then
    begin
      maxHP := 15;
      attack := 6;
      defence := 2;
      visionRange := 5;
      (* Ability to cast enchantments *)
      player_stats.maxMagick := 20;
      player_stats.currentMagick := 20;
      player_stats.dexterity := 8;
    end
    (* Dwarf stats *)
    else if (player_stats.playerRace = 'Dwarf') then
    begin
      maxHP := 25;
      attack := 5;
      defence := 3;
      visionRange := 5;
      player_stats.maxMagick := 0;
      player_stats.currentMagick := 0;
      player_stats.dexterity := 6;
    end
    else
      (* Human stats *)
    begin
      maxHP := 20;
      attack := 5;
      defence := 2;
      visionRange := 4;
      player_stats.maxMagick := 12;
      player_stats.currentMagick := 12;
      player_stats.dexterity := 6;
    end;
    currentHP := maxHP;
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := 0;
    (* Set max vision range *)
    player_stats.maxVisionRange := visionRange;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := True;
    blocks := False;
    discovered := True;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    posX := map.startX;
    posY := map.startY;
  end;
  (* Equipped item durability *)
  player_stats.numEquippedUses := 0;
  (* set up inventory *)
  player_inventory.initialiseInventory;
  ui.equippedWeapon := 'No weapon equipped';
  ui.equippedArmour := 'No armour worn';
  (* Occupy tile *)
  map.occupy(entityList[0].posX, entityList[0].posY);
  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
end;

procedure movePlayerOW(dir: word);
var
  (* store original values in case player cannot move *)
  originalX, originalY, locationID, i: smallint;
  mapFeature: shortstring;
  Dtype: dungeonTerrain;
  title: string;
begin
  (* Repaint visited tiles *)
  fov.islandFOV(entityList[0].posX, entityList[0].posY);
  originalX := entityList[0].posX;
  originalY := entityList[0].posY;
  case dir of
    1: Dec(entityList[0].posY); // N
    2: Dec(entityList[0].posX); // W
    3: Inc(entityList[0].posY); // S
    4: Inc(entityList[0].posX); // E
    5:                          // NE
    begin
      Inc(entityList[0].posX);
      Dec(entityList[0].posY);
    end;
    6:                        // SE
    begin
      Inc(entityList[0].posX);
      Inc(entityList[0].posY);
    end;
    7:                        // SW
    begin
      Dec(entityList[0].posX);
      Inc(entityList[0].posY);
    end;
    8:                        // NW
    begin
      Dec(entityList[0].posX);
      Dec(entityList[0].posY);
    end;
    9:                        // Enter location
    begin
      (* Check if the player is standing on a location *)
      if (island.overworldMap[entityList[0].posY][entityList[0].posX].Glyph = '>') then
      begin
        { Write island to disk }
        file_handling.saveOverworldMap;
        { get the id number of the location }
        locationID := island.getLocationID(entityList[0].posX, entityList[0].posY);
        { Get the name of the dungeon }
        title := island.getLocationName(entityList[0].posX, entityList[0].posY);
        { Dungeon type }
        Dtype := island.getDungeonType(entityList[0].posX, entityList[0].posY);
        { Generate a new location if it doesn't already exist }
        if (island.locationExists(entityList[0].posX, entityList[0].posY) = False) then
        begin
          if (Dtype = tDungeon) then
            universe.createNewDungeon(UTF8Decode(title), tDungeon, locationID);
        end;
        (* store overworld coordinates *)
        globalUtils.OWx := entityList[0].posX;
        globalUtils.OWy := entityList[0].posY;
        (* Set underground flag *)
        globalUtils.womblingFree := 'underground';
        (* Set game state to Game (underground) *)
        gameState := stGame;
        (* Set dungeon name *)
        universe.title := UTF8Decode(title);
        (* Load the dungeon *)
        file_handling.loadDungeonLevel(locationID, 1);
        { prepare changes to the screen }
        LockScreenUpdate;
        (* Clear the screen *)
        ui.screenBlank;
        (* Draw the game screen *)
        scrGame.displayGameScreen;
        map.mapType := Dtype;
        map.loadDisplayedMap;
        (* Find the entrance to place the player *)
        map.placeAtEntrance;
        (* Draw player and FOV *)
        map.occupy(entityList[0].posX, entityList[0].posY);
        (* draw map through the camera *)
        camera.drawMap;
        fov.fieldOfView(entityList[0].posX, entityList[0].posY,
          entityList[0].visionRange, 1);
        (* Redraw all items *)
        items.redrawItems;
        (* Redraw all NPC'S *)
        for i := 1 to entities.npcAmount do
          entities.redrawMapDisplay(i);
        (* draw map through the camera *)
        camera.drawMap;
        (* Draw player and FOV *)
        fov.fieldOfView(entityList[0].posX, entityList[0].posY,
          entityList[0].visionRange, 1);
        (* Message log *)
        ui.displayMessage('             ');
        ui.displayMessage('              ');
        ui.displayMessage('               ');
        ui.displayMessage('Good Luck...');
        ui.displayMessage('You are in the ' + UTF8Encode(universe.title));
        UnlockScreenUpdate;
        UpdateScreen(False);
        exit;
      end
      else
      begin
        LockScreenUpdate;
        TextOut(centreX('Nowhere to enter here'), 22, 'cyan', 'Nowhere to enter here');
        UnlockScreenUpdate;
        UpdateScreen(False);
      end;
    end;
  end;
  (* check if tile is walkable *)
  if (island.overworldMap[entityList[0].posY][entityList[0].posX].Blocks = True) then
  begin
    entityList[0].posX := originalX;
    entityList[0].posY := originalY;
    Dec(entityList[0].moveCount);
  end;
  (* Break out of procedure when leaving the overworld map *)
  if (globalUtils.womblingFree = 'overground') then
  begin
    fov.islandFOV(entityList[0].posX, entityList[0].posY);
    (* display message on type of terrain or name of location *)
    { Blank out the old message }
    scrOverworld.eraseTerrain;

    if (island.overworldMap[entityList[0].posY][entityList[0].posX].TerrainType =
      tForest) then
      TextOut(centreX('forest'), 22, 'cyan', 'forest')
    else if (island.overworldMap[entityList[0].posY][entityList[0].posX].TerrainType =
      tPlains) then
      TextOut(centreX('plains'), 22, 'cyan', 'plains')
    else if (island.overworldMap[entityList[0].posY][entityList[0].posX].TerrainType =
      tLocation) then
    begin
      mapFeature := 'entrance to ' + island.getLocationName(
        entityList[0].posX, entityList[0].posY);
      TextOut(centreX(mapFeature), 22, 'cyan', mapFeature);
    end;

    Inc(entities.entityList[0].moveCount);
    (* Regenerate Magick *)
    if (player_stats.playerRace <> 'Dwarf') then
      regenMagick;
  end;
end;

(* Move the player within the confines of the game map *)
procedure movePlayer(dir: word);
var
  (* store original values in case player cannot move *)
  originalX, originalY: smallint;
begin
  (* Unoccupy tile *)
  map.unoccupy(entityList[0].posX, entityList[0].posY);
  (* Repaint visited tiles *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 0);
  originalX := entities.entityList[0].posX;
  originalY := entities.entityList[0].posY;
  case dir of
    1: Dec(entities.entityList[0].posY); // N
    2: Dec(entities.entityList[0].posX); // W
    3: Inc(entities.entityList[0].posY); // S
    4: Inc(entities.entityList[0].posX); // E
    5:                      // NE
    begin
      Inc(entities.entityList[0].posX);
      Dec(entities.entityList[0].posY);
    end;
    6:                      // SE
    begin
      Inc(entities.entityList[0].posX);
      Inc(entities.entityList[0].posY);
    end;
    7:                      // SW
    begin
      Dec(entities.entityList[0].posX);
      Inc(entities.entityList[0].posY);
    end;
    8:                      // NW
    begin
      Dec(entities.entityList[0].posX);
      Dec(entities.entityList[0].posY);
    end;
  end;
  (* check if tile is occupied *)
  if (map.isOccupied(entities.entityList[0].posX, entities.entityList[0].posY) =
    True) then
    (* check if tile is occupied by hostile NPC *)
    if (combatCheck(entities.entityList[0].posX, entities.entityList[0].posY) =
      True) then
    begin
      entities.entityList[0].posX := originalX;
      entities.entityList[0].posY := originalY;
    end;
  Inc(entities.entityList[0].moveCount);
  (* check if tile is walkable *)
  if (map.canMove(entities.entityList[0].posX, entities.entityList[0].posY) = False) then
  begin
    entities.entityList[0].posX := originalX;
    entities.entityList[0].posY := originalY;
    (* display a clumsy message if player is intoxicated *)
    if (entityList[0].stsDrunk = True) then
      ui.displayMessage('You bump into a wall');
    Dec(entities.entityList[0].moveCount);
  end;
  (* Occupy tile *)
  map.occupy(entityList[0].posX, entityList[0].posY);
  fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[0].visionRange, 1);
  ui.writeBufferedMessages;

  (* Regenerate Magick *)
  if (player_stats.playerRace <> 'Dwarf') then
    regenMagick;
end;

procedure processStatus;
begin
  (* Inebriation *)
  if (entities.entityList[0].stsDrunk = True) then
  begin
    if (entities.entityList[0].tmrDrunk <= 0) then
    begin
      entities.entityList[0].tmrDrunk := 0;
      entities.entityList[0].stsDrunk := False;
      ui.bufferMessage('The effects of the alcohol wear off');
    end
    else
      Dec(entities.entityList[0].tmrDrunk);
  end;

  (* Poison *)
  if (entities.entityList[0].stsPoison = True) then
  begin
    if (ui.poisonStatusSet = False) then
    begin
      (* Update UI *)
      ui.displayStatusEffect(1, 'poison');
      ui.poisonStatusSet := True;
      entityList[0].glyphColour := 'green';
    end;
    if (entities.entityList[0].tmrPoison <= 0) then
    begin
      entities.entityList[0].tmrPoison := 0;
      entities.entityList[0].stsPoison := False;
      (* Update UI *)
      ui.displayStatusEffect(0, 'poison');
      ui.poisonStatusSet := False;
      entityList[0].glyphColour := 'yellow';
    end
    else
    begin
      Dec(entityList[0].currentHP);
      Dec(entityList[0].tmrPoison);
      updateHealth;
    end;
  end;
end;


function combatCheck(x, y: smallint): boolean;
  { TODO : Replace this with a check to see if the tile is occupied }
var
  i: smallint;
begin
  Result := False;
  for i := 1 to entities.npcAmount do
  begin
    if (x = entities.entityList[i].posX) then
    begin
      if (y = entities.entityList[i].posY) then
        combat_resolver.combat(i);
      Result := True;
    end;
  end;
end;

procedure pickUp;
var
  i: smallint;
begin
  for i := 0 to High(itemList) do
  begin
    if (entities.entityList[0].posX = itemList[i].posX) and
      (entities.entityList[0].posY = itemList[i].posY) and
      (itemList[i].onMap = True) then
    begin
      if (player_inventory.addToInventory(i) = True) then
        Inc(entities.entityList[0].moveCount)
      else
        ui.displayMessage('Your inventory is full');
    end
    else if (entities.entityList[0].posX = itemList[i].posX) and
      (entities.entityList[0].posY = itemList[i].posY) and
      (itemList[i].onMap = False) then
      ui.displayMessage('There is nothing on the ground here');
  end;
end;

procedure increaseHealth(amount: smallint);
begin
  if (entities.entityList[0].currentHP <> entities.entityList[0].maxHP) then
  begin
    if ((entities.entityList[0].currentHP + amount) >= entities.entityList[0].maxHP) then
      entities.entityList[0].currentHP := entities.entityList[0].maxHP
    else
      entities.entityList[0].currentHP := entities.entityList[0].currentHP + amount;
    ui.updateHealth;
    ui.bufferMessage('You feel restored');
  end
  else
    ui.bufferMessage('You are already at full health');
end;

procedure levelupHealth(amount: smallint);
begin
  if (entities.entityList[0].currentHP <> entities.entityList[0].maxHP) then
  begin
    if ((entities.entityList[0].currentHP + amount) >= entities.entityList[0].maxHP) then
      entities.entityList[0].currentHP := entities.entityList[0].maxHP
    else
      entities.entityList[0].currentHP := entities.entityList[0].currentHP + amount;
    ui.updateHealth;
  end;
end;

procedure regenMagick;
begin
  (* Player cannot regenerate if they have status effects *)
  if (entityList[0].stsPoison = False) and (entityList[0].stsDrunk = False) then
  begin
    { Elves regenerate magick every 3 turns }
    if (player_stats.playerRace = 'Elf') then
    begin
      if ((entities.entityList[0].moveCount mod 8) = 0) and
        (player_stats.currentMagick < player_stats.maxMagick) then
        Inc(player_stats.currentMagick);
    end
    else
    begin
      { Humans regenerate magick every 8 turns }
      if ((entities.entityList[0].moveCount mod 16) = 0) and
        (player_stats.currentMagick < player_stats.maxMagick) then
        Inc(player_stats.currentMagick);
    end;
  end;
end;

end.
