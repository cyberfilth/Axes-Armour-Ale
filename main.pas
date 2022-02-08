(* Axes, Armour & Ale - A low-fantasy roguelike.
   @author (Chris Hawkins)
*)

unit main;

{$mode objfpc}{$H+}
{$IFOPT D+} {$DEFINE DEBUG} {$ENDIF}

interface

uses
  SysUtils, Video, keyboard, KeyboardInput, ui, camera, map, scrGame, globalUtils,
  universe, fov, scrRIP, plot_gen, file_handling, smell, scrTitle, scrWinAlpha,
  dlgInfo
  {$IFDEF DEBUG}, logging{$ENDIF};

(* Finite State Machine game states *)
type
  gameStatus = (stTitle, stIntro, stGame, stInventory, stDropMenu, stQuaffMenu,
    stWearWield, stQuitMenu, stGameOver, stDialogLevel, stAnim, stLoseSave,
    stCharSelect, stCharIntro, stDialogBox, stWinAlpha);

var
  (* State machine for game menus / controls *)
  gameState: gameStatus;
  (* Used for title menu, TRUE if there is a save file *)
  saveExists: boolean;

procedure setSeed;
procedure initialise;
procedure exitApplication;
procedure exitToTitleMenu;
procedure newGame;
procedure continue;
procedure loop;
procedure gameLoop;
procedure returnToGameScreen;
procedure gameOver;
procedure WinningScreen;

implementation

uses
  entities, items, player, player_inventory, player_stats;

procedure setSeed;
begin
  {$IFDEF Linux}
  RandSeed := RandSeed shl 8;
  {$ENDIF}
  {$IFDEF Windows}
  RandSeed := ((RandSeed shl 8) or GetProcessID);
  {$ENDIF}
  {$IFDEF Darwin}
  RandSeed := RandSeed shl 8;
  {$ENDIF}
end;

procedure initialise;
begin
  (* Set save directory *)
  {$IFDEF Linux}
  globalutils.saveDirectory := getUserDir + '.axesData';
  {$ENDIF}
  {$IFDEF Darwin}
  globalutils.saveDirectory := getUserDir + '.axesData';
  {$ENDIF}
  {$IFDEF Windows}
  globalutils.saveDirectory := getUserDir + 'axesData';
  {$ENDIF}
  gameState := stTitle;
  Randomize;
  { Check if seed set as command line parameter }
  if (ParamCount = 2) then
  begin
    if (ParamStr(1) = '--seed') then
      RandSeed := StrToDWord(ParamStr(2))
    else
    begin
      { Set random seed if not specified }
      setSeed;
    end;
  end
  else
    setSeed;
  {$IFDEF DEBUG}
  logging.beginLogging;
  {$ENDIF}

  (* Check for previous save file *)
  if (FileExists(globalUtils.saveDirectory + DirectorySeparator +
    globalutils.saveFile)) then
  begin
    saveExists := True;
    { Initialise video unit and show title screen }
    ui.setupScreen(1);
  end
  else
  begin
    try
      { create directory }
      CreateDir(globalUtils.saveDirectory);
    finally
      { Initialise video unit and show title screen }
      ui.setupScreen(0);
    end;
  end;
  { Initialise keyboard unit }
  keyboardinput.setupKeyboard;

  (* Set a Dwarven clan name *)
  plot_gen.generateClanName;
end;

