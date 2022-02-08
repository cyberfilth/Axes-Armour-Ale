(* User Interface - Unit responsible for displaying messages and screens *)

unit ui;

{$mode objfpc}{$H+}
{$IFOPT D+} {$DEFINE DEBUG} {$ENDIF}

interface

uses
  SysUtils, StrUtils, video, keyboard, scrTitle, dlgInfo, player_stats, globalUtils,
  scrGame,
  {$IFDEF WINDOWS}
  JwaWinCon, {$ENDIF}
  (* CRT unit is just to clear the screen on exit *)
  Crt;

var
  vid: TVideoMode;
  x, y, displayCol, displayRow: smallint;
  messageArray: array[1..7] of shortstring = (' ', ' ', ' ', ' ', ' ', ' ', ' ');
  buffer: shortstring;
  equippedWeapon, equippedArmour: shortstring;
  (* Status effects *)
  poisonStatusSet: boolean;

(* Write to the screen *)
procedure TextOut(X, Y: word; textcol: shortstring; const S: string);
(* Blank the screen *)
procedure screenBlank;
(* Initialise the video unit *)
procedure setupScreen(yn: byte);
(* Shutdown the video unit *)
procedure shutdownScreen;
(* Display status effects *)
procedure displayStatusEffect(onoff: byte; effectType: shortstring);
(* Write text to the message log *)
procedure displayMessage(message: shortstring);
(* Store all messages from players turn *)
procedure bufferMessage(message: shortstring);
(* Write buffered message to the message log *)
procedure writeBufferedMessages;
(* Restore message window after showing a menu *)
procedure restoreMessages;
(* Update Level number *)
procedure updateLevel;
(* Update Experience points display *)
procedure updateXP;
(* Update player health display *)
procedure updateHealth;
(* Update player magick display *)
procedure updateMagick;
(* Update player attack value *)
procedure updateAttack;
(* Update player defence value *)
procedure updateDefence;
(* Display equipped weapon *)
procedure updateWeapon;
(* Display equipped armour *)
procedure updateArmour;
(* Display Quit Game confirmation *)
procedure exitPrompt;
(* Clears the status bar message *)
procedure clearStatusBar;
(* Clear screen and write exit message *)
procedure exitMessage;
(* Dialog box *)
procedure displayDialog(title, message: shortstring);
(* Display welcome message *)
procedure welcome;
(* Get X coordinate to centre a string *)
function centreX(textstring: shortstring): byte;
(* Redraw map after a pop-up closes *)
procedure clearPopup;

implementation

uses
  entities, main, fov, items, map, camera;

procedure TextOut(X, Y: word; textcol: shortstring; const S: string);
var
  P, I, M: smallint;
  tint: byte;
begin
  tint := $07;
  case textcol of
    'black': tint := video.Black;
    'blue': tint := video.Blue;
    'green': tint := video.Green;
    'lightGreen': tint := video.LightGreen;
    'greenBlink': tint := video.Green + video.Blink;
    'cyan': tint := video.Cyan;
    'cyanBGblackTXT': tint := ($03 shl 4);
    'red': tint := video.Red;
    'pink': tint := video.LightRed;
    'magenta': tint := video.Magenta;
    'lightMagenta': tint := video.LightMagenta;
    'brown': tint := video.Brown;
    'grey': tint := $07;
    'darkGrey': tint := video.DarkGray;
    'brownBlock': tint := $66;
    'lightCyan': tint := video.LightCyan;
    'yellow': tint := video.Yellow;
    'lightGrey': tint := video.LightGray;
    'white': tint := video.White;
    'DgreyBGblack': tint := $80;
    'LgreyBGblack': tint := $70;
    else
      tint := $07;
  end;
  P := ((X - 1) + (Y - 1) * ScreenWidth);
  M := Length(S);
  if ((P + M) > (int64(ScreenWidth) * ScreenHeight)) then
    M := int64(ScreenWidth) * ScreenHeight - P;
  for I := 1 to M do
    VideoBuf^[int64(P + I) - 1] := Ord(S[i]) + (tint shl 8);
end;

procedure screenBlank;
begin
  for y := 1 to displayRow do
  begin
    for x := 1 to displayCol do
    begin
      TextOut(x, y, 'black', ' ');
    end;
  end;
end;

