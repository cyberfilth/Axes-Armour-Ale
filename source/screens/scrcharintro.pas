(* Character introduction and scene setting *)

unit scrCharIntro;

{$mode fpc}{$H+}

interface

uses
  ui, video, globalUtils, plot_gen, player_stats;

procedure setTheScene;
procedure humanText;
procedure elfText;
procedure dwarfText;

implementation

procedure setTheScene;
var
  header, footer: string;
begin
  header := 'Welcome ' + plot_gen.playerName + ', the ' + player_stats.playerRace;
  footer := '[SPACE] to continue  |  s - Skip intro';
  LockScreenUpdate;
  screenBlank;
  TextOut(ui.centreX(header), 2, 'cyan', header);

  (* Add the backstory *)
  if (player_stats.playerRace = 'Human') then
    humanText
  else if (player_stats.playerRace = 'Elf') then
    elfText
  else
    dwarfText;

  TextOut(ui.centreX(footer), 24, 'cyan', footer);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure humanText;
begin
  TextOut(3, 6, 'cyan', 'In the years following the Great Wizard War, the large cities of');
  TextOut(3, 7, 'cyan',
    'The Fallen Isles, where the different kindreds would live together');
  TextOut(3, 8, 'cyan',
    'have crumbled. Now the Isles have reverted to scattered settlements');
  TextOut(3, 9, 'cyan', 'where you have wandered as an adventurer.');
  TextOut(3, 11, 'cyan', 'You are a young human, originally from the small, poor village');
  TextOut(3, 12, 'cyan', 'of ' + plot_gen.smallVillage +
    '. You have set out to find adventure, but this ');
  TextOut(3, 13, 'cyan', 'rainy night finds you out of coin and alone on the road...');
end;

procedure elfText;
begin
  TextOut(3, 6, 'cyan', 'In the years following the Great Wizard War, the large cities of');
  TextOut(3, 7, 'cyan',
    'The Fallen Isles, where the different kindreds would live together');
  TextOut(3, 8, 'cyan',
    'have crumbled. Now the Isles have reverted to scattered settlements');
  TextOut(3, 9, 'cyan', 'where you have wandered as an adventurer.');
  TextOut(3, 11, 'cyan', 'You are a young Elf from ' + plot_gen.elvenTown + '.');
  TextOut(3, 12, 'cyan',
    'You have set out to find adventure, but this rainy night finds you');
  TextOut(3, 13, 'cyan', 'out of coin and alone on the road...');
end;

procedure dwarfText;
begin
  TextOut(3, 6, 'cyan', 'In the years following the Great Wizard War, the large cities of');
  TextOut(3, 7, 'cyan',
    'The Fallen Isles, where the different kindreds would live together');
  TextOut(3, 8, 'cyan',
    'have crumbled. Now the Isles have reverted to scattered settlements');
  TextOut(3, 9, 'cyan', 'where you have wandered as an adventurer.');
  TextOut(3, 11, 'cyan', 'You are a young dwarf, originally from the once proud');
  TextOut(3, 12, 'cyan', player_stats.clanName +
    ' clan. You have set out to find adventure, but this ');
  TextOut(3, 13, 'cyan', 'rainy night finds you out of coin and alone on the road...');
end;

end.
