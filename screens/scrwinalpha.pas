(* Game won screen - only used for Alpha testing *)

unit scrWinAlpha;

{$mode fpc}{$H+}

interface

uses
  SysUtils, video, file_handling, ui;

(* Show the Win screen *)
procedure displayWinscreen;

implementation

procedure displayWinscreen;
begin
  { Closing screen update as it is currently in the main game loop }
  UnlockScreenUpdate;
  UpdateScreen(False);
  (* prepare changes to the screen *)
  LockScreenUpdate;

  ui.screenBlank;
  TextOut(36, 2, 'white', ' You exit the cave! ');
  TextOut(5, 7, 'cyan', 'You have retrieved the map & escaped!');
  TextOut(5, 8, 'cyan', 'Thanks for testing the alpha version of Axes, Armour & Ale.');

  TextOut(5, 11, 'cyan', 'More content and bugfixes coming soon...');
  TextOut(5, 13, 'cyan', 'q - quit the game');

  (* Delete all saved data from disk *)
  file_handling.deleteGameData;

  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

end.

