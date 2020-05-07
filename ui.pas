(* User Interface - Unit responsible for displaying messages and stats *)

unit ui;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Graphics, globalutils;

const
  (* side bar X position *)
  sbx = 687;
  (* side bar Y position *)
  sby = 10;
  (* side bar Width *)
  sbw = 140;
  (* side bar Height *)
  sbh = 150;
  (* equipment bar Y position *)
  eqy = 170;
  (* equipment bar Height *)
  eqh = 120;
  (* Look box Y position *)
  infoy = 300;
  (* Look box Height *)
  infoh = 100;


var
  messageArray: array[1..7] of string = (' ', ' ', ' ', ' ', ' ', ' ', ' ');
  buffer: string;
  logo: TBitmap;

(* Title screen *)
procedure titleScreen(yn: byte);
(* Draws the panel on side of screen *)
procedure drawSidepanel;
(* Update player level *)
procedure updateLevel;
(* Update Experience points display *)
procedure updateXP;
(* Update player health display *)
procedure updateHealth;
(* Update player attack value *)
procedure updateAttack;
(* Update player defence value *)
procedure updateDefence;
(* Display equipped weapon *)
procedure updateWeapon(weaponName: shortstring);
(* Display equipped armour *)
procedure updateArmour(armourName: shortstring);
(* Info window results from LOOK command *)
procedure displayLook(entityName: shortstring; currentHP, maxHP: smallint);
(* Write text to the message log *)
procedure displayMessage(message: string);
(* Store all messages from players turn *)
procedure bufferMessage(message: string);
(* Write buffered message to the message log *)
procedure writeBufferedMessages;
(* Display Quit Game confirmation *)
procedure exitPrompt;
(* Rewrite message at top of log *)
procedure rewriteTopMessage;
(* Clear message log *)
procedure clearLog;

implementation

uses
  main, entities, items;

procedure titleScreen(yn: byte);
begin
  logo := TBitmap.Create;
  logo.LoadFromResourceName(HINSTANCE, 'TITLESCREEN');
  (* Clear the screen *)
  main.tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(0, 0, tempScreen.Width, tempScreen.Height);
  (* Draw logo *)
  drawToBuffer(145, 57, logo);
  (* Check if a save file exists and display menu *)
  if (yn = 0) then
  begin
    writeToBuffer(200, 250, UITEXTCOLOUR, 'N - New Game');
    writeToBuffer(200, 270, UITEXTCOLOUR, 'Q - Quit');
  end
  else
  begin
    writeToBuffer(200, 250, UITEXTCOLOUR, 'L - Load Last Game');
    writeToBuffer(200, 270, UITEXTCOLOUR, 'N - New Game');
    writeToBuffer(200, 290, UITEXTCOLOUR, 'Q - Quit');
  end;
  logo.Free;
end;

procedure drawSidepanel;
begin
  main.tempScreen.Canvas.Pen.Color := globalutils.UICOLOUR;
  (* Stats window *)
  main.tempScreen.Canvas.Rectangle(sbx, sby, sbx + sbw, sby + sbh);
  (* Equipment window *)
  main.tempScreen.Canvas.Rectangle(sbx, eqy, sbx + sbw, eqy + eqh);
  (* Info window *)
  main.tempScreen.Canvas.Rectangle(sbx, infoy, sbx + sbw, infoy + infoh);
  main.tempScreen.Canvas.Font.Size := 10;
  (* Write stats *)
  writeToBuffer(sbx + 8, sby + 5, UITEXTCOLOUR, entities.entityList[0].race);
  updateLevel;
  updateXP;
  updateHealth;
  updateAttack;
  updateDefence;
  (* Write Equipment window *)
  writeToBuffer(sbx + 8, eqy + 5, MESSAGEFADE1, 'Equipment');
  updateWeapon('none');
  updateArmour('none');
  (* Write Info window *)
  writeToBuffer(sbx + 8, infoy + 5, MESSAGEFADE1, 'Info');
end;

procedure updateLevel;
begin
  (* Select players title *)
  if (entities.entityList[0].xpReward <= 10) then
    entities.entityList[0].description := 'the Worthless'
  else if (entities.entityList[0].xpReward > 10) then
    entities.entityList[0].description := 'the Brawler';
  (* Paint over previous title *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 8, sby + 25, sbx + 135, sby + 45);
  (* Write title to screen *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 25, UITEXTCOLOUR, entities.entityList[0].description);
end;

procedure updateXP;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 80, sby + 55, sbx + 135, sby + 75);
  main.tempScreen.Canvas.Pen.Color := UICOLOUR;
  (* Write Experience points *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 55, UITEXTCOLOUR, 'Experience:  ' +
    IntToStr(entities.entityList[0].xpReward));
end;

procedure updateHealth;
var
  healthPercentage: smallint;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 33, sby + 75, sbx + 135, sby + 95);
  (* Draw Health amount *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 75, UITEXTCOLOUR, 'Health:  ' +
    IntToStr(entities.entityList[0].currentHP) + ' / ' +
    IntToStr(entities.entityList[0].maxHP));
  (* Draw health bar *)
  main.tempScreen.Canvas.Brush.Color := $2E2E00; // Background colour
  main.tempScreen.Canvas.FillRect(sbx + 8, sby + 95, sbx + 108, sby + 100);
  (* Calculate percentage of total health *)
  healthPercentage := (entities.entityList[0].currentHP * 100) div
    entities.entityList[0].maxHP;
  main.tempScreen.Canvas.Brush.Color := $0B9117; // Green colour
  main.tempScreen.Canvas.FillRect(sbx + 8, sby + 95, sbx +
    (healthPercentage + 8), sby + 100);
