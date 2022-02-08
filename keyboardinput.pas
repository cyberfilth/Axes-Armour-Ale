(* Player input for game controls and menu selections, grouped in procedures *)

unit KeyboardInput;

{$mode fpc}{$H+}

interface

uses
  Keyboard, map, dlgInfo, scrIntro, scrCharSelect, scrCharIntro;

(* Initialise keyboard unit *)
procedure setupKeyboard;
(* Shutdown keyboard unit *)
procedure shutdownKeyboard;
(* Input in TITLE Menu state *)
procedure titleInput(Keypress: TKeyEvent);
(* Input in the CHARACTER SELECT state *)
procedure charSelInput(Keypress: TKeyEvent);
(* Input in the CHARACTER INTRO Menu state *)
procedure charIntroInput(Keypress: TKeyEvent);
(* Input in the INTRO Menu state *)
procedure introInput(Keypress: TKeyEvent);
(* Input for QUIT Menu state *)
procedure quitInput(Keypress: TKeyEvent);
(* Input in INVENTORY Menu state *)
procedure inventoryInput(Keypress: TKeyEvent);
(* Input in the DROP Menu state *)
procedure dropInput(Keypress: TKeyEvent);
(* Input in the QUAFF Menu state *)
procedure quaffInput(Keypress: TKeyEvent);
(* Input in the WEAR / WIELD Menu state *)
procedure wearWieldInput(Keypress: TKeyEvent);
(* Input in the GAME OVER state *)
procedure RIPInput(Keypress: TKeyEvent);
(* Input in the LEVEL UP state *)
procedure LevelUpInput(Keypress: TKeyEvent);
(* Input in GAME state *)
procedure gameInput(Keypress: TKeyEvent);
(* Input in LOSE SAVE state *)
procedure LoseSaveInput(Keypress: TKeyEvent);
(* Input in the DIALOG state *)
procedure dialogBoxInput(Keypress: TKeyEvent);
(* Input in WIN ALPHA state *)
procedure WinAlphaInput(Keypress: TKeyEvent);

implementation

uses
  main, ui, player, player_inventory, player_stats;

procedure setupKeyboard;
begin
  InitKeyboard;
end;

procedure shutdownKeyboard;
begin
  DoneKeyBoard;
end;