procedure exitApplication;
begin
  (* Don't attempt to save game from Title screen *)
  if (gameState <> stTitle) then
  begin
    if (gameState <> stGameOver) then
    begin
      file_handling.saveGame;
      (* Clear arrays *)
      entityList := nil;
      itemList := nil;
    end;
  end;
  gameState := stGameOver;
  { Shutdown keyboard unit }
  keyboardinput.shutdownKeyboard;
  { Shutdown video unit }
  ui.shutdownScreen;
  (* Clear screen and display author message *)
  ui.exitMessage;
  halt;
end;

procedure exitToTitleMenu;
begin
  (* Don't attempt to save game from Title screen *)
  if (gameState <> stTitle) then
  begin
    if (gameState <> stGameOver) then
    begin
      file_handling.saveGame;
      (* Clear arrays *)
      entityList := nil;
      itemList := nil;
    end;
  end;
  gameState := stTitle;
  ClearScreen;
  (* Clear the message array *)
  ui.messageArray[1] := ' ';
  ui.messageArray[2] := ' ';
  ui.messageArray[3] := ' ';
  ui.messageArray[4] := ' ';
  ui.messageArray[5] := ' ';
  ui.messageArray[6] := ' ';
  ui.messageArray[7] := ' ';
  (* prepare changes to the screen *)
  LockScreenUpdate;
  (* Check for previous save file *)
  if (FileExists(globalUtils.saveDirectory + DirectorySeparator +
    globalutils.saveFile)) then
  begin
    saveExists := True;
    scrtitle.displayTitleScreen(1);
  end
  else
  begin
    try
      { create directory }
      CreateDir(globalUtils.saveDirectory);
    finally
      { Initialise video unit and show title screen }
      scrtitle.displayTitleScreen(0);
    end;
  end;
  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

procedure newGame;
var
  i: byte;
begin
  (* Game state = game running *)
  gameState := stGame;
  dlgInfo.dialogType := dlgNone;
  killer := 'empty';
  (* Initialise the game world and create 1st cave *)
  universe.dlistLength := 0;
  (* first map type is always a cave *)
  map.mapType := universe.tCave;
  (* Create the dungeon *)
  universe.createNewDungeon(map.mapType);
  (* Set smell counter to zero *)
  smell.smellCounter := 0;
  (* Create the Player *)
  entities.spawnPlayer;
  (* Set player stats *)
  player_stats.playerLevel := 1;
  player_stats.enchantedWeaponEquipped := False;
  player_stats.enchWeapType := 0;
  (* Spawn game entities *)
  universe.spawnDenizens;
  (* Initialise items list *)
  items.initialiseItems;
  (* Start dropping items on map *)
  universe.litterItems;

  { prepare changes to the screen }
  LockScreenUpdate;
  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrGame.displayGameScreen;
  (* Place the NPC's *)
  entities.NPCgameLoop;
  (* Redraw all items *)
  for i := 1 to items.itemAmount do
    if (map.canSee(items.itemList[i].posX, items.itemList[i].posY) = True) then
    begin
      items.itemList[i].inView := True;
      items.drawItemsOnMap(i);
      (* Display a message if this is the first time seeing this item *)
      if (items.itemList[i].discovered = False) then
      begin
        ui.displayMessage('You see ' + items.itemList[i].itemArticle + ' ' + items.itemList[i].itemName);
        items.itemList[i].discovered := True;
      end;
    end
    else
    begin
      items.itemList[i].inView := False;
      map.drawTile(itemList[i].posX, itemList[i].posY, 0);
    end;

  (* draw map through the camera *)
  camera.drawMap;

  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);

  (* Generate the welcome message *)
  ui.welcome;

  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure continue;
var
  i: byte;
begin
  (* Initialise items list *)
  items.initialiseItems;
  file_handling.loadGame;
  file_handling.loadDungeonLevel(universe.currentDepth);
  map.loadDisplayedMap;
  (* Game state = game running *)
  gameState := stGame;
  killer := 'empty';
  (* set up inventory *)
  ui.equippedWeapon := 'No weapon equipped';
  ui.equippedArmour := 'No armour worn';
  (* Load player inventory *)
  player_inventory.loadEquippedItems;

  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);

  (* Redraw all items *)
  items.redrawItems;

  (* Redraw all NPC'S *)
  for i := 1 to entities.npcAmount do
    entities.redrawMapDisplay(i);

  { prepare changes to the screen }
  LockScreenUpdate;
  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrGame.displayGameScreen;
  (* draw map through the camera *)
  camera.drawMap;
  (* Generate the welcome message *)
  plot_gen.getTrollDate;
  ui.displayMessage('Good Luck...');
  ui.displayMessage('You are in the ' + UTF8Encode(universe.title));
  ui.displayMessage('It is ' + plot_gen.trollDate);
  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

(* Take input from player for the KeyboardInput unit, based on current game state *)
procedure loop;
var
  Keypress: TKeyEvent;
begin
  while True do
  begin
    Keypress := GetKeyEvent;
    Keypress := TranslateKeyEvent(Keypress);
    case gameState of
      { ----------------------------------   Title menu }
      stTitle: titleInput(Keypress);
      { ----------------------------------   Character select screen }
      stCharSelect: charSelInput(Keypress);
      { ----------------------------------   Intro screen }
      stIntro: introInput(Keypress);
      { ----------------------------------   Character Intro screen }
      stCharIntro: charIntroInput(Keypress);
      { -----------------------------------  Game Over screen }
      stGameOver: RIPInput(Keypress);
      { ----------------------------------   Prompt to quit game }
      stQuitMenu: quitInput(Keypress);
      { ---------------------------------    In the Inventory menu }
      stInventory: inventoryInput(Keypress);
      { ---------------------------------    In the Drop item menu }
      stDropMenu: dropInput(Keypress);
      { ---------------------------------    In the Quaff menu }
      stQuaffMenu: quaffInput(Keypress);
      { ---------------------------------    In the Wear / Wield menu }
      stWearWield: wearWieldInput(Keypress);
      { ---------------------------------    In the Level Up menu }
      stDialogLevel: LevelUpInput(Keypress);
      { ---------------------------------    In the Dialog pop-up }
      stDialogBox: dialogBoxInput(Keypress);
      { ---------------------------------    Gameplay controls }
      stGame: gameInput(Keypress);
      { ---------------------------------    Confirm overwrite game }
      stLoseSave: LoseSaveInput(Keypress);
      { ---------------------------------    Winning Alpha version of game }
      stWinAlpha: WinAlphaInput(Keypress);
    end;
  end;
end;

procedure gameLoop;
var
  i: byte;
begin
  (* Check for player death at start of game loop *)
  if (entityList[0].currentHP <= 0) then
  begin
    gameState := stGameOver;
    gameOver;
  end;

  (* ALPHA VERSION ONLY - Check if player has won *)
  if (gameState = stWinAlpha) then
    Exit;

  (* move NPC's *)
  entities.NPCgameLoop;
  (* Process status effects *)
  player.processStatus;
  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  (* Redraw all items *)
  items.redrawItems;
  (* Redraw all NPC'S *)
  for i := 1 to entities.npcAmount do
    entities.redrawMapDisplay(i);
  { prepare changes to the screen }
  LockScreenUpdate;

  (* BEGIN DRAWING TO THE BUFFER *)

  entities.occupyUpdate;
  (* Update health display to show damage *)
  ui.updateHealth;
  (* Update magick display *)
  if (player_stats.playerRace <> 'Dwarf') then
    ui.updateMagick;
  (* Reduce smell counter *)
  if (smell.smellCounter > 0) then
    Dec(smell.smellCounter);
  (* draw map through the camera *)
  camera.drawMap;

  (* FINISH DRAWING TO THE BUFFER *)

  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
  (* Check for player death at end of game loop *)
  if (entityList[0].currentHP <= 0) then
  begin
    gameState := stGameOver;
    gameOver;
  end;
  (* Check if the player has levelled up *)
  player_stats.checkLevel;
  (* Process any dialog pop-ups *)
  dlgInfo.checkNotifications;
end;

procedure returnToGameScreen;
var
  i: byte;
begin
  { prepare changes to the screen }
  LockScreenUpdate;
  (* BEGIN DRAWING TO THE BUFFER *)

  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrGame.displayGameScreen;
  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  (* Redraw all NPC'S *)
  for i := 1 to entities.npcAmount do
    entities.redrawMapDisplay(i);
  (* Redraw all items *)
  for i := 1 to items.itemAmount do
    if (map.canSee(items.itemList[i].posX, items.itemList[i].posY) = True) then
    begin
      items.itemList[i].inView := True;
      items.drawItemsOnMap(i);
      (* Display a message if this is the first time seeing this item *)
      if (items.itemList[i].discovered = False) then
      begin
        ui.displayMessage('You see ' + items.itemList[i].itemArticle + ' ' + items.itemList[i].itemName);
        items.itemList[i].discovered := True;
      end;
    end
    else
    begin
      items.itemList[i].inView := False;
      map.drawTile(itemList[i].posX, itemList[i].posY, 0);
    end;
  (* draw map through the camera *)
  camera.drawMap;
  entities.occupyUpdate;
  (* Update health display to show damage *)
  ui.updateHealth;
  (* draw map through the camera *)
  camera.drawMap;
  (* Redraw message log *)
  ui.restoreMessages;
  ui.writeBufferedMessages;

  (* FINISH DRAWING TO THE BUFFER *)

  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure gameOver;
begin
  scrRIP.displayRIPscreen;
end;

procedure WinningScreen;
begin
  gameState := stWinAlpha;
  scrWinAlpha.displayWinscreen;
end;

end.
