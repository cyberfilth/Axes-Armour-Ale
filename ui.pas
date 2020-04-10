(* User Interface - Unit responsible for displaying messages and stats *)

unit ui;

{$mode objfpc}{$H+}

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
  sbh = 380;

var
  messageArray: array[1..7] of string = (' ', ' ', ' ', ' ', ' ', ' ', ' ');
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
(* Write text to the message log *)
procedure displayMessage(message: string);
(* Display Quit Game confirmation *)
procedure exitPrompt;
(* Rewrite message at top of log *)
procedure rewriteTopMessage;
(* Clear message log *)
procedure clearLog;

implementation

uses
  main, player;

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
  main.tempScreen.Canvas.Rectangle(sbx, sby, sbx + sbw, sby + sbh);
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 5, UITEXTCOLOUR, ThePlayer.playerName);
  updateLevel;
  updateXP;
  updateHealth;
  updateAttack;
  updateDefence;
end;

procedure updateLevel;
begin
  (* Select players title *)
  if (ThePlayer.experience <= 10) then
    ThePlayer.title := 'the Worthless'
  else if (ThePlayer.experience > 10) then
    ThePlayer.title := 'the Brawler';
  (* Paint over previous title *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 8, sby + 25, sbx + 135, sby + 45);
  (* Write title to screen *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 25, UITEXTCOLOUR, ThePlayer.title);
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
    IntToStr(ThePlayer.experience));
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
    IntToStr(ThePlayer.currentHP) + ' / ' + IntToStr(ThePlayer.maxHP));
  (* Draw health bar *)
  main.tempScreen.Canvas.Brush.Color := $2E2E00; // Background colour
  main.tempScreen.Canvas.FillRect(sbx + 8, sby + 95, sbx + 108, sby + 100);
  (* Calculate percentage of total health *)
  healthPercentage := (ThePlayer.currentHP * 100) div ThePlayer.maxHP;
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
    IntToStr(ThePlayer.attack));
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
    IntToStr(ThePlayer.defense));
end;

procedure displayMessage(message: string);
begin
  (* Catch duplicate messages *)
  if (message = messageArray[1]) then
  begin
    main.tempScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
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
