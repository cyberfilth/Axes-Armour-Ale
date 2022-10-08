(* Builds a map of randomly placed rooms with prefab rooms *)

unit crypt;

{$mode fpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, globalUtils;

type
  coordinates = record
    x, y: smallint;
  end;

const
  PREFAB_4X4a: array [1..4, 1..4] of char = (
    ('#', '.', '.', '#'),
    ('.', '.', '.', '.'),
    ('.', '.', '.', '.'),
    ('#', '.', '.', '#'));
  PREFAB_5x4a: array [1..4, 1..5] of char = (
    ('#', '#', '.', '#', '#'),
    ('#', '.', '.', '.', '#'),
    ('#', '.', '.', '.', '#'),
    ('#', '#', '.', '#', '#'));
  PREFAB_5x4b: array [1..4, 1..5] of char = (
    ('#', '.', '.', '.', '#'),
    ('.', '#', '.', '#', '.'),
    ('.', '.', '.', '.', '.'),
    ('#', '.', '.', '.', '#'));
  PREFAB_5x5a: array [1..5, 1..5] of char = (
    ('#', '.', '.', '.', '#'),
    ('.', '#', '.', '#', '.'),
    ('.', '.', '.', '.', '.'),
    ('.', '#', '.', '#', '.'),
    ('#', '.', '.', '.', '#'));
  PREFAB_6x6a: array [1..6, 1..6] of char = (
    ('#', '#', '.', '.', '#', '#'),
    ('#', '.', '.', '.', '.', '#'),
    ('.', '.', '.', '.', '.', '.'),
    ('.', '.', '.', '.', '.', '.'),
    ('#', '.', '.', '.', '.', '#'),
    ('#', '#', '.', '.', '#', '#'));
  PREFAB_6x6b: array [1..6, 1..6] of char = (
    ('.', '.', '#', '#', '.', '.'),
    ('.', '.', '.', '.', '.', '.'),
    ('#', '.', '#', '#', '.', '#'),
    ('#', '.', '#', '#', '.', '#'),
    ('.', '.', '.', '.', '.', '.'),
    ('.', '.', '#', '#', '.', '.'));
  PREFAB_7x7a: array [1..7, 1..7] of char = (
    ('#', '#', '.', '.', '.', '#', '#'),
    ('#', '.', '.', '.', '.', '.', '#'),
    ('.', '.', '#', '.', '#', '.', '.'),
    ('.', '.', '.', '.', '.', '.', '.'),
    ('.', '.', '#', '.', '#', '.', '.'),
    ('#', '.', '.', '.', '.', '.', '#'),
    ('#', '#', '.', '.', '.', '#', '#'));
  PREFAB_7x7b: array [1..7, 1..7] of char = (
    ('#', '#', '#', '.', '#', '#', '#'),
    ('#', '.', '#', '.', '#', '.', '#'),
    ('#', '.', '#', '.', '#', '.', '#'),
    ('.', '.', '.', '.', '.', '.', '.'),
    ('#', '.', '#', '.', '#', '.', '#'),
    ('#', '.', '#', '.', '#', '.', '#'),
    ('#', '#', '#', '.', '#', '#', '#'));

var
  r, c, i, p, t, listLength, firstHalf, lastHalf: smallint;
  dungeonArray: array[1..globalutils.MAXROWS, 1..globalutils.MAXCOLUMNS] of char;
  processed_dungeon: array[1..globalutils.MAXROWS, 1..globalutils.MAXCOLUMNS] of char;
  totalRooms, roomSquare, stairX, stairY: smallint;
  (* start creating corridors once this rises above 1 *)
  roomCounter: smallint;
  (* list of coordinates of centre of each room *)
  centreList: array of coordinates;
  (* Player starting position *)
  startX, startY: smallint;
  (* TESTING - Write dungeon to text file *)
  filename: shortstring;
  myfile: Text;

(* Build a level in the dungeon *)
procedure buildLevel(floorNumber: byte);
(* Create corridors linking the rooms *)
procedure createCorridor(fromX, fromY, toX, toY: smallint);
(* Carve a horizontal tunnel *)
procedure carveHorizontally(x1, x2, y: smallint);
(* Carve a vertical tunnel *)
procedure carveVertically(y1, y2, x: smallint);
(* Create a room *)
procedure createRoom(gridNumber: smallint);
(* Generate a dungeon *)
procedure generate(title: string; idNumber: smallint; totalDepth: byte);
(* sort room list in order from left to right *)
procedure leftToRight;

implementation

uses
  universe, file_handling, map;

procedure buildLevel(floorNumber: byte);
var
  i2: byte;
begin
  roomCounter := 0;
  { initialise the array }
  SetLength(centreList, 1);
  { fill map with walls }
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      dungeonArray[r][c] := '#';
    end;
  end;
  { between 15 - 20 rooms }
  totalRooms := randomRange(15, 20);
  for i2 := 1 to totalRooms do
  begin
    { randomly choose grid location from 1 to 27 }
    roomSquare := randomRange(1, 27);
    createRoom(roomSquare);
    Inc(roomCounter);
  end;
  leftToRight;
  for i2 := 1 to (totalRooms - 1) do
  begin
    createCorridor(centreList[i2].x, centreList[i2].y, centreList[i2 + 1].x,
      centreList[i2 + 1].y);
  end;
  { connect random rooms so the map isn't totally linear
    from the first half of the room list }
  firstHalf := (totalRooms div 2);
  p := random(firstHalf - 1) + 1;
  t := random(firstHalf - 1) + 1;
  createCorridor(centreList[p].x, centreList[p].y, centreList[t].x,
    centreList[t].y);
  { from the second half of the room list }
  lastHalf := (totalRooms - firstHalf);
  p := random(lastHalf) + firstHalf;
  t := random(lastHalf) + firstHalf;
  createCorridor(centreList[p].x, centreList[p].y, centreList[t].x, centreList[t].y);

  { set player start coordinates }
  (* First floor only, set player start coordinates *)
  if (floorNumber = 1) then
  begin
    map.startX := centreList[1].x;
    map.startY := centreList[1].y;
  end;
end;

procedure createCorridor(fromX, fromY, toX, toY: smallint);
var
  direction: byte;
begin
  { flip a coin to decide whether to first go horizontally or vertically }
  direction := Random(2);
  { horizontally first }
  if direction = 1 then
  begin
    carveHorizontally(fromX, toX, fromY);
    carveVertically(fromY, toY, toX);
  end
  { vertically first }
  else
  begin
    carveVertically(fromY, toY, toX);
    carveHorizontally(fromX, toX, fromY);
  end;
end;

procedure carveHorizontally(x1, x2, y: smallint);
var
  x: byte;
begin
  if x1 < x2 then
  begin
    for x := x1 to x2 do
      dungeonArray[y][x] := '.';
  end;
  if x1 > x2 then
  begin
    for x := x2 to x1 do
      dungeonArray[y][x] := '.';
  end;
end;

procedure carveVertically(y1, y2, x: smallint);
var
  y: byte;
begin
  if y1 < y2 then
  begin
    for y := y1 to y2 do
      dungeonArray[y][x] := '.';
  end;
  if y1 > y2 then
  begin
    for y := y2 to y1 do
      dungeonArray[y][x] := '.';
  end;
end;

procedure createRoom(gridNumber: smallint);
var
  topLeftX, topLeftY, roomHeight, roomWidth, drawHeight, drawWidth,
  nudgeDown, nudgeAcross: smallint;
begin

(* Grids are unevenly spaced, so exact coordinates are used. 'Nudge' is used to
change starting point of each room so they don't all start drawing from the top left corner *)
  nudgeDown := 0;
  nudgeAcross := 0;
  topLeftX := 0;
  topLeftY := 0;
  roomHeight := 0;
  roomWidth := 0;
  case gridNumber of
    1:
    begin
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 6);
      topLeftX := 2;
      topLeftY := 2;
    end;
    2:
    begin
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 8);
      topLeftX := 10;
      topLeftY := 2;
    end;
    3:
    begin
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 7);
      topLeftX := 20;
      topLeftY := 2;
    end;
    4:
    begin
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 7);
      topLeftX := 29;
      topLeftY := 2;
    end;
    5:
    begin
      topLeftX := 38;
      topLeftY := 2;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 7);
    end;
    6:
    begin
      topLeftX := 47;
      topLeftY := 2;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 7);
    end;
    7:
    begin
      topLeftX := 56;
      topLeftY := 2;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 7);
    end;
    8:
    begin
      topLeftX := 65;
      topLeftY := 2;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 6);
    end;
    9:
    begin
      topLeftX := 73;
      topLeftY := 2;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(2, 7);
    end;
    10:
    begin
      topLeftX := 2;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 6);
    end;
    11:
    begin
      topLeftX := 10;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 8);
    end;
    12:
    begin
      topLeftX := 20;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 7);
    end;
    13:
    begin
      topLeftX := 29;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 7);
    end;
    14:
    begin
      topLeftX := 38;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 7);
    end;
    15:
    begin
      topLeftX := 47;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 7);
    end;
    16:
    begin
      topLeftX := 56;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 7);
    end;
    17:
    begin
      topLeftX := 65;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 6);
    end;
    18:
    begin
      topLeftX := 73;
      topLeftY := 8;
      roomHeight := randomRange(4, 6);
      roomWidth := randomRange(4, 7);
    end;
    19:
    begin
      topLeftX := 2;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 6);
    end;
    20:
    begin
      topLeftX := 10;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 8);
    end;
    21:
    begin
      topLeftX := 20;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 7);
    end;
    22:
    begin
      topLeftX := 29;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 7);
    end;
    23:
    begin
      topLeftX := 38;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 7);
    end;
    24:
    begin
      topLeftX := 47;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 7);
    end;
    25:
    begin
      topLeftX := 56;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 7);
    end;
    26:
    begin
      topLeftX := 65;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 6);
    end;
    27:
    begin
      topLeftX := 73;
      topLeftY := 16;
      roomHeight := randomRange(2, 4);
      roomWidth := randomRange(3, 7);
    end;
  end;

  if (roomHeight = 2) then
    nudgeDown := randomRange(0, 2)
  else if (roomHeight = 3) then
    nudgeDown := randomRange(0, 1);
  if (roomWidth = 2) then
    nudgeAcross := randomRange(0, 2)
  else if (roomWidth = 3) then
    nudgeAcross := randomRange(0, 1);

  (* Save coordinates of the centre of the room *)
  listLength := Length(centreList);
  SetLength(centreList, listLength + 1);
  centreList[listLength].x := (topLeftX + nudgeAcross) + (roomWidth div 2);
  centreList[listLength].y := (topLeftY + nudgeDown) + (roomHeight div 2);
  (* Draw room within the grid square *)
  /// add prefabs here
  for drawHeight := 0 to roomHeight do
  begin
    for drawWidth := 0 to roomWidth do
    begin
      dungeonArray[(topLeftY + nudgeDown) + drawHeight][
        (topLeftX + nudgeAcross) + drawWidth] := '.';
    end;
  end;
