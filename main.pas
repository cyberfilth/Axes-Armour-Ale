(* Axes, Armour & Ale - Roguelike for Linux and Windows.
   @author (Chris Hawkins)
*)

unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, ComCtrls, Graphics, SysUtils, map, player,
  globalutils, Controls, LCLType, ui, items, player_inventory;

type

  { TGameWindow }

  TGameWindow = class(TForm)
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word);
    procedure FormPaint(Sender: TObject);
    (* New game setup *)
    procedure newGame;
    (* Continue previous saved game *)
    procedure continueGame;
    (* Confirm quit game *)
    procedure confirmQuit;
    (* Free memory *)
    procedure freeMemory;
  private

  public
  end;

var
  GameWindow: TGameWindow;
  (* Display is drawn on tempScreen before being copied to canvas *)
  tempScreen, inventoryScreen: TBitmap;
  (* 0 = titlescreen, 1 = game running, 2 = inventory screen, 3 = Quit menu *)
  gameState: byte;
  (* Screen to display *)
  currentScreen: TBitmap;

implementation

uses
  entities, fov;

{$R *.lfm}

{ TGameWindow }

procedure TGameWindow.FormCreate(Sender: TObject);
begin
  gameState := 0;
  tempScreen := TBitmap.Create;
  tempScreen.Height := 578;
  tempScreen.Width := 835;
  inventoryScreen := TBitmap.Create;
  inventoryScreen.Height := 578;
  inventoryScreen.Width := 835;
  currentScreen := tempScreen;
  Randomize;
  (* Set random seed *)
  {$IFDEF Linux}
  RandSeed := RandSeed shl 8;
  {$ENDIF}
  {$IFDEF Windows}
  RandSeed := ((RandSeed shl 8) or GetProcessID);
  {$ENDIF}
  StatusBar1.SimpleText := 'Version ' + globalutils.VERSION;
  (* Check for previous save file *)
  if FileExists(GetUserDir + globalutils.saveFile) then
    ui.titleScreen(1)
  else
    ui.titleScreen(0);
end;


