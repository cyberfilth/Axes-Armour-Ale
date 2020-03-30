(* Axes, Armour & Ale - Roguelike for Linux and Windows.
   @author (Chris Hawkins)
*)

unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, ComCtrls, Graphics, SysUtils, map, player,
  globalutils, Controls, LCLType, ui, cave_rat;

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
  private

  public
  end;

var
  GameWindow: TGameWindow;
  (* Display is drawn on tempScreen before being copied to canvas *)
  tempScreen: TBitmap;
  (* 0 = titlescreen, 1 = game running *)
  gameState: byte;


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
    map.caveFloorHi.Free;
    map.caveFloorDef.Free;
    map.caveWallHi.Free;
    map.caveWallDef.Free;
    map.blueDungeonFloorDef.Free;
    map.blueDungeonFloorHi.Free;
    map.blueDungeonWallDef.Free;
    map.blueDungeonWallHi.Free;
    player.ThePlayer.glyph.Free;
  end;
  tempScreen.Free;
  {$IFDEF Linux}
  WriteLn('Axes, Armour & Ale - (c) Chris Hawkins');
  {$ENDIF}
  Application.Terminate;
end;

procedure gameLoop;
var
  i: smallint;
begin
  (* move NPC's *)
  for i := 1 to entities.npcAmount do
    if entities.entityList[i].isDead = False then
    begin
      cave_rat.takeTurn(i, entities.entityList[i].posX, entities.entityList[i].posY);
    end;
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
    end;
  end // end of game input
  else if (gameState = 0) then
  begin // beginning of Title menu
    case Key of
      VK_N: newGame;
      VK_L: continueGame;
      VK_Q: Close();   //Application.Terminate;
    end;
  end;
end;

procedure TGameWindow.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0, 0, tempScreen);
end;


procedure TGameWindow.newGame;
begin
  gameState := 1;
  map.setupMap;
  map.setupTiles;
  (* Clear the screen *)
  tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  tempScreen.Canvas.FillRect(0, 0, tempScreen.Width, tempScreen.Height);
  (* spawn player *)
  player.spawnPlayer(map.startX, map.startY);
  (* Spawn NPC's *)
  entities.spawnNPCs;
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
  drawToBuffer(map.mapToScreen(ThePlayer.posX), map.mapToScreen(ThePlayer.posY), ThePlayer.glyph);
  (* Add NPC's to the screen *)
  entities.redrawNPC;
  ui.displayMessage('Welcome message to be added here...');
  Canvas.Draw(0, 0, tempScreen);
end;

end.
