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
  header, footer, whoami, statsBar, dmg: string;
  y: smallint;
begin
  y := 6;
  dmg := '';
  header := 'Character sheet';
  footer := '[x] to exit this screen';
  whoami := 'Name: ' + entityList[0].race + ' the ' +
    entityList[0].description + '      ' + 'Level ' + IntToStr(player_stats.playerLevel) +
    ' ' + player_stats.playerRace;

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

  Inc(y, 1);
  TextOut(10, y, 'cyan', 'Equipped armour: ' + equippedArmour);

  TextOut(ui.centreX(footer), 24, 'cyan', footer);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
