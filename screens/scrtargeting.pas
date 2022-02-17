(* Screen used for Look and targeting *)

unit scrTargeting;

{$mode fpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, map, entities, video, ui, camera, fov;

var
  (* Target coordinates *)
  targetX, targetY: smallint;
  (* last safe coordinates *)
  safeX, safeY: smallint;       // initialise these

procedure look(dir: word);
procedure restorePlayerGlyph;

implementation

procedure look(dir: word);
var
  i: byte;
begin
  LockScreenUpdate;
  (* Turn player glyph to an X *)
  entityList[0].glyph := 'X';
  entityList[0].glyphColour := 'white';

  if (dir <> 0) then
  begin
    case dir of
      1: Dec(targetY); // N
      2: Dec(targetX); // W
      3: Inc(targetY); // S
      4: Inc(targetX); // E
    end;
    if (map.withinBounds(targetX, targetY) = False) or
      (map.maparea[targetY, targetX].Visible = False) then
    begin
      targetX := safeX;
      targetY := safeY;
    end;

    (* Redraw all NPC's *)
    for i := 1 to entities.npcAmount do
      entities.redrawMapDisplay(i);


    (* Redraw all items *)


    // Draw X on target
    map.mapDisplay[targetY, targetX].GlyphColour := 'white';
    map.mapDisplay[targetY, targetX].Glyph := 'X';

    if (map.isOccupied(targetX, targetY) = True) then
      ui.displayMessage('You see ' + entities.getCreatureName(targetX, targetY))
    else
      // display coords - for testing
      ui.displayMessage(IntToStr(targetX) + ', ' + IntToStr(targetY));
  end;

  (* Repaint map *)
  camera.drawMap;
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);

  UnlockScreenUpdate;
  UpdateScreen(False);
  (* Store the coordinates, so the cursor doesn't get lost off screen *)
  safeX := targetX;
  safeY := targetY;
end;

procedure restorePlayerGlyph;
begin
  entityList[0].glyph := '@';
  if (entityList[0].stsPoison = True) then
    entityList[0].glyphColour := 'green'
  else
    entityList[0].glyphColour := 'yellow';
end;

end.
