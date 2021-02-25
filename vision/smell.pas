(* Smell map, a copy of the map is floodfilled with integers.
   Each integer increments the further away it is from the player.
   Creatures can then track the player by finding a tile with a lower number
   than the one that they're standing on.

   The below routine is based on code from Stephen Peter (aka speter) *)

unit smell;

{$mode objfpc}{$H+}

interface

uses
  globalutils;

const
  (* used on the smell map to denote a wall *)
  BLOCKVALUE = 500;

type
  TDist = array [1..MAXROWS, 1..MAXCOLUMNS] of smallint;
  Tbkinds = (bWall, bClear);

var
  smellmap: array[1..MAXROWS, 1..MAXCOLUMNS] of smallint;
  distances: TDist;
  (* TESTING - Write smell map to text file *)
  filename: ShortString;
  myfile: Text;

(* Check if tile is a wall or not *)
function blockORnot(x, y: smallint): Tbkinds;
(* Calculate distance from player *)
procedure calcDistances(x, y: smallint);
(* Generate smell map *)
procedure sniff;
(* Check tile to the North *)
function sniffNorth(y, x: smallint): boolean;
(* Check tile to the East *)
function sniffEast(y, x: smallint): boolean;
(* Check tile to the South *)
function sniffSouth(y, x: smallint): boolean;
(* Check tile to the West *)
function sniffWest(y, x: smallint): boolean;

implementation

uses
  entities;

function blockORnot(x, y: smallint): Tbkinds;
begin
  if (dungeon[y][x] = '#') then
    Result := bWall
  else if (dungeon[y][x] = '.') then
    Result := bClear
  else
    Result := bWall;
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
    r: array[1..4] of tpoint =              // the four directions of movement
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

  /////////////////////////////
  //Write map to text file for testing
  //filename := 'smellmap.txt';
  //AssignFile(myfile, filename);
  //rewrite(myfile);
  //for r := 1 to MAXROWS do
  //begin
  //  for c := 1 to MAXCOLUMNS do
  //  begin
  //    Write(myfile, smellmap[r][c], ' ');
  //  end;
  //  Write(myfile, sLineBreak);
  //end;
  //closeFile(myfile);
  //////////////////////////////

end;

(* If the tile to the North has a lower value than current tile return true *)
function sniffNorth(y, x: smallint): boolean;
begin
  if (smellmap[y - 1][x] < smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

(* If the tile to the East has a lower value than current tile return true *)
function sniffEast(y, x: smallint): boolean;
begin
  if (smellmap[y][x + 1] < smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

(* If the tile to the South has a lower value than current tile return true *)
function sniffSouth(y, x: smallint): boolean;
begin
  if (smellmap[y + 1][x] < smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

(* If the tile to the West has a lower value than current tilem return true *)
function sniffWest(y, x: smallint): boolean;
begin
  if (smellmap[y][x - 1] < smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

end.
