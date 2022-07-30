(* Smell map, a copy of the map is floodfilled with integers.
   Each integer increments the further away it is from the player.
   Creatures can then track the player by finding a tile with a lower number
   than the one that they're standing on.

   The below routine is based on code from Stephen Peter (AKA speter) *)

unit smell;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
interface

uses
  SysUtils, Classes, Math, globalutils;

const
  (* used on the smell map to denote a wall *)
  BLOCKVALUE = 500;

type
  TDist = array [1..MAXROWS, 1..MAXCOLUMNS] of smallint;
  Tbkinds = (bNone, bWall, bClear);

var
  smellmap: array[1..MAXROWS, 1..MAXCOLUMNS] of smallint;
  distances: TDist;
  (* Tracks the scent decaying over time *)
  smellCounter: byte;

(* TESTING - Write smell map to text file *)
  { filename: shortstring;
  myfile: Text; }

function blockORnot(x, y: integer): Tbkinds;
(* Calculate distance from player *)
procedure calcDistances(x, y: smallint);
(* Generate smell map *)
procedure sniff;
(* Find the tile with the highest scent value *)
function scentDirection(y, x: smallint): char;
(* Get Coordinates of the tile with highest scent value *)
function scentDirectionCoords(y, x: smallint): TPoint;
(* Generate a path to the player *)
function pathFinding(id: smallint): path;

implementation

uses
  entities, map;

(* Check if tile is a wall or not *)
function blockORnot(x, y: integer): Tbkinds;
begin
  if (map.maparea[y][x].Glyph = '*') then
    Result := bWall
  else if (map.maparea[y][x].Glyph = '.') then
    Result := bClear
  else
    Result := bNone;
end;

procedure calcDistances(x, y: smallint);
(* Check within boundaries of map *)
  function rangeok(x, y: smallint): boolean;
  begin
    Result := (x in [2..MAXCOLUMNS - 1]) and (y in [2..MAXROWS - 1]);
  end;

  (* Set distance around current tile *)
  procedure setaround(x, y: smallint; d: smallint);
  const
    r: array[1..4] of tpoint =              { the four directions of movement }
      ((x: 0; y: -1), (x: 1; y: 0), (x: 0; y: 1), (x: -1; y: 0));
  var
    a: smallint;
    dx, dy: smallint;
  begin
    for a := 1 to 4 do
    begin
      dx := x + r[a].x;
      dy := y + r[a].y;
      if rangeok(dx, dy) and (blockORnot(dx, dy) = bClear) and
        (d < distances[dy, dx]) then
      begin
        distances[dy, dx] := d;
        setaround(dx, dy, d + 1);
      end;
    end;
  end;

begin
  distances[x, y] := 0;
  setaround(x, y, 1);
end;


procedure sniff;
begin
  (* Initialise distance map *)
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      distances[r, c] := BLOCKVALUE;
    end;
  end;
  (* flood map from players current position *)
  calcDistances(entityList[0].posX, entityList[0].posY);

  (* create smell map *)
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      smellmap[r][c] := distances[r, c];
    end;
  end;

  (* Set smell counter *)
  smellCounter := 5;

  // Write map to text file for testing
  (* filename := 'smellmap.txt';
  AssignFile(myfile, filename);
  rewrite(myfile);
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      Write(myfile, smellmap[r][c], ' ');
    end;
    Write(myfile, sLineBreak);
  end;
  closeFile(myfile);  *)
end;

function scentDirection(y, x: smallint): char;
var
  surroundingArea: array[0..3] of integer;
begin
  { Initialise Result }
  Result := 'n';
  if (smellCounter < 1) then
    (* Smell the surrounding area *)
    sniff;

  (* Find the tile with the strongest scent *)
  (* North *)
  surroundingArea[0] := smellmap[y - 1][x];
  (* South *)
  surroundingArea[1] := smellmap[y + 1][x];
  (* East *)
  surroundingArea[2] := smellmap[y][x + 1];
  (* West *)
  surroundingArea[3] := smellmap[y][x - 1];

  (* Return direction with strongest scent *)
  if (surroundingArea[0] = MinValue(surroundingArea)) then
    Result := 'n'
  else if (surroundingArea[1] = MinValue(surroundingArea)) then
    Result := 's'
  else if (surroundingArea[2] = MinValue(surroundingArea)) then
    Result := 'e'
  else if (surroundingArea[3] = MinValue(surroundingArea)) then
    Result := 'w';
end;

function scentDirectionCoords(y, x: smallint): TPoint;
var
  surroundingArea: array[0..7] of integer;
  choice: TPoint;
begin
  (* Find the tile with the strongest scent *)
  (* North *)
  surroundingArea[0] := smellmap[y - 1][x];
  (* North East *)
  surroundingArea[1] := smellmap[y - 1][x + 1];
  (* East *)
  surroundingArea[2] := smellmap[y][x + 1];
  (* South East *)
  surroundingArea[3] := smellmap[y + 1][x + 1];
  (* South *)
  surroundingArea[4] := smellmap[y + 1][x];
  (* South West *)
  surroundingArea[5] := smellmap[y + 1][x - 1];
  (* West *)
  surroundingArea[6] := smellmap[y][x - 1];
  (* West *)
  surroundingArea[7] := smellmap[y - 1][x - 1];

  (* Return direction with strongest scent *)
  (* North *)
  if (surroundingArea[0] = MinValue(surroundingArea)) then
  begin
    choice.X := x;
    choice.Y := y;
  end
  (* North East *)
  else if (surroundingArea[1] = MinValue(surroundingArea)) then
  begin
    choice.X := x + 1;
    choice.Y := y - 1;
  end
  (* East *)
  else if (surroundingArea[2] = MinValue(surroundingArea)) then
  begin
    choice.X := x + 1;
    choice.Y := y;
  end
  (* South East *)
  else if (surroundingArea[3] = MinValue(surroundingArea)) then
  begin
    choice.X := x + 1;
    choice.Y := y + 1;
  end
  (* South *)
  else if (surroundingArea[4] = MinValue(surroundingArea)) then
  begin
    choice.X := x;
    choice.Y := y + 1;
  end
  (* South West *)
  else if (surroundingArea[5] = MinValue(surroundingArea)) then
  begin
    choice.X := x - 1;
    choice.Y := y + 1;
  end
  (* West *)
  else if (surroundingArea[6] = MinValue(surroundingArea)) then
  begin
    choice.X := x - 1;
    choice.Y := y;
  end
  (* North West *)
  else if (surroundingArea[7] = MinValue(surroundingArea)) then
  begin
    choice.X := x - 1;
    choice.Y := y - 1;
  end;
  (* Output the coordinates *)
  Result := choice;
end;

function pathFinding(id: smallint): path;
var
  i: byte;
  pathCoords: path;
begin
  (* Initialise the array *)
  for i := 1 to 30 do
  begin
    pathCoords[i].X := 0;
    pathCoords[i].Y := 0;
  end;
  if (smellCounter <> 5) then
     sniff;
  (* Generate the path *)
  for i := 1 to 30 do
  begin
    (* Starting tile *)
    if (i = 1) then
       pathCoords[i] := scentDirectionCoords(entityList[id].posX, entityList[id].posY)
    else
    begin
    (* Check that path hasn't already reached target *)
    if (pathCoords[i - 1].X <> entityList[0].posX) and (pathCoords[i - 1].Y <> entityList[0].posY) then
    begin
         pathCoords[i] := scentDirectionCoords(pathCoords[i - 1].X, pathCoords[i - 1].Y);
    end;
    end;
  end;
  Result := pathCoords;
end;

end.
