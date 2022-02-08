(* Game over screen *)

unit scrRIP;

{$mode fpc}{$H+}

interface

uses
  SysUtils, video, globalUtils, entities, file_handling;

(* Show the game over screen *)
procedure displayRIPscreen;
(* Draw a skull on screen *)
procedure drawSkull;
(* Draw a bat on the screen *)
procedure drawBat;
(* Draw a gravestone on the screen *)
procedure drawGrave;

implementation

uses
  ui, player_stats;

procedure displayRIPscreen;

var
  epitaph, deathMessage, raceLevel, exitMessage: shortstring;
  prefix, img: smallint;
begin
  (* Create a farewell message *)
  epitaph := entityList[0].race + ' the ' + entityList[0].description;
  raceLevel := 'Level ' + IntToStr(player_stats.playerLevel) + ' ' +
    player_stats.playerRace;
  exitMessage := 'q - Quit game   |    x - Exit to menu';
  prefix := randomRange(1, 3);
  if (prefix = 1) then
    epitaph := 'Fare thee well, ' + epitaph
  else if (prefix = 2) then
    epitaph := 'So long, ' + epitaph
  else
    epitaph := 'In Memoriam, ' + epitaph;

  (* Show which creature killed the player *)
  deathMessage := 'Killed by a ' + globalUtils.killer + ', after ' +
    IntToStr(entityList[0].moveCount) + ' moves.';

  { Closing screen update as it is currently in the main game loop }
  UnlockScreenUpdate;
  UpdateScreen(False);

  (* prepare changes to the screen *)
  LockScreenUpdate;

  ui.screenBlank;
  TextOut(36, 2, 'cyan', 'You Died!');
  TextOut(ui.centreX(epitaph), 3, 'cyan', epitaph);
  TextOut(ui.centreX(raceLevel), 4, 'cyan', raceLevel);

  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
  (* Delete all saved data from disk *)
  file_handling.deleteGameData;

  (* prepare changes to the screen *)
  LockScreenUpdate;

  (* Randomly choose an image *)
  img := randomRange(1, 4);
  if (img = 1) then
    drawBat
  else if (img = 2) then
    drawSkull
  else
    drawGrave;

  TextOut(centreX(deathMessage), 18, 'cyan', deathMessage);
  TextOut(centreX(exitMessage), 24, 'cyan', exitMessage);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure drawSkull;

var
  col: shortstring;
  x: byte;
begin
  col := 'darkGrey';
  x := 32;
  TextOut(x, 5, col, '     ______');
  TextOut(x, 6, col, '  .-"      "-.');
  TextOut(x, 7, col, ' /            \');
  TextOut(x, 8, col, '|              |');
  TextOut(x, 9, col, '|,  .-.  .-.  ,|');
  TextOut(x, 10, col, '| )(__/  \__)( |');
  TextOut(x, 11, col, '|/     /\     \|');
  TextOut(x, 12, col, '(_     ^^     _)');
  TextOut(x, 13, col, ' \__|IIIIII|__/');
  TextOut(x, 14, col, '  | \IIIIII/ |');
  TextOut(x, 15, col, '  \          /');
  TextOut(x, 16, col, '   `--------`');

end;

procedure drawBat;

var
  col: shortstring;
  x: byte;
begin
  col := 'darkGrey';
  x := 32;
  TextOut(x, 10, col, '  _   ,_,   _');
  TextOut(x, 11, col, ' / `''=) (=''` \');
  TextOut(x, 12, col, '/.-.-.\ /.-.-.\');
  TextOut(x, 13, col, '`      "      `');
end;

procedure drawGrave;

var
  col: shortstring;
  x: byte;
begin
  col := 'darkGrey';
  x := 32;
  TextOut(x, 7, col, '       -|-');
  TextOut(x, 8, col, '    .-''~~~`-.');
  TextOut(x, 9, col, '  .''         `.');
  TextOut(x, 10, col, '  |  R  I  P  |');
  TextOut(x, 11, col, '  |           |');
  TextOut(x, 12, col, '  |           |');
  TextOut(x, 13, col, '\\|           |//');
  (* Write name on grave if it fits *)
  if (Length(entityList[0].race) <= 11) then
    TextOut(centreX(entityList[0].race), 11, col, entityList[0].race);
end;

end.
