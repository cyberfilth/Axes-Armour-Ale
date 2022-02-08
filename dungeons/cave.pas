(* Generate a cave using two passes of a cellular automata algorithm and then
   remove any unreachable areas by floodfilling the map and discarding maps that
   are less than 39% floor tiles. Stairs are placed on the top level and a
   connecting stairway is placed on the floor below. If the floor below has a
   wall tile where the stair should be, that floor is discarded and generated
   again. *)

unit cave;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}
{$IFOPT D+} {$DEFINE DEBUG} {$ENDIF}

interface

uses
  SysUtils, globalutils, Classes;

const
  BLOCKVALUE = 99;

type
  TDist = array [1..MAXROWS, 1..MAXCOLUMNS] of integer;
  Tbkinds = (bWall, bClear);

var
  terrainArray, tempArray, tempArray2: array[1..MAXROWS, 1..MAXCOLUMNS] of shortstring;
  r, c, i, iterations, tileCounter, stairX, stairY: smallint;
  totalRooms: byte;
  distances: TDist;
  (* TESTING - Write cavern to text file *)
  filename: ShortString;
  myfile: Text;

(* Fill array with walls *)
procedure fillWithWalls;
(* Fill array with random tiles *)
procedure randomTileFill;
(* Dig out the cave *)
procedure digCave(floorNumber: byte);
(* Generate a caves and place the stairs *)
procedure generate(idNumber: smallint; totalDepth: byte);
(* Determines if a tile is a wall or not *)
function blockORnot(x, y: integer): Tbkinds;
(* Floodfill cave to find unreachable areas *)
procedure calcDistances(x, y: smallint);
(* Check that the left side of the map contains floor tiles *)
function leftHasFloor(): boolean;
(* Check that the right side of the map contains floor tiles *)
function rightHasFloor(): boolean;

implementation

uses
  map, universe, file_handling;

procedure fillWithWalls;
begin
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      terrainArray[r][c] := '*';
    end;
  end;
end;

procedure randomTileFill;
begin
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      (* 45% chance of drawing a wall tile *)
      if (Random(100) <= 45) then
        terrainArray[r][c] := '*'
      else
        terrainArray[r][c] := '.';
    end;
  end;
end;

procedure digCave(floorNumber: byte);
var
  numOfFloorTiles: smallint;
