(* Character sheet - Shows player stats *)

unit scrCharacter;

{$mode fpc}{$H+}

interface

uses
  SysUtils, ui, video, entities, player_stats;

(* Draw a box around the title *)
procedure drawOutline;
(* Display information about player character *)
procedure displayCharacterSheet;

implementation

procedure drawOutline;
begin
  TextOut(10, 1, 'cyan', chr(218));
  for x := 11 to 69 do
    TextOut(x, 1, 'cyan', chr(196));
  TextOut(70, 1, 'cyan', chr(191));
  TextOut(10, 2, 'cyan', chr(180));
  TextOut(70, 2, 'cyan', chr(195));
  TextOut(10, 3, 'cyan', chr(192));
  for x := 11 to 69 do
    TextOut(x, 3, 'cyan', chr(196));
  TextOut(70, 3, 'cyan', chr(217));
end;

procedure displayCharacterSheet;
var
  header, footer, whoami, statsBar, dmg, statusFX: string;
  y: smallint;
begin
  y := 6;
  dmg := '';
  statusFX := '';
  header := 'Character sheet';
  footer := '[x] to exit this screen';
  whoami := 'Name: ' + entityList[0].race + ' the ' + entityList[0].description +
  '     Kin: ' + player_stats.playerRace + '     Level ' + IntToStr(player_stats.playerLevel) + ' adventurer';

  statsBar := 'Attack [' + IntToStr(entityList[0].attack) +
    ']   Defence [' + IntToStr(entityList[0].defence) + ']   Dexterity [' +
    IntToStr(player_stats.dexterity) + ']   XP [' + IntToStr(entityList[0].xpReward) + ']';

  LockScreenUpdate;
  screenBlank;
  (* Draw box around the title *)
  drawOutline;

  TextOut(ui.centreX(header), 2, 'cyan', header);
  TextOut(ui.centreX(whoami), y, 'cyan', whoami);
  Inc(y, 2);
  TextOut(ui.centreX(statsBar), y, 'cyan', statsBar);
  Inc(y, 3);
  (* Get the weapon adds *)
  if (entityList[0].weaponDice <> 0) then
     dmg := dmg + IntToStr(entityList[0].weaponDice) + 'D6';
  if (entityList[0].weaponAdds <> 0) then
     dmg := dmg + '+' + IntToStr(entityList[0].weaponAdds);
  if (dmg <> '') then
     TextOut(10, y, 'cyan', 'Equipped weapon: ' + equippedWeapon + ' (' + dmg + ')')
  else
     TextOut(10, y, 'cyan', 'Equipped weapon: ' + equippedWeapon);
  (* Get the armour protection *)
  Inc(y, 1);
  if (player_stats.armourPoints > 0) then
    TextOut(10, y, 'cyan', 'Equipped armour: ' + equippedArmour + ' (+' + IntToStr(player_stats.armourPoints) + ')')
  else
     TextOut(10, y, 'cyan', 'Equipped armour: ' + equippedArmour);
  (* XP points to the next level *)
  Inc(y, 2);
  if (player_stats.playerLevel = 1) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(100 - entityList[0].xpReward) + ' experience points to advance to level 2')
  else if (player_stats.playerLevel = 2) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(250 - entityList[0].xpReward) + ' experience points to advance to level 3')
  else if (player_stats.playerLevel = 3) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(450 - entityList[0].xpReward) + ' experience points to advance to level 4')
  else if (player_stats.playerLevel = 4) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(700 - entityList[0].xpReward) + ' experience points to advance to level 5')
  else if (player_stats.playerLevel = 5) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(1000 - entityList[0].xpReward) + ' experience points to advance to level 6')
  else if (player_stats.playerLevel = 6) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(1350 - entityList[0].xpReward) + ' experience points to advance to level 7')
  else if (player_stats.playerLevel = 7) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(1750 - entityList[0].xpReward) + ' experience points to advance to level 8')
  else if (player_stats.playerLevel = 8) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(2200 - entityList[0].xpReward) + ' experience points to advance to level 9')
  else if (player_stats.playerLevel = 9) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(2700 - entityList[0].xpReward) + ' experience points to advance to level 10')
  else if (player_stats.playerLevel = 10) then
    TextOut(10, y, 'cyan', 'You need ' + IntToStr(3250 - entityList[0].xpReward) + ' experience points to advance to level 11');

  (* Status effects *)
  if (entityList[0].stsDrunk = True) or (entityList[0].stsPoison = True) then
    begin
         Inc(y, 2);
         if (entityList[0].stsDrunk = True) then
           statusFX := statusFX + '  [ drunk ]  ';
         if (entityList[0].stsPoison = True) then
           statusFX := statusFX + '  [ poisoned ]  ';
         TextOut(10, y, 'cyan', 'Current status:');
         Inc(y);
         TextOut(centreX(statusFX), y, 'cyan', statusFX);
    end;

  TextOut(ui.centreX(footer), 24, 'cyan', footer);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
