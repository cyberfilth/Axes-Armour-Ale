(* Overworld screen user interface *)

unit scrOverworld;

{$mode fpc}{$H+}

interface

uses
  player_stats, scrGame;

(* Draws the panel on side of screen *)
procedure drawSidepanel;

implementation

uses
  ui, entities;

procedure drawSidepanel;
var
  i: smallint;
begin
  (* Stats window *)
  { top line }
  TextOut(scrGame.minX, 1, 'cyan', Chr(218));
  for i := scrGame.minX + 1 to scrGame.minX + 21 do
  begin
    TextOut(i, 1, 'cyan', Chr(196));
  end;
  TextOut(scrGame.minX + 22, 1, 'cyan', Chr(191));
  { edges }
  for i := 2 to 13 do
  begin
    TextOut(scrGame.minX, i, 'cyan', Chr(179) + '                     ' + Chr(179));
  end;
  { bottom }
  TextOut(scrGame.minX, 14, 'cyan', Chr(192));
  for i := scrGame.minX + 1 to scrGame.minX + 21 do
  begin
    TextOut(i, 14, 'cyan', Chr(196));
  end;
  TextOut(scrGame.minX + 22, 14, 'cyan', Chr(217));

  (* Equipment window *)
  { top line }
  TextOut(scrGame.minX, 15, 'cyan', Chr(218));
  for i := scrGame.minX + 1 to scrGame.minX + 21 do
  begin
    TextOut(i, 15, 'cyan', Chr(196));
  end;
  TextOut(scrGame.minX + 22, 15, 'cyan', Chr(191));
  TextOut(scrGame.minX + 2, 15, 'cyan', 'Equipment');
  { edges }
  for i := 16 to 20 do
  begin
    TextOut(scrGame.minX, i, 'cyan', Chr(179) + '                     ' + Chr(179));
  end;
  { bottom }
  TextOut(scrGame.minX, 20, 'cyan', Chr(192));
  for i := scrGame.minX + 1 to scrGame.minX + 21 do
  begin
    TextOut(i, 20, 'cyan', Chr(196));
  end;
  TextOut(scrGame.minX + 22, 20, 'cyan', Chr(217));

  (* Write stat titles *)
  TextOut(scrGame.minX + 2, 2, 'cyan', entities.entityList[0].race);
  TextOut(scrGame.minX + 2, 3, 'cyan', 'The ' + entities.entityList[0].description);
  TextOut(scrGame.minX + 2, 4, 'cyan', 'Level:');
  TextOut(scrGame.minX + 2, 6, 'cyan', 'Experience:');
  TextOut(scrGame.minX + 2, 7, 'cyan', 'Health:');
  (* Dwarf doesn't display magic in the sidebar *)
  if (player_stats.playerRace = 'Dwarf') then
  begin
    TextOut(scrGame.minX + 2, 9, 'cyan', 'Attack:');
    TextOut(scrGame.minX + 2, 10, 'cyan', 'Defence:');
    TextOut(scrGame.minX + 2, 11, 'cyan', 'Dexterity:');
  end
  else
  begin
    TextOut(scrGame.minX + 2, 9, 'cyan', 'Magick:');
    TextOut(scrGame.minX + 2, 11, 'cyan', 'Attack:');
    TextOut(scrGame.minX + 2, 12, 'cyan', 'Defence:');
    TextOut(scrGame.minX + 2, 13, 'cyan', 'Dexterity:');
  end;

  (* Write stats *)
  ui.updateLevel;
  ui.updateXP;
  ui.updateHealth;
  if (player_stats.playerRace <> 'Dwarf') then
    ui.updateMagick;
  ui.updateAttack;
  ui.updateDefence;
  ui.updateDexterity;
  ui.updateWeapon;
  ui.updateArmour;
end;

end.
