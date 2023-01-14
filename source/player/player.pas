(* Player creation and movement *)
unit player;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, player_stats, plot_gen, combat_resolver, items, dlgInfo, ai_villager, ai_merchant, island, scrOverworld, file_handling,
  globalUtils, video, universe;

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
(* Check if a tile is occupied by a friendly NPC *)
function chatCheck(x, y:smallint):boolean;
(* Pick up an item from the floor *)
procedure pickUp;
(*Increase Health, no more than maxHP *)
procedure increaseHealth(amount: smallint);
(* Increase Health with no feedback *)
procedure topupHealth(amount: smallint);
(* Increase health without messages *)
procedure levelupHealth(amount: smallint);
(* Regenerate Magickal power *)
procedure regenMagick;

implementation

uses
  map, fov, ui, entities, main, player_inventory;

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
    stsBewild := False;
    stsFrozen := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    tmrBewild := 0;
    tmrFrozen := 0;
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
  originalX, originalY, locationID: smallint;
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
           universe.createNewDungeon(UTF8Decode(title), Dtype, locationID);
           island.setVisitedFlag(entityList[0].posX, entityList[0].posY);
        end;
        (* store overworld coordinates *)
        globalUtils.OWx := entityList[0].posX;
        globalUtils.OWy := entityList[0].posY;
        (* Set underground flag *)
        globalUtils.womblingFree := 'underground';
        (* Set game state *)
        if (Dtype = tVillage) then
          gameState := stVillage
        else
          gameState := stGame;
        (* Set dungeon name *)
        universe.title := UTF8Decode(title);
        (* Clear list of items *)
        items.initialiseItems;
        (* Clear list of NPC's *)
        entities.newFloorNPCs;
        (* Load the dungeon *)
        file_handling.loadDungeonLevel(locationID, 1);
        { Show already discovered tiles }
        for r := 1 to globalUtils.MAXROWS do
            begin
                 for c := 1 to globalUtils.MAXCOLUMNS do
                 begin
                      drawTile(c, r, 0);
                 end;
            end;
        map.mapType := Dtype;
        map.loadDisplayedMap;
        (* Find the entrance to place the player *)
        map.placeAtEntrance;
        (* Draw player and FOV *)
        map.occupy(entityList[0].posX, entityList[0].posY);
        (* Message log *)
        ui.displayMessage('           ');
        ui.displayMessage('            ');
        ui.displayMessage('             ');
        if (Dtype = tVillage) then
          begin
            ui.displayMessage('              ');
            ui.displayMessage('You enter the village of ' + UTF8Encode(universe.title));
          end
        else
          begin
            ui.displayMessage('Good Luck...');
            ui.displayMessage('You are in the ' + UTF8Encode(universe.title));
          end;
        (* Redraw map and the contents *)
        main.returnToGameScreen;
        main.gameLoop;
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
  (* Check if the player is in a village *)
  if (gameState = stVillage) then
    begin
        (* Unoccupy tile *)
        map.unoccupy(entityList[0].posX, entityList[0].posY);
        (* Repaint visited tiles *)
        fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 0);
        originalX := entities.entityList[0].posX;
        originalY := entities.entityList[0].posY;
        (* Choose a direction: duplicate code will be refactored eventually *)
        case dir of
          1: // N 
          begin
            (* Check if at the boundaries of the map *)
            if (entityList[0].posY = 1) then
              dlginfo.dialogType := dlgLveVill
            else
              Dec(entities.entityList[0].posY); 
          end;
          2: // W
          begin
            if (entityList[0].posX = 12) then
              dlginfo.dialogType := dlgLveVill
            else
              Dec(entities.entityList[0].posX);
          end;
          3: // S
          begin
            if (entityList[0].posY = 20) then
              dlginfo.dialogType := dlgLveVill
            else
              Inc(entities.entityList[0].posY);
          end;
          4: // E
          begin
            if (entityList[0].posX = 67) then
              dlginfo.dialogType := dlgLveVill
            else
              Inc(entities.entityList[0].posX);
          end;
          5:                      // NE
          begin
            if (entityList[0].posY = 1) or (entityList[0].posX = 67) then
              dlginfo.dialogType := dlgLveVill
            else
              begin
                Inc(entities.entityList[0].posX);
                Dec(entities.entityList[0].posY);
              end;
          end;
          6:                      // SE
          begin
            if (entityList[0].posY = 20) or (entityList[0].posX = 67) then
              dlginfo.dialogType := dlgLveVill
            else
              begin
                Inc(entities.entityList[0].posX);
                Inc(entities.entityList[0].posY);
              end;
          end;
          7:                      // SW
          begin
            if (entityList[0].posY = 20) or (entityList[0].posX = 12) then
              dlginfo.dialogType := dlgLveVill
            else
              begin
                Dec(entities.entityList[0].posX);
                Inc(entities.entityList[0].posY);
              end;
          end;
          8:                      // NW
          begin
            if (entityList[0].posY = 1) or (entityList[0].posX = 12) then
              dlginfo.dialogType := dlgLveVill
            else
              begin
                Dec(entities.entityList[0].posX);
                Dec(entities.entityList[0].posY);
              end;
          end;
          9:
          begin
                                // Wait in place
          end;
        end;
        (* check if tile is occupied *)
        if (map.isOccupied(entities.entityList[0].posX, entities.entityList[0].posY) = True) then
          (* check if tile is occupied by NPC and initiate chat if so *)
          if (chatCheck(entities.entityList[0].posX, entities.entityList[0].posY) =  True) then
          begin
            entities.entityList[0].posX := originalX;
            entities.entityList[0].posY := originalY;
          end;
