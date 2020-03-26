(* Common functions / utilities *)

unit globalutils;

{$mode objfpc}{$H+}

interface

uses
  Graphics;

type
  coordinates = record
    x, y: smallint;
  end;

const
  (* Version info - a = Alpha, d = Debug, r = Release *)
  VERSION = '18a';
  (* Columns of the game map *)
  MAXCOLUMNS = 67;
  (* Rows of the game map *)
  MAXROWS = 38;
  (* Colours *)
  BACKGROUNDCOLOUR = TColor($131A00);
  UICOLOUR = TColor($808000);
  UITEXTCOLOUR = TColor($F5F58C);
  MESSAGEFADE1 = TColor($A0A033);
  MESSAGEFADE2 = TColor($969613);
  MESSAGEFADE3 = TColor($808000);
  MESSAGEFADE4 = TColor($686800);
  MESSAGEFADE5 = TColor($4F4F00);
  MESSAGEFADE6 = TColor($2E2E00);

var
  dungeonArray: array[1..MAXROWS, 1..MAXCOLUMNS] of char;
  (* Number of rooms in the current dungeon *)
  currentDgnTotalRooms: smallint;
  (* list of coordinates of centre of each room *)
  currentDgncentreList: array of coordinates;

(* Select random number from a range *)
function randomRange(fromNumber, toNumber: smallint): smallint;
(* Draw image to temporary screen buffer *)
procedure drawToBuffer(x, y: smallint; image: TBitmap);
(* Write text to temporary screen buffer *)
procedure writeToBuffer(x, y: smallint; messageColour: TColor; message: string);
(* Draw an NPC to temporary screen buffer *)
procedure drawNPCtoBuffer(x, y: smallint; glyphTextColour: TColor; glyphCharacter: char);

implementation

uses
  main, map;

// Random(Range End - Range Start) + Range Start
function randomRange(fromNumber, toNumber: smallint): smallint;
var
  p: smallint;
begin
  p := toNumber - fromNumber;
  Result := random(p + 1) + fromNumber;
end;

procedure drawToBuffer(x, y: smallint; image: TBitmap);
begin
  main.tempScreen.Canvas.Draw(x, y, image);
end;

procedure writeToBuffer(x, y: smallint; messageColour: TColor; message: string);
begin
  main.tempScreen.Canvas.Font.Color := messageColour;
  main.tempScreen.Canvas.TextOut(x, y, message);
end;

procedure drawNPCtoBuffer(x, y: smallint; glyphTextColour: TColor; glyphCharacter: char);
begin
  main.tempScreen.Canvas.Brush.Style := bsClear;
  main.tempScreen.Canvas.Font.Color := glyphTextColour;
  main.tempScreen.Canvas.TextOut(map.mapToScreen(x), (map.mapToScreen(y) + 1) -
    (tileSize div 2), glyphCharacter);
  (* Add a duplicate glyph, slightly offset, to make the glyph bold *)
  main.tempScreen.Canvas.TextOut(map.mapToScreen(x)+1, (map.mapToScreen(y) + 1) - (tileSize div 2), glyphCharacter);
end;

end.