procedure setupScreen(yn: byte);
begin
  {$IFDEF WINDOWS}
  SetConsoleTitle('Axes, Armour & Ale');
  {$ENDIF}
  { Initialise the video unit }
  InitVideo;
  InitKeyboard;
  vid.Col := displayCol;
  vid.Row := displayRow;
  vid.Color := True;
  SetVideoMode(vid);
  SetCursorType(crHidden);
  ClearScreen;
  (* prepare changes to the screen *)
  LockScreenUpdate;
  scrtitle.displayTitleScreen(yn);
  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

procedure shutdownScreen;
begin
  SetCursorType(crBlock);
  ClearScreen;
  DoneVideo;
  DoneKeyboard;
end;

procedure displayStatusEffect(onoff: byte; effectType: shortstring);
begin
  { POISON }
  if (effectType = 'poison') then
  begin
    if (onoff = 1) then
      TextOut(5, 20, 'green', '[Poisoned]')
    else if (onoff = 0) then
      TextOut(5, 20, 'black', '          ');
  end;
end;

procedure displayMessage(message: shortstring);
var
  tempStr: shortstring;
  tempCounter: smallint;
begin
  (* Catch duplicate messages *)
  if (message = messageArray[1]) then
  begin
    (* Clear first line *)
    for x := 1 to 80 do
    begin
      TextOut(x, 21, 'black', ' ');
    end;
    messageArray[1] := messageArray[1] + ' x2';
    TextOut(1, 21, 'white', messageArray[1]);
  end
  else if (ansistartstext(message, messageArray[1]) = True) then
  begin
    (* Clear first line *)
    for x := 1 to 80 do
    begin
      TextOut(x, 21, 'black', ' ');
    end;
    tempStr := rightstr(messageArray[1], Length(messageArray[1]) -
      lastdelimiter('x', messageArray[1]));
    tempCounter := StrToInt(tempStr);
    Inc(tempCounter);
    messageArray[1] := message + ' x' + IntToStr(tempCounter);
    TextOut(1, 21, 'white', messageArray[1]);
  end
  else
  begin
    (* Clear the message window *)
    for y := 21 to 25 do
    begin
      for x := 1 to 80 do
      begin
        TextOut(x, y, 'black', ' ');
      end;
    end;
    (* Shift all messages down one in the array *)
    messageArray[7] := messageArray[6];
    messageArray[6] := messageArray[5];
    messageArray[5] := messageArray[4];
    messageArray[4] := messageArray[3];
    messageArray[3] := messageArray[2];
    messageArray[2] := messageArray[1];
    messageArray[1] := message;
    (* Display each line, gradually getting darker *)
    TextOut(1, 21, 'white', messageArray[1]);
    TextOut(1, 22, 'lightGrey', messageArray[2]);
    TextOut(1, 23, 'grey', messageArray[3]);
    TextOut(1, 24, 'darkGrey', messageArray[4]);
    TextOut(1, 25, 'darkGrey', messageArray[5]);
  end;
end;

procedure bufferMessage(message: shortstring);
begin
  buffer := buffer + message + '. ';
  if (Length(buffer) >= 45) then
    displayMessage(buffer);
end;

procedure writeBufferedMessages;
begin
  if (buffer <> '') then
    displayMessage(buffer);
  buffer := '';
end;

procedure restoreMessages;
begin
  (* Display each line, gradually getting darker *)
  TextOut(1, 21, 'white', messageArray[1]);
  TextOut(1, 22, 'lightGrey', messageArray[2]);
  TextOut(1, 23, 'grey', messageArray[3]);
  TextOut(1, 24, 'darkGrey', messageArray[4]);
  TextOut(1, 25, 'darkGrey', messageArray[5]);
end;

procedure updateLevel;
begin
  (* Paint over previous stats *)
  TextOut(scrGame.minX + 9, 4, 'black', Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219));
  (* Write out Level number *)
  TextOut(scrGame.minX + 9, 4, 'cyan', IntToStr(player_stats.playerLevel));
end;

procedure updateXP;
begin
  (* Paint over previous stats *)
  TextOut(scrGame.minX + 14, 6, 'black', Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219));
  (* Write out XP amount *)
  TextOut(scrGame.minX + 14, 6, 'cyan', IntToStr(entities.entityList[0].xpReward));
end;

procedure updateHealth;
var
  healthPercentage, bars, i: byte;