// if it's not an npc, it must be a merchant
// initate barter screen

          
        Inc(entities.entityList[0].moveCount);
        (* check if tile is walkable *)
        if (map.canMove(entities.entityList[0].posX, entities.entityList[0].posY) = False) then
        begin
          entities.entityList[0].posX := originalX;
          entities.entityList[0].posY := originalY;
          (* display a clumsy message if player is intoxicated *)
          if (entityList[0].stsDrunk = True) then
            ui.displayMessage('You stagger into a wall');
          Dec(entities.entityList[0].moveCount);
        end;
        (* Occupy tile *)
        map.occupy(entityList[0].posX, entityList[0].posY); // trigger is here
        fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY, entities.entityList[0].visionRange, 1);
        ui.writeBufferedMessages;
    end
    else
      (* If the player is not in a village *)
      begin
      (* Check if player is frozen in place *)
      if (entityList[0].stsFrozen = False) then
      begin
        (* Unoccupy tile *)
        map.unoccupy(entityList[0].posX, entityList[0].posY);
        (* Repaint visited tiles *)
        fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 0);
        originalX := entities.entityList[0].posX;
        originalY := entities.entityList[0].posY;
        (* If the player is bewildered, move in a random direction *)
        if (entityList[0].stsBewild = True) then
        begin
          dir := randomRange(1,8);
        end;
        (* Else choose a direction *)
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
          9:
          begin
                                // Wait in place
          end;
        end;
        (* check if tile is occupied *)
        if (map.isOccupied(entities.entityList[0].posX, entities.entityList[0].posY) = True) then
          (* check if tile is occupied by hostile NPC *)
          if (combatCheck(entities.entityList[0].posX, entities.entityList[0].posY) =  True) then
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
        fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY, entities.entityList[0].visionRange, 1);
        ui.writeBufferedMessages;

        (* Regenerate Magick *)
        if (player_stats.playerRace <> 'Dwarf') then
          regenMagick;
    end
    { Display a message if the player is frozen }
    else
      begin
        ui.displayMessage('You are frozen in place, unable to move');
      end;  
  end;
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

  (* Bewildered *)
  if (entities.entityList[0].stsBewild = True) then
  begin
    if (ui.bewilderedStatusSet = False) then
    begin
      (* Update UI *)
      ui.displayStatusEffect(1, 'bewildered');
      ui.bewilderedStatusSet := True;
    end;
   if (entities.entityList[0].tmrBewild <= 0) then
    begin
      entities.entityList[0].tmrBewild := 0;
      entities.entityList[0].stsBewild := False;
      (* Update UI *)
      ui.displayStatusEffect(0, 'bewildered');
      ui.bewilderedStatusSet := False;
    end
   else
       Dec(entityList[0].tmrBewild);
  end;

  (* Frozen *)
  if (entities.entityList[0].stsFrozen = True) then
  begin
    if (ui.frozenStatusSet = False) then
    begin
      (* Update UI *)
      ui.displayStatusEffect(1, 'frozen');
      ui.frozenStatusSet := True;
    end;
   if (entities.entityList[0].tmrFrozen <= 0) then
    begin
      entities.entityList[0].tmrFrozen := 0;
      entities.entityList[0].stsFrozen := False;
      (* Update UI *)
      ui.displayStatusEffect(0, 'frozen');
      ui.frozenStatusSet := False;
    end
   else
       Dec(entityList[0].tmrFrozen);
  end;
end;

function combatCheck(x, y: smallint): boolean;
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

function chatCheck(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 1 to entities.npcAmount do
  begin
    if (x = entities.entityList[i].posX) then
    begin
      if (y = entities.entityList[i].posY) then
        begin
          { Check if the NPC is a villager or a merchant }
          if (entities.getCreatureName(x, y) = 'merchant') then
            ai_merchant.barter 
          else
            ai_villager.chat;
        end;
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

procedure topupHealth(amount: smallint);
begin
  if (entities.entityList[0].currentHP <> entities.entityList[0].maxHP) then
  begin
    if ((entities.entityList[0].currentHP + amount) >= entities.entityList[0].maxHP) then
      entities.entityList[0].currentHP := entities.entityList[0].maxHP
    else
      entities.entityList[0].currentHP := entities.entityList[0].currentHP + amount;
    ui.updateHealth;
  end
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
  (* Player cannot regenerate if they have certain status effects *)
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
