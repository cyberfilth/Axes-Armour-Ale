(* Information Dialog box *)

unit dlgInfo;

{$mode fpc}{$H+}

interface

uses
  SysUtils, video, plot_gen, universe, globalUtils;

(* Types of pop-up dialog box *)
type
  dialogFlag = (dlgNone, dlgFoundSMap, dlgParchment, dlgNecro, dlgLveVill, dlgMerchantIntro);

var
  (* Notifies the game loop whether to display a pop-up or not *)
  dialogType: dialogFlag;
  (* Type of parchment scroll found *)
  parchmentType: string;

(* Display Info dialog box *)
procedure infoDialog(message: shortstring);
(* Display level up dialog box *)
procedure levelUpDialog(message: shortstring);
(* Display welcome text *)
procedure newGame;
(* Display a warning when starting a new game *)
procedure newWarning;
(* Check if there is a pop-up to display *)
procedure checkNotifications;
(* 1st cave, found the Smugglers Map *)
procedure foundMap;
(* Read a parchment scroll *)
procedure readScroll;
(* Necromancers curse *)
procedure displayCurse;
(* Prompt to leave the village *)
procedure leaveVillage;
(* Buy / Sell items dialog box *)
procedure buySellIntro;

implementation

uses
  ui, entities, main;

procedure infoDialog(message: shortstring);
var
  x, y: smallint;