end;

procedure generate(title: string; idNumber: smallint; totalDepth: byte);
var
  i, i2: byte;
begin
  for i := 1 to totalDepth do
  begin
    buildLevel(i);
    { First floor only }
    if (i = 1) then
    begin

      (* Place a marker in the centre of each room *)
      for i2 := 1 to (totalRooms - 1) do
      begin
        dungeonArray[centreList[i2].y][centreList[i2].x] := 'X';
      end;

      (* Upper stairs, placed on players starting location *)
      dungeonArray[map.startY][map.startX] := '<';

      (* Down stairs, choose random location on the right side map *)
      repeat
        r := globalutils.randomRange(3, MAXROWS);
        c := globalutils.randomRange((MAXCOLUMNS div 2), MAXCOLUMNS);
      until (dungeonArray[r][c] = '.');
      (* Place the stairs *)
      dungeonArray[r][c] := '>';

      (* Save location of stairs *)
      stairX := c;
      stairY := r;

      (* write the first level to universe.currentDungeon *)
      for r := 1 to globalUtils.MAXROWS do
      begin
        for c := 1 to globalUtils.MAXCOLUMNS do
        begin
          universe.currentDungeon[r][c] := processed_dungeon[r][c];
        end;
      end;
      universe.totalRooms := totalRooms;
      file_handling.writeNewDungeonLevel(title, idNumber, i, totalDepth, totalRooms, tDungeon);
    end
    { If the floor number is an odd number }
    else if (Odd(i)) and (i <> totalDepth) then
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        buildLevel(i);
      until dungeonArray[stairY][stairX] = '.';
      dungeonArray[stairY][stairX] := '<';
      (* Down stairs, choose random location on the right side map *)
      repeat
        r := globalutils.randomRange(3, MAXROWS);
        c := globalutils.randomRange((MAXCOLUMNS div 2), MAXCOLUMNS);
      until (dungeonArray[r][c] = '.');

      (* Place a marker in the centre of each room *)
      for i2 := 1 to (totalRooms - 1) do
      begin
        dungeonArray[centreList[i2].y][centreList[i2].x] := 'X';
      end;

      (* Place the stairs *)
      dungeonArray[r][c] := '>';
      (* Save location of stairs *)
      stairX := c;
      stairY := r;

      file_handling.writeNewDungeonLevel(title, idNumber,
        i, totalDepth, totalRooms,
        tDungeon);
    end
    else if not (Odd(i)) and (i <> totalDepth) then
      { If the floor number is an even number }
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        buildLevel(i);
      until dungeonArray[stairY][stairX] = '.';
      dungeonArray[stairY][stairX] := '<';
      (* Down stairs, choose random location on the left side map *)
      repeat
        r := globalutils.randomRange(1, MAXROWS);
        c := globalutils.randomRange(1, (MAXCOLUMNS div 2));
      until (dungeonArray[r][c] = '.');

      (* Place a marker in the centre of each room *)
      for i2 := 1 to (totalRooms - 1) do
      begin
        dungeonArray[centreList[i2].y][centreList[i2].x] := 'X';
      end;

      (* Place the stairs *)
      dungeonArray[r][c] := '>';
      (* Save location of stairs *)
      stairX := c;
      stairY := r;

      file_handling.writeNewDungeonLevel(title, idNumber,
        i, totalDepth, totalRooms,
        tDungeon);
    end
    else
      (* Last floor *)
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        buildLevel(i);
      until dungeonArray[stairY][stairX] = '.';

      (* Place a marker in the centre of each room *)
      for i2 := 1 to (totalRooms - 1) do
      begin
        dungeonArray[centreList[i2].y][centreList[i2].x] := 'X';
      end;

      dungeonArray[stairY][stairX] := '<';

      file_handling.writeNewDungeonLevel(title, idNumber, i,
        totalDepth, totalRooms, tDungeon);
    end;

    /////////////////////////////
    // Write map to text file for testing
    //filename := 'dungeon_level_' + IntToStr(i) + '.txt';
    //AssignFile(myfile, filename);
    //rewrite(myfile);
    //for r := 1 to MAXROWS do
    //begin
    //  for c := 1 to MAXCOLUMNS do
    //  begin
    //    Write(myfile, dungeonArray[r][c]);
    //  end;
    //  Write(myfile, sLineBreak);
    //end;
    //closeFile(myfile);
    ////////////////////////////////
  end;
end;

procedure leftToRight;
var
  i, j, n, tempX, tempY: smallint;
begin
  n := length(centreList) - 1;
  for i := n downto 2 do
    for j := 0 to i - 1 do
      if centreList[j].x > centreList[j + 1].x then
      begin
        tempX := centreList[j].x;
        tempY := centreList[j].y;
        centreList[j].x := centreList[j + 1].x;
        centreList[j].y := centreList[j + 1].y;
        centreList[j + 1].x := tempX;
        centreList[j + 1].y := tempY;
      end;
end;

end.
