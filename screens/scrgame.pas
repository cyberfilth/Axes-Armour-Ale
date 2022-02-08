(* Main game user interface *)

unit scrGame;

{$mode fpc}{$H+}

interface

uses
  player_stats;

var
  minX: smallint;

(* Draws the panel on side of screen *)
procedure drawSidepanel;
(* Clear screen and load various panels for game *)
procedure displayGameScreen;


implementation

uses
  ui, entities;

procedure drawSidepanel;
var
  i: smallint;
begin
  (* Stats window *)
  { top line }
  TextOut(minX, 1, 'cyan', Chr(218));
  for i := minX + 1 to minX + 21 do
  begin
    TextOut(i, 1, 'cyan', Chr(196));
  end;
  TextOut(minX + 22, 1, 'cyan', Chr(191));
  { edges }
  for i := 2 to 13 do
  begin
    TextOut(minX, i, 'cyan', Chr(179) + '                     ' + Chr(179));
  end;
  { bottom }
  TextOut(minX, 14, 'cyan', Chr(192));
  for i := minX + 1 to minX + 21 do
  begin
    TextOut(i, 14, 'cyan', Chr(196));
  end;
  TextOut(minX + 22, 14, 'cyan', Chr(217));

  (* Equipment window *)
  { top line }
  TextOut(minX, 15, 'cyan', Chr(218));
  for i := minX + 1 to minX + 21 do
  begin
    TextOut(i, 15, 'cyan', Chr(196));
  end;
  TextOut(minX + 22, 15, 'cyan', Chr(191));
  TextOut(minX + 2, 15, 'cyan', 'Equipment');
  { edges }
  for i := 16 to 20 do
  begin
    TextOut(minX, i, 'cyan', Chr(179) + '                     ' + Chr(179));
  end;
  { bottom }
  TextOut(minX, 20, 'cyan', Chr(192));
  for i := minX + 1 to minX + 21 do
  begin
    TextOut(i, 20, 'cyan', Chr(196));
  end;
  TextOut(minX + 22, 20, 'cyan', Chr(217));

  (* Write stat titles *)
  TextOut(minX + 2, 2, 'cyan', entities.entityList[0].race);
  TextOut(minX + 2, 3, 'cyan', 'The ' + entities.entityList[0].description);
  TextOut(minX + 2, 4, 'cyan', 'Level:');
  TextOut(minX + 2, 6, 'cyan', 'Experience:');
  TextOut(minX + 2, 7, 'cyan', 'Health:');
  (* Dwarf doesn't display magic in the sidebar *)
  if (player_stats.playerRace = 'Dwarf') then
  begin
    TextOut(minX + 2, 9, 'cyan', 'Attack:');
    TextOut(minX + 2, 10, 'cyan', 'Defence:');
  end
  else
  begin
    TextOut(minX + 2, 9, 'cyan', 'Magick:');
    TextOut(minX + 2, 11, 'cyan', 'Attack:');
    TextOut(minX + 2, 12, 'cyan', 'Defence:');
  end;

  (* Write stats *)
  ui.updateLevel;
  ui.updateXP;
  ui.updateHealth;
  if (player_stats.playerRace <> 'Dwarf') then
    ui.updateMagick;
  ui.updateAttack;
  ui.updateDefence;
  ui.updateWeapon;
  ui.updateArmour;
end;

procedure displayGameScreen;
begin
  drawSidepanel;
end;

end.