procedure TGameWindow.FormDestroy(Sender: TObject);
begin
  (* Don't try to save game from title screen *)
  if (gameState = 1) then
  begin
    globalutils.saveGame;
    freeMemory;
  end;
  tempScreen.Free;
  inventoryScreen.Free;
  {$IFDEF Linux}
  WriteLn('Axes, Armour & Ale - (c) Chris Hawkins');
  {$ENDIF}
  Application.Terminate;
end;

procedure gameLoop;
var
  i: smallint;
begin
  (* Draw all visible items *)
  for i := 1 to items.itemAmount do
    if (map.canSee(items.itemList[i].posX, items.itemList[i].posY) = True) then
    begin
      items.itemList[i].inView := True;
      items.redrawItems;
      (* Display a message if this is the first time seeing this item *)
      if (items.itemList[i].discovered = False) then
      begin
        ui.displayMessage('You see a ' + items.itemList[i].itemName);
        items.itemList[i].discovered := True;
      end;
    end
    else
      items.itemList[i].inView := False;
  (* move NPC's *)
  entities.NPCgameLoop;
  entities.redrawNPC;
  (* Redraw Player *)
  drawToBuffer(map.mapToScreen(ThePlayer.posX), map.mapToScreen(ThePlayer.posY),
    ThePlayer.glyph);
  (* Process status effects *)
  player.processStatus;
end;

procedure TGameWindow.FormKeyDown(Sender: TObject; var Key: word);
begin
  if (gameState = 1) then
  begin // beginning of game input
    case Key of
      VK_LEFT, VK_NUMPAD4:
      begin
        player.movePlayer(2);
        gameLoop;
        Invalidate;
      end;
      VK_RIGHT, VK_NUMPAD6:
      begin
        player.movePlayer(4);
        gameLoop;
        Invalidate;
      end;
      VK_UP, VK_NUMPAD8:
      begin
        player.movePlayer(1);
        gameLoop;
        Invalidate;
      end;
      VK_DOWN, VK_NUMPAD2:
      begin
        player.movePlayer(3);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD9:
      begin
        player.movePlayer(5);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD3:
      begin
        player.movePlayer(6);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD1:
      begin
        player.movePlayer(7);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD7:
      begin
        player.movePlayer(8);
        gameLoop;
        Invalidate;
      end;
      VK_G: // Get item
      begin
        player.pickUp;
        gameLoop;
        Invalidate;
      end;
      VK_D: // Drop item
      begin
        currentScreen := inventoryScreen;
        gameState := 2;
        player_inventory.drop(10);
        Invalidate;
      end;
      VK_Q: // Quaff item
      begin
        currentScreen := inventoryScreen;
        gameState := 2;
        player_inventory.quaff(10);
        Invalidate;
      end;
      VK_I: // Show inventory
      begin
        player_inventory.showInventory;
        Invalidate;
      end;
      VK_ESCAPE: // Quit game
      begin
        gameState := 3;
        confirmQuit;
      end;
    end;
  end // end of game input
  else if (gameState = 0) then
  begin // beginning of Title menu
    case Key of
      VK_N: newGame;
      VK_L: continueGame;
      VK_Q: Close();
    end; // end of title menu screen
  end
  else if (gameState = 2) then
  begin // beginning of inventory menu
    case Key of
      VK_ESCAPE:  // Exit
      begin
        player_inventory.menu(0);
        Invalidate;
      end;
      VK_D:  // Drop
      begin
        player_inventory.menu(1);
        Invalidate;
      end;
      VK_Q:  // Quaff
      begin
        player_inventory.menu(5);
        { TODO : Renumber the menu options once all slots are added }
        Invalidate;
      end;
      VK_0:
      begin
        player_inventory.menu(2);
        Invalidate;
      end;
      VK_1:
      begin
        player_inventory.menu(3);
        Invalidate;
      end;
      VK_2:
      begin
        player_inventory.menu(4);
        Invalidate;
      end;   { TODO : First 3 inventory added for testing, rest to be added later }
    end;  // end of inventory menu
  end
  else if (gameState = 3) then // Quit menu
  begin
    case Key of
      VK_Q:
      begin
        gameState := 1;
        Close();
      end;
      VK_X:
      begin
        freeMemory;
        globalutils.saveGame;
        gameState := 0;
        ui.clearLog;
        ui.titleScreen(1);
        Invalidate;
      end;
      VK_ESCAPE:
      begin
        gameState := 1;
        ui.rewriteTopMessage;
        Invalidate;
      end;
    end;
  end;
end;

procedure TGameWindow.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0, 0, currentScreen);
end;


procedure TGameWindow.newGame;
begin
  gameState := 1;
  playerTurn := 0;
  map.mapType := 0;// set to cavern
  map.setupMap;
  map.setupTiles;
  entities.setupEntities;
  items.setupItems;
  (* Clear the screen *)
  tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  tempScreen.Canvas.FillRect(0, 0, tempScreen.Width, tempScreen.Height);
  (* spawn player *)
  player.spawnPlayer(map.startX, map.startY);
  (* Spawn NPC's *)
  entities.spawnNPCs;
  (* Drop items *)
  items.spawnItem;
  (* Draw sidepanel *)
  ui.drawSidepanel;
  ui.displayMessage('Welcome message to be added here...');
  Canvas.Draw(0, 0, tempScreen);
end;

procedure TGameWindow.continueGame;
begin
  gameState := 1;
  globalutils.loadGame;
  (* Clear the screen *)
  tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  tempScreen.Canvas.FillRect(0, 0, tempScreen.Width, tempScreen.Height);
  map.setupTiles;
  map.loadMap;
  (* Draw sidepanel *)
  ui.drawSidepanel;
  (* Setup player *)
  with player.ThePlayer do
  begin
    glyph := TBitmap.Create;
    glyph.LoadFromResourceName(HINSTANCE, 'PLAYER_GLYPH');
  end;
  fov.fieldOfView(player.ThePlayer.posX, player.ThePlayer.posY,
    player.ThePlayer.visionRange, 1);
  drawToBuffer(map.mapToScreen(ThePlayer.posX), map.mapToScreen(ThePlayer.posY),
    ThePlayer.glyph);
  (* Add NPC's to the screen *)
  entities.setupEntities;
  entities.redrawNPC;
  ui.displayMessage('Welcome message to be added here...');
  Canvas.Draw(0, 0, tempScreen);
end;

procedure TGameWindow.confirmQuit;
begin
  ui.exitPrompt;
  Invalidate;
end;

procedure TGameWindow.freeMemory;
begin
  map.caveFloorHi.Free;
  map.caveFloorDef.Free;
  map.caveWallHi.Free;
  map.caveWallDef.Free;
  map.blueDungeonFloorDef.Free;
  map.blueDungeonFloorHi.Free;
  map.blueDungeonWallDef.Free;
  map.blueDungeonWallHi.Free;
  items.aleTankard.Free;
  entities.caveRatGlyph.Free;
  entities.hyenaGlyph.Free;
  player.ThePlayer.glyph.Free;
end;

end.