begin
  numOfFloorTiles := 0;
  repeat

    fillWithWalls;
    randomTileFill;

    (* Run through cave generator process 5 times *)
    for iterations := 1 to 5 do
    begin
      for r := 1 to MAXROWS do
      begin
        for c := 1 to MAXCOLUMNS do
        begin
          (* Generate landmass *)
          tileCounter := 0;
          if (terrainArray[r - 1][c] = '*') then // NORTH
            Inc(tileCounter);
          if (terrainArray[r - 1][c + 1] = '*') then // NORTH EAST
            Inc(tileCounter);
          if (terrainArray[r][c + 1] = '*') then // EAST
            Inc(tileCounter);
          if (terrainArray[r + 1][c + 1] = '*') then // SOUTH EAST
            Inc(tileCounter);
          if (terrainArray[r + 1][c] = '*') then // SOUTH
            Inc(tileCounter);
          if (terrainArray[r + 1][c - 1] = '*') then // SOUTH WEST
            Inc(tileCounter);
          if (terrainArray[r][c - 1] = '*') then // WEST
            Inc(tileCounter);
          if (terrainArray[r - 1][c - 1] = '*') then // NORTH WEST
            Inc(tileCounter);
          (* Set tiles in temporary array *)
          if (terrainArray[r][c] = '*') then
          begin
            if (tileCounter >= 4) then
              tempArray[r][c] := '*'
            else
              tempArray[r][c] := '.';
          end;
          if (terrainArray[r][c] = '.') then
          begin
            if (tileCounter >= 5) then
              tempArray[r][c] := '*'
            else
              tempArray[r][c] := '.';
          end;
        end;
      end;
    end;

    (* Start second cave *)
    fillWithWalls;
    randomTileFill;

    (* Run through cave generator process 5 times *)
    for iterations := 1 to 5 do
    begin
      for r := 1 to MAXROWS do
      begin
        for c := 1 to MAXCOLUMNS do
        begin
          (* Generate landmass *)
          tileCounter := 0;
          if (terrainArray[r - 1][c] = '*') then // NORTH
            Inc(tileCounter);
          if (terrainArray[r - 1][c + 1] = '*') then // NORTH EAST
            Inc(tileCounter);
          if (terrainArray[r][c + 1] = '*') then // EAST
            Inc(tileCounter);
          if (terrainArray[r + 1][c + 1] = '*') then // SOUTH EAST
            Inc(tileCounter);
          if (terrainArray[r + 1][c] = '*') then // SOUTH
            Inc(tileCounter);
          if (terrainArray[r + 1][c - 1] = '*') then // SOUTH WEST
            Inc(tileCounter);
          if (terrainArray[r][c - 1] = '*') then // WEST
            Inc(tileCounter);
          if (terrainArray[r - 1][c - 1] = '*') then // NORTH WEST
            Inc(tileCounter);
          (* Set tiles in temporary array *)
          if (terrainArray[r][c] = '*') then
          begin
            if (tileCounter >= 4) then
              tempArray2[r][c] := '*'
            else
              tempArray2[r][c] := '.';
          end;
          if (terrainArray[r][c] = '.') then
          begin
            if (tileCounter >= 5) then
              tempArray2[r][c] := '*'
            else
              tempArray2[r][c] := '.';
          end;
        end;
      end;
    end;

    (* Copy temporary map back to main dungeon map array *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        if (tempArray[r][c] = '*') and (tempArray2[r][c] = '*') then
          terrainArray[r][c] := '.'
        else if (tempArray[r][c] = '.') and (tempArray2[r][c] = '.') then
        begin
          if (terrainArray[r][c] = '*') then
            terrainArray[r][c] := '*'
          else
            terrainArray[r][c] := '*';
        end
        else
          terrainArray[r][c] := '.';
      end;
    end;
    (* draw top and bottom border *)
    for i := 1 to MAXCOLUMNS do
    begin
      terrainArray[1][i] := '*';
      terrainArray[MAXROWS][i] := '*';
    end;
    (* draw left and right border *)
    for i := 1 to MAXROWS do
    begin
      terrainArray[i][1] := '*';
      terrainArray[i][MAXCOLUMNS] := '*';
    end;

    (* Total rooms is used to calculate the number of NPC's *)
    totalRooms := Random(5) + 10; // between 10 - 15 rooms

    (* First floor only, set player start coordinates *)
    if (floorNumber = 1) then
    begin
      repeat
        map.startX := Random(19) + 1;
        map.startY := Random(19) + 1;
      until terrainArray[map.startY][map.startX] = '.';
    end;

    (* Flood fill the map, removing any areas that can't be reached *)
    { Initialise distance map }
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        distances[r, c] := BLOCKVALUE;
      end;
    end;

    calcDistances(map.startX, map.startY);
    (* Floodfill the map *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        terrainArray[r][c] := IntToStr(distances[r, c]);
      end;
    end;

    (* Change unreachable areas to walls *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        if (terrainArray[r][c] = '99') then
          terrainArray[r][c] := '*'
        else
          terrainArray[r][c] := '.';
      end;
    end;
    (* End of floodfill   *)

    (* Cave generator will discard levels that are less than 39% walkable *)
    for r := 1 to globalutils.MAXROWS do
    begin
      for c := 1 to globalutils.MAXCOLUMNS do
      begin
        if (terrainArray[r][c] = '.') then
          Inc(numOfFloorTiles);
      end;
    end;

  until (numOfFloorTiles > 1000) and (leftHasFloor() = True) and
    (rightHasFloor() = True);

end;

procedure generate(idNumber: smallint; totalDepth: byte);
var
  i: byte;
begin
  for i := 1 to totalDepth do
  begin
    digCave(i);
    { First floor only }
    if (i = 1) then
    begin
      (* Upper stairs, placed on players starting location *)
      terrainArray[map.startY][map.startX] := '<';

      (* Down stairs, choose random location on the right side map *)
      repeat
        r := globalutils.randomRange(3, MAXROWS);
        c := globalutils.randomRange((MAXCOLUMNS div 2), MAXCOLUMNS);
      until (terrainArray[r][c] = '.');
      (* Place the stairs *)
      terrainArray[r][c] := '>';

      (* Save location of stairs *)
      stairX := c;
      stairY := r;
      (* write the first level to universe.currentDungeon *)
      for r := 1 to globalUtils.MAXROWS do
      begin
        for c := 1 to globalUtils.MAXCOLUMNS do
        begin
          universe.currentDungeon[r][c] := terrainArray[r][c];
        end;
      end;
      universe.totalRooms := totalRooms;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tCave);
    end
    { If the floor number is an odd number }
    else if (Odd(i)) and (i <> totalDepth) then
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        digCave(i);
      until terrainArray[stairY][stairX] = '.';
      terrainArray[stairY][stairX] := '<';
      (* Down stairs, choose random location on the right side map *)
      repeat
        r := globalutils.randomRange(3, MAXROWS);
        c := globalutils.randomRange((MAXCOLUMNS div 2), MAXCOLUMNS);
      until (terrainArray[r][c] = '.');
      (* Place the stairs *)
      terrainArray[r][c] := '>';
      (* Save location of stairs *)
      stairX := c;
      stairY := r;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tCave);
    end
    else if not (Odd(i)) and (i <> totalDepth) then
      { If the floor number is an even number }
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        digCave(i);
      until terrainArray[stairY][stairX] = '.';
      terrainArray[stairY][stairX] := '<';
      (* Down stairs, choose random location on the left side map *)
      repeat
        r := globalutils.randomRange(1, MAXROWS);
        c := globalutils.randomRange(1, (MAXCOLUMNS div 2));
      until (terrainArray[r][c] = '.');
      (* Place the stairs *)
      terrainArray[r][c] := '>';
      (* Save location of stairs *)
      stairX := c;
      stairY := r;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tCave);
    end
    else
      (* Last floor *)
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        digCave(i);
      until terrainArray[stairY][stairX] = '.';
      terrainArray[stairY][stairX] := '<';
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tCave);
    end;


    { Write map to text file for testing }
   (* filename := 'cave_level_' + IntToStr(i) + '.txt';
    AssignFile(myfile, filename);
    rewrite(myfile);
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        Write(myfile, terrainArray[r][c]);
      end;
      Write(myfile, sLineBreak);
    end;
    closeFile(myfile);    *)
    { end of writing map to text file }

  end;
end;

function blockORnot(x, y: integer): Tbkinds;
begin
  if (terrainArray[y][x] = '*') then
    Result := bWall
  else if (terrainArray[y][x] = '.') then
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
    r: array[1..4] of tpoint =  (* the four directions of movement *)
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

function leftHasFloor(): boolean;
var
  r, c: smallint;
begin
  Result := False;
  for r := 3 to MAXROWS do
  begin
    for c := 3 to (MAXCOLUMNS div 2) do
    begin
      if (terrainArray[r][c] = '.') then
        Result := True;
    end;
  end;
end;

function rightHasFloor(): boolean;
var
  r, c: smallint;
begin
  Result := False;
  for r := 3 to MAXROWS do
  begin
    for c := (MAXCOLUMNS div 2) to MAXCOLUMNS do
    begin
      if (terrainArray[r][c] = '.') then
        Result := True;
    end;
  end;
end;

end.
