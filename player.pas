(* Player setup and stats *)
unit player;

{$mode objfpc}{$H+}

interface

uses
  Graphics;

type
  (* Store information about the player *)
  Creature = record
    currentHP, maxHP, attack, defense, posX, posY, visionRange: smallint;
    (* Player Glyph *)
    glyph: TBitmap;
  end;

var
  (* Player character *)
  ThePlayer: Creature;

(* Places the player on the map *)
procedure spawnPlayer(startX, startY: smallint);
(* Moves the player on the map *)
procedure movePlayer(dir: word);

implementation

uses
  globalutils, map, fov, ui;

procedure spawnPlayer(startX, startY: smallint);
begin
  (* Setup player stats *)
  with ThePlayer do
  begin
    currentHP := 20;
    maxHP := 20;
    attack := 5;
    defense := 2;
    posX := startX;
    posY := startY;
    visionRange:= 5;
    glyph := TBitmap.Create;
    glyph.LoadFromResourceName(HINSTANCE, 'PLAYER_GLYPH');
    fov.fieldOfView(ThePlayer.posX, ThePlayer.posY, ThePlayer.visionRange, 1);
    drawToBuffer(map.mapToScreen(ThePlayer.posX),
      map.mapToScreen(ThePlayer.posY), glyph);
  end;
end;

{ TODO -cMovement : Once combat is implemented, revisit the checks for occupying a square so NPC's cannot move to it }

(* Move the player within the confines of the game map *)
procedure movePlayer(dir: word);
begin
  (* Repaint visited tiles *)
  fov.fieldOfView(ThePlayer.posX, ThePlayer.posY, ThePlayer.visionRange, 0);
  case dir of
    1:
    begin
      if (map.canMove(ThePlayer.posX, ThePlayer.posY - 1) = True) then
      begin
        // increment moves counter
        Dec(ThePlayer.posY);
      end
      else
        ui.displayMessage('You bump into a wall');
    end;
    2:
    begin
      if (map.canMove(ThePlayer.posX - 1, ThePlayer.posY) = True) then
      begin
        // increment moves counter
        Dec(ThePlayer.posX);
      end
      else
        ui.displayMessage('You bump into a wall');
    end;
    3:
    begin
      if (map.canMove(ThePlayer.posX, ThePlayer.posY + 1) = True) then
      begin
        // increment moves counter
        Inc(ThePlayer.posY);
      end
      else
        ui.displayMessage('You bump into a wall');
    end;
    4:
    begin
      if (map.canMove(ThePlayer.posX + 1, ThePlayer.posY) = True) then
      begin
        // increment moves counter
        Inc(ThePlayer.posX);
      end
      else
        ui.displayMessage('You bump into a wall');
    end
    else
    // empty else clause
  end;
    fov.fieldOfView(ThePlayer.posX, ThePlayer.posY, ThePlayer.visionRange, 1);
  drawToBuffer(map.mapToScreen(ThePlayer.posX), map.mapToScreen(ThePlayer.posY),
    ThePlayer.glyph);

end;

end.