begin
  (* If player is dead, exit game *)
  if (entities.entityList[0].currentHP <= 0) then
  begin
    main.gameState := stGameOver;
    main.gameOver;
    Exit;
  end;
  (* Paint over previous stats *)
  TextOut(scrGame.minX + 10, 7, 'black', Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219));
  (* Write stats *)
  TextOut(scrGame.minX + 10, 7, 'cyan', IntToStr(entities.entityList[0].currentHP) +
    '/' + IntToStr(entities.entityList[0].maxHP));
  (* Paint over health bar *)
  TextOut(scrGame.minX + 2, 8, 'black', Chr(223) + Chr(223) + Chr(223) +
    Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) +
    Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223));
  (* Length of health bar *)
  bars := 0;
  (* Calculate percentage of total health *)
  healthPercentage :=
    (entities.entityList[0].currentHP * 100) div entities.entityList[0].maxHP;
  (* Calculate the length of the health bar *)
  if (healthPercentage <= 6) then
    bars := 1
  else if (healthPercentage > 6) and (healthPercentage <= 12) then
    bars := 2
  else if (healthPercentage > 12) and (healthPercentage <= 18) then
    bars := 3
  else if (healthPercentage > 18) and (healthPercentage < 25) then
    bars := 4
  else if (healthPercentage >= 25) and (healthPercentage <= 31) then
    bars := 5
  else if (healthPercentage > 31) and (healthPercentage <= 37) then
    bars := 6
  else if (healthPercentage > 37) and (healthPercentage <= 43) then
    bars := 7
  else if (healthPercentage > 43) and (healthPercentage < 50) then
    bars := 8
  else if (healthPercentage >= 50) and (healthPercentage <= 56) then
    bars := 9
  else if (healthPercentage > 56) and (healthPercentage <= 62) then
    bars := 10
  else if (healthPercentage > 62) and (healthPercentage <= 68) then
    bars := 11
  else if (healthPercentage > 68) and (healthPercentage < 75) then
    bars := 12
  else if (healthPercentage >= 75) and (healthPercentage <= 81) then
    bars := 13
  else if (healthPercentage > 81) and (healthPercentage <= 87) then
    bars := 14
  else if (healthPercentage > 87) and (healthPercentage <= 94) then
    bars := 15
  else if (healthPercentage > 94) then
    bars := 16;
  (* Draw health bar *)
  for i := 1 to bars do
    TextOut((scrGame.minX + 1) + i, 8, 'green', Chr(223));
end;

procedure updateMagick;
var
  magickPercentage, bars, i: byte;
begin
  (* Paint over previous stats *)
  TextOut(scrGame.minX + 10, 9, 'black', Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219));
  (* Write stats *)
  TextOut(scrGame.minX + 10, 9, 'cyan', IntToStr(player_stats.currentMagick) +
    '/' + IntToStr(player_stats.maxMagick));
  (* Paint over magick bar *)
  TextOut(scrGame.minX + 2, 10, 'black', Chr(223) + Chr(223) + Chr(223) +
    Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) +
    Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223) + Chr(223));
  (* Length of magick bar *)
  bars := 0;
  (* Calculate percentage of total magick *)
  magickPercentage := (player_stats.currentMagick * 100) div player_stats.maxMagick;
  (* Calculate the length of the magick bar *)
  if (magickPercentage >= 1) and (magickPercentage <= 6) then
    bars := 1
  else if (magickPercentage > 6) and (magickPercentage <= 12) then
    bars := 2
  else if (magickPercentage > 12) and (magickPercentage <= 18) then
    bars := 3
  else if (magickPercentage > 18) and (magickPercentage < 25) then
    bars := 4
  else if (magickPercentage >= 25) and (magickPercentage <= 31) then
    bars := 5
  else if (magickPercentage > 31) and (magickPercentage <= 37) then
    bars := 6
  else if (magickPercentage > 37) and (magickPercentage <= 43) then
    bars := 7
  else if (magickPercentage > 43) and (magickPercentage < 50) then
    bars := 8
  else if (magickPercentage >= 50) and (magickPercentage <= 56) then
    bars := 9
  else if (magickPercentage > 56) and (magickPercentage <= 62) then
    bars := 10
  else if (magickPercentage > 62) and (magickPercentage <= 68) then
    bars := 11
  else if (magickPercentage > 68) and (magickPercentage < 75) then
    bars := 12
  else if (magickPercentage >= 75) and (magickPercentage <= 81) then
    bars := 13
  else if (magickPercentage > 81) and (magickPercentage <= 87) then
    bars := 14
  else if (magickPercentage > 87) and (magickPercentage <= 94) then
    bars := 15
  else if (magickPercentage > 94) then
    bars := 16;
  (* Draw magick bar *)
  for i := 1 to bars do
    TextOut((scrGame.minX + 1) + i, 10, 'blue', Chr(223));