procedure titleInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'n':
    begin
      (* Check to see if there's an existing save *)
      if (main.saveExists = True) then
      begin
        gameState := stLoseSave;
        dlgInfo.newWarning;
      end
      else
      begin
        (* Game state = Character Select screen *)
        gameState := stCharSelect;
        scrCharSelect.choose;
      end;
    end;
    'l': { Load previously saved game }
    begin
      if (main.saveExists = True) then
        main.continue;
    end;
    'q': main.exitApplication;
  end;
end;

procedure charSelInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'a', 'A': { Dwarf }
    begin
      scrCharSelect.displayDwarf;
    end;
    'b', 'B': { Elf }
    begin
      scrCharSelect.displayElf;
    end;
    'c', 'C': { Human }
    begin
      scrCharSelect.displayHuman;
    end;
    #32: { Space key - Confirm selection }
    begin
      gameState := stCharIntro;
      scrCharIntro.setTheScene; { Go to Character Intro screen }
    end;
  end;
end;

procedure charIntroInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    #32: { Space key }
    begin
      gameState := stIntro; { Continue }
      scrIntro.displayIntroScreen;
    end;
    's', 'S': { Skip intro }
    begin
      main.newGame;
    end;
  end;
end;

procedure introInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    #32: { Space key }
    begin
      main.newGame; { Start a new game }
    end;
  end;
end;

procedure quitInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'q', 'Q': { Save and Quit }
    begin
      main.exitApplication;
    end;
    'x', 'X': { Exit to main menu }
    begin
      main.exitToTitleMenu;
    end;
    #27: { Escape key - Cancel }
    begin
      gameState := stGame;
      main.returnToGameScreen;
    end;
  end;
end;

procedure inventoryInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'D': { Drop menu }
    begin
      gameState := stDropMenu;
      player_inventory.drop;
    end;
    'Q': { Quaff menu }
    begin
      gameState := stQuaffMenu;
      player_inventory.quaff;
    end;
    'W': { Wear / Wield menu }
    begin
      gameState := stWearWield;
      player_inventory.wield('n');
    end;
    'x', 'X': { Exit menu }
    begin
      gameState := stGame;
      main.returnToGameScreen;
    end;
    { List of inventory slots }
    'a': player_inventory.examineInventory(0);
    'b': player_inventory.examineInventory(1);
    'c': player_inventory.examineInventory(2);
    'd': player_inventory.examineInventory(3);
    'e': player_inventory.examineInventory(4);
    'f': player_inventory.examineInventory(5);
    'g': player_inventory.examineInventory(6);
    'h': player_inventory.examineInventory(7);
    'i': player_inventory.examineInventory(8);
    'j': player_inventory.examineInventory(9);
  end;
end;

procedure dropInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'x', 'X': { Exit menu }
    begin
      gameState := stGame;
      main.returnToGameScreen;
    end;
    'I': { Inventory menu }
    begin
      gameState := stInventory;
      player_inventory.showInventory;
    end;
    'Q': { Quaff menu }
    begin
      gameState := stQuaffMenu;
      player_inventory.quaff;
    end;
    'W': { Wear / Wield menu }
    begin
      gameState := stWearWield;
      player_inventory.wield('n');
    end;
    { List of inventory slots }
    'a': player_inventory.dropSelection(0);
    'b': player_inventory.dropSelection(1);
    'c': player_inventory.dropSelection(2);
    'd': player_inventory.dropSelection(3);
    'e': player_inventory.dropSelection(4);
    'f': player_inventory.dropSelection(5);
    'g': player_inventory.dropSelection(6);
    'h': player_inventory.dropSelection(7);
    'i': player_inventory.dropSelection(8);
    'j': player_inventory.dropSelection(9);
  end;
end;

procedure quaffInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'x', 'X': { Exit menu }
    begin
      gameState := stGame;
      main.returnToGameScreen;
    end;
    'I': { Inventory menu }
    begin
      gameState := stInventory;
      player_inventory.showInventory;
    end;
    'D': { Drop menu }
    begin
      gameState := stDropMenu;
      player_inventory.drop;
    end;
    'W': { Wear / Wield menu }
    begin
      gameState := stWearWield;
      player_inventory.wield('n');
    end;
    { List of inventory slots }
    'a': player_inventory.quaffSelection(0);
    'b': player_inventory.quaffSelection(1);
    'c': player_inventory.quaffSelection(2);
    'd': player_inventory.quaffSelection(3);
    'e': player_inventory.quaffSelection(4);
    'f': player_inventory.quaffSelection(5);
    'g': player_inventory.quaffSelection(6);
    'h': player_inventory.quaffSelection(7);
    'i': player_inventory.quaffSelection(8);
    'j': player_inventory.quaffSelection(9);
  end;
end;

procedure wearWieldInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'x', 'X': { Exit menu }
    begin
      gameState := stGame;
      main.returnToGameScreen;
    end;
    'I': { Inventory menu }
    begin
      gameState := stInventory;
      player_inventory.showInventory;
    end;
    'D': { Drop menu }
    begin
      gameState := stDropMenu;
      player_inventory.drop;
    end;
    'Q': { Quaff menu }
    begin
      gameState := stQuaffMenu;
      player_inventory.quaff;
    end;
    { List of inventory slots }
    'a': player_inventory.wearWieldSelection(0);
    'b': player_inventory.wearWieldSelection(1);
    'c': player_inventory.wearWieldSelection(2);
    'd': player_inventory.wearWieldSelection(3);
    'e': player_inventory.wearWieldSelection(4);
    'f': player_inventory.wearWieldSelection(5);
    'g': player_inventory.wearWieldSelection(6);
    'h': player_inventory.wearWieldSelection(7);
    'i': player_inventory.wearWieldSelection(8);
    'j': player_inventory.wearWieldSelection(9);
  end;
end;

procedure RIPInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'x', 'X': { Exit to menu }
    begin
      main.exitToTitleMenu;
    end;
    'q', 'Q': { Quit game }
    begin
      main.exitApplication;
    end;
  end;
end;

procedure LevelUpInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'a', 'A': { Increase max health }
    begin
      player_stats.increaseMaxHealth;
      ui.displayMessage('You find you can see further.');
      main.gameState := stGame;
      main.returnToGameScreen;
    end;
    'b', 'B': { Increase attack strength }
    begin
      player_stats.increaseAttack;
      ui.displayMessage('You find you can see further.');
      main.gameState := stGame;
      main.returnToGameScreen;
    end;
    'c', 'C': { Increase defence strength }
    begin
      player_stats.increaseDefence;
      ui.displayMessage('You find you can see further.');
      main.gameState := stGame;
      main.returnToGameScreen;
    end;
    'd', 'D': { Increase attack & defence strength }
    begin
      player_stats.increaseAttackDefence;
      ui.displayMessage('You find you can see further.');
      main.gameState := stGame;
      main.returnToGameScreen;
    end;
  end;
end;

procedure gameInput(Keypress: TKeyEvent);
begin
  { Arrow keys }
  case GetKeyEventCode(Keypress) of
    kbdLeft:
    begin
      player.movePlayer(2);
      main.gameLoop;
    end;
    kbdRight:
    begin
      player.movePlayer(4);
      main.gameLoop;
    end;
    kbdUp:
    begin
      player.movePlayer(1);
      main.gameLoop;
    end;
    KbdDown:
    begin
      player.movePlayer(3);
      main.gameLoop;
    end;
  end;
  { Numpad and VI keys }
  case GetKeyEventChar(Keypress) of
    '8', 'k', 'K': { N }
    begin
      player.movePlayer(1);
      main.gameLoop;
    end;
    '9', 'u', 'U': { NE }
    begin
      player.movePlayer(5);
      main.gameLoop;
    end;
    '6', 'l', 'L': { E }
    begin
      player.movePlayer(4);
      main.gameLoop;
    end;
    '3', 'n', 'N': { SE }
    begin
      player.movePlayer(6);
      main.gameLoop;
    end;
    '2', 'j', 'J': { S }
    begin
      player.movePlayer(3);
      main.gameLoop;
    end;
    '1', 'b', 'B': { SW }
    begin
      player.movePlayer(7);
      main.gameLoop;
    end;
    '4', 'h', 'H': { W }
    begin
      player.movePlayer(2);
      main.gameLoop;
    end;
    '7', 'y', 'Y': { NW }
    begin
      player.movePlayer(8);
      main.gameLoop;
    end;
    '<': { Go up the stairs }
    begin
      map.ascendStairs;
      main.gameLoop;
    end;
    '>': { Go down the stairs }
    begin
      map.descendStairs;
      main.gameLoop;
    end;
    'z', 'Z': {Zap magic }
    begin
      player_inventory.Zzap(player_stats.enchWeapType);
      main.gameLoop;
    end;
    'i', 'I': { Inventory }
    begin
      main.gameState := stInventory;
      player_inventory.showInventory;
    end;
    'd', 'D': { Drop menu }
    begin
      main.gameState := stDropMenu;
      player_inventory.drop;
    end;
    'q', 'Q': { Quaff menu }
    begin
      main.gameState := stQuaffMenu;
      player_inventory.quaff;
    end;
    'w', 'W': { Wear / Wield menu }
    begin
      gameState := stWearWield;
      player_inventory.wield('n');
    end;
    ',', 'g', 'G': { Get item }
    begin
      player.pickUp;
      main.gameLoop;
    end;
    #27: { Escape key - Quit }
    begin
      gameState := stQuitMenu;
      ui.exitPrompt;
    end;
  end;
end;

procedure LoseSaveInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'y', 'Y': { Start new game }
    begin
      gameState := stCharSelect;
      scrCharSelect.choose;
    end;
    'n', 'N': { Return to title menu }
    begin
      gameState := stTitle;
      main.exitToTitleMenu;
    end;
  end;
end;

procedure dialogBoxInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'x', 'X': { Exit dialog box }
    begin
      { Clear the box }
      main.gameState := stGame;
      { Redraw the map }
      ui.clearPopup;
    end;
  end;
end;

procedure WinAlphaInput(Keypress: TKeyEvent);
begin
  case GetKeyEventChar(Keypress) of
    'q', 'Q': { Quit the game }
    begin
      main.exitApplication;
    end;
  end;
end;

end.
