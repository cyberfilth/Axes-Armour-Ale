(* Determines the terminal size when the game is first opened and resizes
   the user interface accordingly.
   For a typical 80x24 terminal size, the camera size will be 57x19
   For a terminal size of 102x24 and greater, the camera size will be 80x19
   This is kept to 19 rather than the full 20 to all for screenshake to
   be added in future versions.*)

unit resolution;

{$mode fpc}{$H+}

interface

uses
  crt, camera, scrGame, ui;

procedure getSize;

implementation

procedure getSize;
begin
  if (ScreenWidth >= 103) then
  begin
    scrGame.minX := 81;
    camera.camWidth := 80;
    ui.displayCol := 103;
    ui.displayRow := 25;
  end
  else
  begin
    scrGame.minX := 58;
    camera.camWidth := 57;
    ui.displayCol := 80;
    ui.displayRow := 25;
  end;
end;

end.

