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
(* Update player health display *)
procedure updateHealth;
(* Update player attack value *)
procedure updateAttack;
(* Update player defence value *)
procedure updateDefence;
(* Write text to the message log *)
procedure displayMessage(message: string);

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
  writeToBuffer(sbx + 50, sby + 5, UICOLOUR, 'Player');
  updateHealth;
  updateAttack;
  updateDefence;
end;

procedure updateHealth;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 33, sby + 40, sbx + 135, sby + 60);
  (* Draw Health amount *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 40, UITEXTCOLOUR, 'Health:  ' +
    IntToStr(ThePlayer.currentHP) + ' / ' + IntToStr(player.ThePlayer.maxHP));
end;

procedure updateAttack;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 50, sby + 60, sbx + 135, sby + 80);
  main.tempScreen.Canvas.Pen.Color := UICOLOUR;
  (* Draw Attack amount *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 60, UITEXTCOLOUR, 'Attack:  ' +
    IntToStr(ThePlayer.attack));
end;

procedure updateDefence;
begin
  (* Paint over previous stats *)
  main.tempScreen.Canvas.Brush.Color := BACKGROUNDCOLOUR;
  main.tempScreen.Canvas.FillRect(sbx + 60, sby + 80, sbx + 135, sby + 100);
  main.tempScreen.Canvas.Pen.Color := UICOLOUR;
  (* Draw Defence amount *)
  main.tempScreen.Canvas.Font.Size := 10;
  writeToBuffer(sbx + 8, sby + 80, UITEXTCOLOUR, 'Defence:  ' +
    IntToStr(ThePlayer.defense));
end;

procedure displayMessage(message: string);
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

end.