begin
  x := 8;
  y := 5;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 9 to 45 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(46, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 12 do
    TextOut(8, y, 'LgreyBGblack', chr(186) + '                                     ' + chr(186));
  (* Bottom border *)
  TextOut(8, y + 1, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 9 to 45 do
    TextOut(x, y + 1, 'LgreyBGblack', chr(205));
  TextOut(46, y + 1, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(10, 5, 'LgreyBGblack', 'Info');
  (* Write the message *)
  TextOut(10, 7, 'LgreyBGblack', message);
end;

procedure levelUpDialog(message: shortstring);
var
  x, y: smallint;
begin
  x := 8;
  y := 5;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 9 to 46 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(47, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 17 do
    TextOut(8, y, 'LgreyBGblack', chr(186) + '                                      ' + chr(186));
  (* Bottom border *)
  TextOut(8, y + 1, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 9 to 46 do
    TextOut(x, y + 1, 'LgreyBGblack', chr(205));
  TextOut(47, y + 1, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(10, 5, 'LgreyBGblack', chr(181) + ' Level up ' + chr(198));

  (* Write the message *)
  TextOut(10, 7, 'LgreyBGblack', 'Your experiences have sharpened your');
  TextOut(10, 8, 'LgreyBGblack', 'skills.');
  TextOut(10, 9, 'LgreyBGblack', 'You have advanced to level ' + message);
  TextOut(10, 11, 'LgreyBGblack', 'Increase one of the following:');
  { Increase max health by 10 % }
  TextOut(10, 12, 'LgreyBGblack', 'A - Increase Max Health by ' + IntToStr(round((entityList[0].maxHP / 100) * 10)));
  { Increase attack strength by level number }
  TextOut(10, 13, 'LgreyBGblack', 'B - Increase Attack by ' + message);
  { Increase defence by level number }
  TextOut(10, 14, 'LgreyBGblack', 'C - Increase Defence by ' + message);
  { Increase both attack and defence by half of level number }
  TextOut(10, 15, 'LgreyBGblack', 'D - Increase Attack & Defence by ' + IntToStr(StrToInt(message) div 2));
  { Increase dexterity by half of level number }
  TextOut(10, 16, 'LgreyBGblack', 'E - Increase Dexterity by ' + IntToStr(StrToInt(message) div 2));
  { Options }
  TextOut(13, 18, 'LgreyBGblack', '[A]   [B]   [C]   [D]   [E]');
end;

procedure newGame;
var
  x, y: smallint;
begin
  plot_gen.getTrollDate;
  x := 3;
  y := 5;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(54, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 12 do
    TextOut(3, y, 'LgreyBGblack', chr(186) +
      '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 13, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 13, 'LgreyBGblack', chr(205));
  TextOut(54, 13, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(5, 5, 'LgreyBGblack', ' Welcome ');
  (* Write the message *)
  TextOut(5, 7, 'LgreyBGblack', 'It is ' + plot_gen.trollDate);
  TextOut(5, 8, 'LgreyBGblack', 'You enter the ' + UTF8Encode(universe.title) + '.');
  TextOut(5, 10, 'LgreyBGblack', 'Find the map and return to the surface.');
  TextOut(5, 12, 'LgreyBGblack', 'Good Luck...');
end;

procedure newWarning;
var
  y, warning: smallint;
  warningText: shortstring;
begin
  (* Clear screen & set background to black *)
  ui.screenBlank;
  y := 8;
  (* Select a warning message *)
  warning := randomRange(1, 3);
  if (warning = 1) then
    warningText := ' Watch your step! '
  else if (warning = 2) then
    warningText := ' Careful now! '
  else
    warningText := ' Beware adventurer! ';

  (* prepare changes to the screen *)
  LockScreenUpdate;
  TextOut(centreX(warningText), y, 'cyanBGblackTXT', warningText);
  TextOut(centreX('If you start a new game, you will'), y + 2, 'cyan',
    'If you start a new game, you will');
  TextOut(centreX('lose your existing save file.....'), y + 3, 'cyan',
    'lose your existing save file.....');
  TextOut(centreX('Do you wish to proceed?'), y + 5, 'cyan', 'Do you wish to proceed?');
  TextOut(centreX('y / n'), y + 6, 'cyan', 'y / n');

  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

procedure checkNotifications;
begin
  case dialogType of
    dlgNone: exit;
    dlgFoundSMap: foundMap;
    dlgParchment: readScroll;
    dlgNecro: displayCurse;
    dlgLveVill: leaveVillage;
    dlgMerchantIntro: buySellIntro;
  end;
end;

procedure foundMap;
var
  x, y: smallint;
begin
  main.gameState := stDialogBox;
  x := 3;
  y := 5;
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(54, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 12 do
    TextOut(3, y, 'LgreyBGblack', chr(186) +
      '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 13, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 13, 'LgreyBGblack', chr(205));
  TextOut(54, 13, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(5, 5, 'LgreyBGblack', ' Item Found ');
  (* Write the message *)
  TextOut(5, 7, 'LgreyBGblack', 'You have found the Smugglers Map!');
  TextOut(5, 8, 'LgreyBGblack', 'In the distance, you hear the sound of a door');
  TextOut(5, 9, 'LgreyBGblack', 'unlocking. It is time to leave.');
  TextOut(5, 11, 'LgreyBGblack', 'Well done....');
  TextOut(8, 13, 'LgreyBGblack', ' press [x] to continue');

  UnlockScreenUpdate;
  UpdateScreen(False);
  dialogType := dlgNone;
end;

procedure readScroll;
var
  x, y: smallint;
begin
  main.gameState := stDialogBox;
  x := 3;
  y := 5;
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(54, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 12 do
    TextOut(3, y, 'LgreyBGblack', chr(186) +
      '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 13, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 13, 'LgreyBGblack', chr(205));
  TextOut(54, 13, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(5, 5, 'LgreyBGblack', ' Item Found ');
  (* Write the message *)
  TextOut(5, 7, 'LgreyBGblack', 'You have found an enchanted scroll!');
  TextOut(5, 8, 'LgreyBGblack', 'You try to decipher the runes...');
  TextOut(5, 9, 'LgreyBGblack', '"' + plot_gen.writeScroll(parchmentType) + '"');
  case parchmentType of
    'DEX': TextOut(5, 11, 'LgreyBGblack', 'You feel your Dexterity improve');
    'ATT': TextOut(5, 11, 'LgreyBGblack', 'You feel your Attack improve');
    'DEF': TextOut(5, 11, 'LgreyBGblack', 'You feel your Defence improve');
  end;
  TextOut(8, 13, 'LgreyBGblack', ' press [x] to continue');
  UnlockScreenUpdate;
  UpdateScreen(False);
  dialogType := dlgNone;
end;

procedure displayCurse;
var
  x, y: smallint;
begin
  main.gameState := stDialogBox;
  x := 3;
  y := 5;
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(54, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 12 do
    TextOut(3, y, 'LgreyBGblack', chr(186) +
      '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 13, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 13, 'LgreyBGblack', chr(205));
  TextOut(54, 13, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(5, 5, 'LgreyBGblack', ' Curses! ');
  (* Write the message *)
  TextOut(5, 7, 'LgreyBGblack', 'The necromancer collapses, dying.');
  TextOut(5, 8, 'LgreyBGblack', 'As they fall, a curse leaves their lips');
  TextOut(5, 10, 'LgreyBGblack', '"Arise, dead brothers. Arise!"');
  TextOut(5, 12, 'LgreyBGblack', 'You hear corpses stumbling to their feet..');
  TextOut(8, 13, 'LgreyBGblack', ' press [x] to continue');
  UnlockScreenUpdate;
  UpdateScreen(False);
  dialogType := dlgNone;
end;

procedure leaveVillage;
var
  x, y: smallint;
begin
  main.gameState := stLeaveVillage;
  x := 3;
  y := 5;
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, 'LgreyBGblack', chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, 'LgreyBGblack', chr(205));
  TextOut(54, y, 'LgreyBGblack', chr(187));
  (* Vertical sides *)
  for y := 6 to 8 do
    TextOut(3, y, 'LgreyBGblack', chr(186) + '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 9, 'LgreyBGblack', chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 9, 'LgreyBGblack', chr(205));
  TextOut(54, 9, 'LgreyBGblack', chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(5, 5, 'LgreyBGblack', ' Leave Village? ');
  (* Write the message *)
  TextOut(5, 7, 'LgreyBGblack', 'Do you want to leave the village?');
  TextOut(14, 9, 'LgreyBGblack', ' [y] to leave, [n] to stay ');
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure buySellIntro;
var
  x, y: smallint;
  BG, FG, greeting: shortstring;
  randGreet: byte;
begin
  main.gameState := stBarterIntro;
  greeting := '';
  randGreet := randomRange(0, 3);
  x := 3;
  y := 5;
  BG := 'cyan';
  FG := 'white';
  (* Select a random greeting *)
  if (randGreet = 0) then
    greeting := 'Greetings, are you looking to trade?'
  else if (randGreet = 1) then
    greeting := 'Welcome, would you like to see my wares?'
  else if (randGreet = 2) then
    greeting := 'Hail!, would you like to buy / sell something?'
  else
    greeting := 'Greetings, are you looking for equipment?';
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, BG, chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, BG, chr(205));
  TextOut(54, y, BG, chr(187));
  (* End borders around title *)
  TextOut(5, y, BG, chr(181));
  TextOut(25, y, BG, chr(198));
  (* Vertical sides *)
  for y := 6 to 8 do
    TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 9, BG, chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 9, BG, chr(205));
  TextOut(54, 9, BG, chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(6, 5, BG, 'The merchant speaks');
  (* Write the message *)
  TextOut(5, 7, FG, greeting);
  TextOut(22, 9,BG, ' [y]es, [n]o ');
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