end;

procedure updateAttack;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 50, sby + 105, sbx + 135, sby + 125);
  main.tempScreen.Canvas.Pen.Color := UICOLOUR;
  (* Draw Attack amount *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 105, UITEXTCOLOUR, 'Attack:  ' +
    IntToStr(entities.entityList[0].attack));
end;

procedure updateDefence;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 60, sby + 125, sbx + 135, sby + 145);
  main.tempScreen.Canvas.Pen.Color := UICOLOUR;
  (* Draw Defence amount *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 125, UITEXTCOLOUR, 'Defence:  ' +
    IntToStr(entities.entityList[0].defense));
end;

procedure updateWeapon(weaponName: shortstring);
begin
  main.tempScreen.Canvas.Font.Size := 10;
  (* Paint over previous text *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 8, eqy + 25, sbx + 135, eqy + 40);
  if (weaponName = 'none') then
  begin
    writeToBuffer(sbx + 8, eqy + 25, MESSAGEFADE2, 'No weapon equipped');
  end
  else
  begin
    writeToBuffer(sbx + 8, eqy + 25, UITEXTCOLOUR, weaponName);
  end;
end;

procedure updateArmour(armourName: shortstring);
begin
  main.tempScreen.Canvas.Font.Size := 10;
  (* Paint over previous text *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 8, eqy + 45, sbx + 135, eqy + 60);
  if (armourName = 'none') then
  begin
    writeToBuffer(sbx + 8, eqy + 45, MESSAGEFADE2, 'No armour equipped');
  end
  else
  begin
    writeToBuffer(sbx + 8, eqy + 45, UITEXTCOLOUR, armourName);
  end;
end;

procedure displayLook(entityName: shortstring; currentHP, maxHP: smallint);
begin
  (* Paint over previous text *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 3, infoy + 20, sbx + 135, infoy + 98);
  main.tempScreen.Canvas.Font.Size := 10;
  (* Display entity name *)
  writeToBuffer(sbx + 5, infoy + 30, UITEXTCOLOUR, entityName);
  (* Display health *)
  writeToBuffer(sbx + 5, infoy + 50, UITEXTCOLOUR, 'Health: ' +
    IntToStr(currentHP) + ' / ' + IntToStr(maxHP));
end;

procedure displayMessage(message: string);
begin
  (* Catch duplicate messages *)
  if (message = messageArray[1]) then
  begin
    main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
    messageArray[1] := messageArray[1] + ' x2';
    main.tempScreen.Canvas.Font.Size := 9;
    writeToBuffer(10, 410, UITEXTCOLOUR, messageArray[1]);
  end
  else
  begin
    (* Clear the message log *)
    main.tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
    main.tempScreen.Canvas.FillRect(5, 410, 833, 550);
    (* Shift all messages down one line *)
    messageArray[7] := messageArray[6];
    messageArray[6] := messageArray[5];
    messageArray[5] := messageArray[4];
    messageArray[4] := messageArray[3];
    messageArray[3] := messageArray[2];
    messageArray[2] := messageArray[1];
    messageArray[1] := message;
    (* Display each line, gradually getting darker *)
    main.tempScreen.Canvas.Font.Size := 9;
    writeToBuffer(10, 410, UITEXTCOLOUR, messageArray[1]);
    writeToBuffer(10, 430, MESSAGEFADE1, messageArray[2]);
    writeToBuffer(10, 450, MESSAGEFADE2, messageArray[3]);
    writeToBuffer(10, 470, MESSAGEFADE3, messageArray[4]);
    writeToBuffer(10, 490, MESSAGEFADE4, messageArray[5]);
    writeToBuffer(10, 510, MESSAGEFADE5, messageArray[6]);
    writeToBuffer(10, 530, MESSAGEFADE6, messageArray[7]);
  end;
end;

{ TODO : If buffered message is longer than a certain length, flush the buffer with writeBuffer procedure }
procedure bufferMessage(message: string);
begin
  buffer := buffer + message + '. ';
end;

procedure writeBufferedMessages;
begin
  if (buffer <> '') then
    displayMessage(buffer);
  buffer := '';
end;

procedure exitPrompt;
begin
  main.tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.Font.Size := 9;
  writeToBuffer(10, 410, clWhite,
    'Exit game?      [Q] - Quit game    |    [X] - Exit to main menu    |    [ESC] - Return to game');
end;

procedure rewriteTopMessage;
begin
  // rewrite message at top of log *)
  main.tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(5, 410, 833, 429);
  main.tempScreen.Canvas.Font.Size := 9;
  writeToBuffer(10, 410, UITEXTCOLOUR, messageArray[1]);
end;

procedure clearLog;
begin
  messageArray[7] := ' ';
  messageArray[6] := ' ';
  messageArray[5] := ' ';
  messageArray[4] := ' ';
  messageArray[3] := ' ';
  messageArray[2] := ' ';
  messageArray[1] := ' ';
end;

end.
