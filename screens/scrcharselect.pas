(* Choose your characters race *)

unit scrCharSelect;

{$mode fpc}{$H+}

interface

uses
  ui, video, globalUtils, player_stats, plot_gen;

procedure choose;
procedure displayDwarf;
procedure displayElf;
procedure displayHuman;

implementation

procedure choose;
var
  yLine, randSelect: smallint;
  options, randSelectText: shortstring;
begin
  yLine := 4;
  randSelect := 2;
  options := 'a - Dwarf     b - Elf     c - Human';
  randSelectText := '[SPACE] to randomly select a race';
  (* Randomly select a race, in case the player doesn't choose one *)
  randSelect := randomRange(1, 3);
  if (randSelect = 1) then
  begin
    player_stats.playerRace := 'Human';
    plot_gen.generateHumanName;
  end
  else if (randSelect = 2) then
  begin
    player_stats.playerRace := 'Elf';
    plot_gen.generateElfName;
  end
  else
  begin
    player_stats.playerRace := 'Dwarf';
    plot_gen.generateDwarfName;
  end;

  LockScreenUpdate;
  screenBlank;
  TextOut(ui.centreX('Choose your character'), 2, 'cyan', 'Choose your character');
  TextOut(ui.centreX(options), yLine, 'cyan', options);
  TextOut(ui.centreX(randSelectText), 20, 'cyan', randSelectText);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure displayDwarf;
var
  yLine: smallint;
  options, SelectText: shortstring;
begin
  plot_gen.generateDwarfName;
  player_stats.playerRace := 'Dwarf';
  yLine := 4;
  options := 'a - Dwarf     b - Elf     c - Human';
  SelectText := '[SPACE] to confirm selection';

  LockScreenUpdate;
  screenBlank;
  TextOut(ui.centreX('Dwarf'), 2, 'cyan', 'Dwarf');
  TextOut(ui.centreX(options), yLine, 'cyan', options);
  TextOut(3, yLine + 2, 'cyan', 'Tough. Stubborn. Hairy. The dwarves of the ' +
    player_stats.clanName + ' clan');
  TextOut(3, yLine + 3, 'cyan',
    'are all of these and more. Immune to the effects of most harmful');
  TextOut(3, yLine + 4, 'cyan',
    'magic, dwarves are also unable to cast spells, relying instead on');
  TextOut(3, yLine + 5, 'cyan', 'iron, steel and their strength.');
  TextOut(ui.centreX(SelectText), 20, 'cyan', SelectText);

  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure displayElf;
var
  yLine: smallint;
  options, SelectText: shortstring;
begin
  plot_gen.generateElfName;
  player_stats.playerRace := 'Elf';
  yLine := 4;
  options := 'a - Dwarf     b - Elf     c - Human';
  SelectText := '[SPACE] to confirm selection';

  LockScreenUpdate;
  screenBlank;
  TextOut(ui.centreX('Elf'), 2, 'cyan', 'Elf');
  TextOut(ui.centreX(options), yLine, 'cyan', options);
  TextOut(3, yLine + 2, 'cyan',
    'In tune with both nature and the magical realm. Elves spend their');
  TextOut(3, yLine + 3, 'cyan',
    'considerably long lives learning how best to channel eldritch');
  TextOut(3, yLine + 4, 'cyan',
    'forces. Their fae nature doesn''t allow them to wield weapons and');
  TextOut(3, yLine + 5, 'cyan',
    'armour made of iron, but they are masters of combat and deadly');
  TextOut(3, yLine + 6, 'cyan',
    'foes nonetheless.');
  TextOut(ui.centreX(SelectText), 20, 'cyan', SelectText);

  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure displayHuman;
var
  yLine: smallint;
  options, SelectText: shortstring;
begin
  plot_gen.generateHumanName;
  player_stats.playerRace := 'Human';
  yLine := 4;
  options := 'a - Dwarf     b - Elf     c - Human';
  SelectText := '[SPACE] to confirm selection';

  LockScreenUpdate;
  screenBlank;
  TextOut(ui.centreX('Human'), 2, 'cyan', 'Human');
  TextOut(ui.centreX(options), yLine, 'cyan', options);
  TextOut(3, yLine + 2, 'cyan',
    'The most common race above ground, humans are short-lived but');
  TextOut(3, yLine + 3, 'cyan',
    'adaptable. Although lacking the keen eyesight, strength and');
  TextOut(3, yLine + 4, 'cyan',
    'magical mastery of some of the elder races. Humans are able to');
  TextOut(3, yLine + 5, 'cyan',
    'learn any skill or sorcery through sheer determination.');
  TextOut(ui.centreX(SelectText), 20, 'cyan', SelectText);

  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
