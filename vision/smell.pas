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

(* Flood fill map with integers *)
procedure floodFill(r, c: smallint);
(* Generate smell map *)
procedure sniff;
(* Check tile to the North *)
procedure sniffNorth(y, x: smallint);
(* Check tile to the East *)
procedure sniffEast(y, x: smallint);
(* Check tile to the South *)
procedure sniffSouth(y, x: smallint);
(* Check tile to the West *)
procedure sniffWest(y, x: smallint);

implementation

uses
  entities;

procedure floodFill(r, c: smallint);
begin
  if (counter < 500) then
  begin
    if (r >= 1) and (r <= MAXROWS) and (c >= 1) and (c <= MAXCOLUMNS) then
    begin
      if (dungeonCopy[r][c] = '.') then
      begin
        smellmap[r][c] := counter;
        dungeonCopy[r][c] := '*';
        counter := counter + 1;
      end
      else
        exit;
      if (dungeonCopy[r + 1][c] = '.') then
        floodFill(r + 1, c);
      if (dungeonCopy[r - 1][c] = '.') then
        floodFill(r - 1, c);
      if (dungeonCopy[r][c + 1] = '.') then
        floodFill(r, c + 1);
      if (dungeonCopy[r][c - 1] = '.') then
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
  // generate smell map
  counter := 0;
  floodFill(entityList[0].posY, entityList[0].posX);
end;

procedure sniffNorth(y, x: smallint);
begin
  if (smellmap[y - 1][x] > smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

procedure sniffEast(y, x: smallint);
begin
  if (smellmap[y][x + 1] > smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

procedure sniffSouth(y, x: smallint);
begin
  if (smellmap[y + 1][x] > smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

procedure sniffWest(y, x: smallint);
begin
  if (smellmap[y][x - 1] > smellmap[y][x]) then
    Result := True
  else
    Result := False;
end;

end.

