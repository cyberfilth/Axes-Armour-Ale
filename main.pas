(* Axes, Armour & Ale - Roguelike for Linux and Windows.
   @author (Chris Hawkins)
*)

unit main;

{$mode objfpc}{$H+}
{$IfOpt D+}
{$Define DEBUG}
{$EndIf}

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
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
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
  tempScreen, inventoryScreen, RIPscreen: TBitmap;
  (* 0 = titlescreen, 1 = game running, 2 = inventory screen, 3 = Quit menu, 4 = Game Over *)
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
  RIPscreen := TBitmap.Create;
  RIPscreen.Height := 578;
  RIPscreen.Width := 835;
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
  RIPscreen.Free;
  {$IFDEF Linux}
  WriteLn('Axes, Armour & Ale - (c) Chris Hawkins');
  {$ENDIF}
  Application.Terminate;
end;

procedure gameLoop;
var
  i: smallint;
begin
  if (entityList[0].currentHP <= 0) then
  begin
    player.gameOver;
    Exit;
  end;
  (* move NPC's *)
  entities.NPCgameLoop;
  (* Redraw Field of View after entities move *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
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
    begin
      items.itemList[i].inView := False;
      map.drawTile(itemList[i].posX, itemList[i].posY, 0);
    end;
  (* Redraw NPC's *)
  entities.redrawNPC;
  (* Update health display to show damage *)
  ui.updateHealth;
  if (entityList[0].currentHP <= 0) then
  begin
    player.gameOver;
    Exit;
  end;
  (* Clear Look / Info box *)
  ui.displayLook(1, 'none', '', 0, 0);
  (* Redraw Player *)
  drawToBuffer(map.mapToScreen(entities.entityList[0].posX),
    map.mapToScreen(entities.entityList[0].posY),
    entities.playerGlyph);
  (* Process status effects *)
  player.processStatus;
end;

procedure TGameWindow.FormKeyDown(Sender: TObject; var Key: word);
begin
  if (gameState = 1) then
  begin // beginning of game input
    case Key of
      VK_LEFT, VK_NUMPAD4, VK_H:
      begin
        player.movePlayer(2);
        gameLoop;
        Invalidate;
      end;
      VK_RIGHT, VK_NUMPAD6, VK_L:
      begin
        player.movePlayer(4);
        gameLoop;
        Invalidate;
      end;
      VK_UP, VK_NUMPAD8, VK_K:
      begin
        player.movePlayer(1);
        gameLoop;
        Invalidate;
      end;
      VK_DOWN, VK_NUMPAD2, VK_J:
      begin
        player.movePlayer(3);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD9, VK_U:
      begin
        player.movePlayer(5);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD3, VK_N:
      begin
        player.movePlayer(6);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD1, VK_B:
      begin
        player.movePlayer(7);
        gameLoop;
        Invalidate;
      end;
      VK_NUMPAD7, VK_Y:
      begin
        player.movePlayer(8);
        gameLoop;
        Invalidate;
      end;
      VK_G, VK_OEM_COMMA: // Get item
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
      VK_W: // Wear / Wield item
      begin
        currentScreen := inventoryScreen;
        gameState := 2;
        player_inventory.wield(10);
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
        player_inventory.menu(12);
        Invalidate;
      end;
      VK_W:  // Wear / Wield
      begin
        player_inventory.menu(13);
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
      end;
      VK_3:
      begin
        player_inventory.menu(5);
        Invalidate;
      end;
      VK_4:
      begin
        player_inventory.menu(6);
        Invalidate;
      end;
      VK_5:
      begin
        player_inventory.menu(7);
        Invalidate;
      end;
      VK_6:
      begin
        player_inventory.menu(8);
        Invalidate;
      end;
      VK_7:
      begin
        player_inventory.menu(9);
        Invalidate;
      end;
      VK_8:
      begin
        player_inventory.menu(10);
        Invalidate;
      end;
      VK_9:
      begin
        player_inventory.menu(11);
        Invalidate;
      end;
    end;  // end of inventory menu
  end
  else if (gameState = 3) then // Quit menu
  begin
    case Key of
      VK_Q:
      begin
        globalutils.saveGame;
        gameState := 0;
        freeMemory;
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
  end
  else if (gameState = 4) then // Game Over menu
  begin
    case Key of
      VK_Q:
      begin
        gameState := 0;
        freeMemory;
        Close();
      end;
      VK_X:
      begin
        freeMemory;
        gameState := 0;
        ui.clearLog;
        ui.titleScreen(0);
        currentScreen := tempScreen;
        Invalidate;
      end;
    end;
  end;
end;

(* Capture mouse position for the Look command *)
procedure TGameWindow.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if (X >= 1) and (X <= 686) and (Y >= 1) and (Y <= 400) then
  begin
    (* Check for entity *)
    if (map.isOccupied(map.screenToMap(x), map.screenToMap(y)) = True) then
    begin
      (* Add check if they are visible *)
      if (isCreatureVisible(screenToMap(x), screenToMap(y)) = True) then
      begin
        (* Send entity name, current HP and max HP to UI display *)
        ui.displayLook(1, getCreatureName(screenToMap(x), screenToMap(y)), '',
          getCreatureHP(screenToMap(x), screenToMap(y)),
          getCreatureMaxHP(screenToMap(x), screenToMap(y)));
        Invalidate;
      end;
    end
    (* Check for item *)
    else if (items.containsItem(map.screenToMap(x), map.screenToMap(y)) = True) then
    begin
      ui.displayLook(2, getItemName(map.screenToMap(x), map.screenToMap(y)),
        getItemDescription(map.screenToMap(x), map.screenToMap(y)), 0, 0);
      Invalidate;
    end
    else
    begin
      (* Clear UI display *)
      ui.displayLook(1, 'none', '', 0, 0);
      Invalidate;
    end;
  end;
end;

procedure TGameWindow.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0, 0, currentScreen);
end;


procedure TGameWindow.newGame;
begin
  {$IfDef DEBUG}
  {$IfDef Linux}
  writeln('Debugging info...');
  writeln('Random seed = ' + IntToStr(RandSeed));
  {$EndIf}
  {$EndIf}
  gameState := 1;
  killer := 'empty';
  playerTurn := 0;
  map.mapType := 0;// set to cavern
  map.setupMap;
  map.setupTiles;
  entities.setupEntities;
  items.setupItems;
  (* Clear the screen *)
  tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  tempScreen.Canvas.FillRect(0, 0, tempScreen.Width, tempScreen.Height);
  (* Spawn game entities *)
  entities.spawnNPCs;
  (* Drop items *)
  items.spawnItem;
  (* Draw sidepanel *)
  ui.drawSidepanel;
  (* Setup players starting equipment *)
  player.createEquipment;
  ui.displayMessage('Welcome message to be added here...');
  gameLoop;
  Canvas.Draw(0, 0, tempScreen);
end;

procedure TGameWindow.continueGame;
begin
  gameState := 1;
  globalutils.loadGame;
  killer := 'empty';
  (* Clear the screen *)
  tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  tempScreen.Canvas.FillRect(0, 0, tempScreen.Width, tempScreen.Height);
  map.setupTiles;
  map.loadMap;
  (* Add entities to the screen *)
  entities.setupEntities;
  entities.redrawNPC;
  (* Add items to the screen *)
  items.setupItems;
  items.redrawItems;
  (* Draw sidepanel *)
  ui.drawSidepanel;
  (* Check for equipped items *)
  player_inventory.loadEquippedItems;
  (* Setup player vision *)
  fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[0].visionRange, 1);
  ui.displayMessage('Welcome message to be added here...');
  gameLoop;
  Canvas.Draw(0, 0, tempScreen);
end;

procedure TGameWindow.confirmQuit;
begin
  ui.exitPrompt;
  Invalidate;
end;

procedure TGameWindow.freeMemory;
begin
  (* Map tiles *)
  map.caveFloorHi.Free;
  map.caveFloorDef.Free;
  map.caveWallHi.Free;
  map.caveWallDef.Free;
  map.blueDungeonFloorDef.Free;
  map.blueDungeonFloorHi.Free;
  map.blueDungeonWallDef.Free;
  map.blueDungeonWallHi.Free;
  (* Item sprites *)
  items.aleTankard.Free;
  items.crudeDagger.Free;
  items.leatherArmour1.Free;
  items.woodenClub.Free;
  (* Entity sprites *)
  entities.playerGlyph.Free;
  entities.caveRatGlyph.Free;
  entities.hyenaGlyph.Free;
  entities.caveBearGlyph.Free;
end;

end.