end;

procedure updateAttack;
var
  position: byte;
begin
  if (player_stats.playerRace = 'Dwarf') then
    position := 9
  else
    position := 11;
  (* Paint over previous stats *)
  TextOut(scrGame.minX + 10, position, 'black', Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219));
  (* Write out XP amount *)
  TextOut(scrGame.minX + 10, position, 'cyan', IntToStr(entities.entityList[0].attack));
end;

procedure updateDefence;
var
  position: byte;
begin
  if (player_stats.playerRace = 'Dwarf') then
    position := 10
  else
    position := 12;
  (* Paint over previous stats *)
  TextOut(scrGame.minX + 11, position, 'black', Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) + Chr(219) +
    Chr(219) + Chr(219) + Chr(219));
  (* Write out XP amount *)
  TextOut(scrGame.minX + 11, position, 'cyan', IntToStr(entities.entityList[0].defence));
end;

procedure updateWeapon;
begin
  (* Paint over previous weapon *)
  TextOut(scrGame.minX + 1, 17, 'black', '                     '); { 21 characters }
  (* Display equipped weapon *)
  if (equippedWeapon <> 'No weapon equipped') then
    TextOut(scrGame.minX + 1, 17, 'cyan', equippedWeapon)
  else
    TextOut(scrGame.minX + 1, 17, 'darkGrey', equippedWeapon);
end;

procedure updateArmour;
begin
  (* Paint over previous armour *)
  TextOut(scrGame.minX + 1, 18, 'black', '                     '); { 21 characters }
  (* Display equipped armour *)
  if (equippedArmour <> 'No armour worn') then
    TextOut(scrGame.minX + 1, 18, 'cyan', equippedArmour)
  else
    TextOut(scrGame.minX + 1, 18, 'darkGrey', equippedArmour);
end;

procedure exitPrompt;
begin
  (* prepare changes to the screen *)
  LockScreenUpdate;
  TextOut(1, 20, 'LgreyBGblack',
    ' [Q]-Quit game  [X]-Exit to menu  [ESC]-Return to game  ');
  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

procedure clearStatusBar;
begin
  (* prepare changes to the screen *)
  LockScreenUpdate;
  TextOut(1, 20, 'black', '                                                        ');
  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

procedure exitMessage;
begin
  ClrScr;
  {$IFDEF DEBUG}
  writeln('DEBUG VERSION');
  writeln('Random seed: ' + IntToStr(RandSeed));
  {$EndIf}
  writeln('Axes, Armour & Ale - Version ' + globalUtils.VERSION);
  writeln('by Chris Hawkins');
  Exit;
end;

procedure displayDialog(title, message: shortstring);
begin
  case title of
    'info': dlgInfo.infoDialog(message);
    'level': dlgInfo.levelUpDialog(message);
  end;
end;

procedure welcome;
begin
  dlgInfo.newGame;
end;

function centreX(textstring: shortstring): byte;
begin
  Result := 40 - (Length(textstring) div 2);
end;

procedure clearPopup;
var
  i: smallint;
begin
  LockScreenUpdate;
  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  (* Redraw all NPC'S *)
  for i := 1 to entities.npcAmount do
    entities.redrawMapDisplay(i);
  (* Redraw all items *)
  for i := 1 to items.itemAmount do
    if (map.canSee(items.itemList[i].posX, items.itemList[i].posY) = True) then
    begin
      items.itemList[i].inView := True;
      items.drawItemsOnMap(i);
      (* Display a message if this is the first time seeing this item *)
      if (items.itemList[i].discovered = False) then
      begin
        ui.displayMessage('You see ' + items.itemList[i].itemArticle + ' ' + items.itemList[i].itemName);
        items.itemList[i].discovered := True;
      end;
    end
    else
    begin
      items.itemList[i].inView := False;
      map.drawTile(itemList[i].posX, itemList[i].posY, 0);
    end;
  (* draw map through the camera *)
  camera.drawMap;
  UnlockScreenUpdate;
  UpdateScreen(False);
  dialogType := dlgNone;
end;

end.
