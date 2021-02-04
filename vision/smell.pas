(* Smell map, a copy of the map is floodfilled with integers.
   Each integer increments the further away it is from the player.
   Creatures can then track the player by finding a tile with a lower number
   than the one that they're standing on *)

unit smell;

{$mode objfpc}{$H+}

interface

uses
  globalutils;

var
  dungeonCopy: array[1..MAXROWS, 1..MAXCOLUMNS] of char;
  smellmap: array[1..MAXROWS, 1..MAXCOLUMNS] of smallint;
  counter: smallint;
  (* TESTING - Write dungeon to text file *)
  filename: ShortString;
  myfile: Text;

(* Flood fill map with integers *)
procedure floodFill(r, c: smallint);
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

(* Fill immediate area *)
procedure floodFill(r, c: smallint);
begin
  if (counter < 500) then
  begin
    if (r >= 1) and (r <= MAXROWS) and (c >= 1) and (c <= MAXCOLUMNS) then
    begin
      if (dungeonCopy[r][c] = ':') and (smellmap[r][c] > counter) then
      begin
        smellmap[r][c] := counter;
        dungeonCopy[r][c] := '*';
        counter := counter + 1;
      end
      else
        exit;
      floodFill(r + 1, c);
      floodFill(r - 1, c);
      floodFill(r, c + 1);
      floodFill(r, c - 1);
    end;
  end;
end;

procedure sniff;
var
  r, c: smallint;
begin
  // create a copy of the dungeon
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      dungeonCopy[r][c] := dungeonArray[r][c];
    end;
  end;
  // initialise smell map
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      smellmap[r][c] := 550;
    end;
  end;
  // generate smell map
  counter := 1;
  floodFill(entityList[0].posY, entityList[0].posX);
  /////////////////////////////
  //Write map to text file for testing
  filename := 'smellmap.txt';
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
  closeFile(myfile);
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
