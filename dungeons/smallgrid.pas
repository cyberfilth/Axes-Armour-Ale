(* Generates a grid based dungeon with wide spaces between rooms, this is then processed to apply bitmasked walls *)

unit smallGrid;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, globalutils;

type
  coordinates = record
    x, y: smallint;
  end;

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
  filename: ShortString;
  myfile: Text;

(* Process generated dungeon to add shaped walls *)
procedure prettify;
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
procedure generate(idNumber: smallint; totalDepth: byte);
(* sort room list in order from left to right *)
procedure leftToRight;

implementation

uses
  universe, file_handling, map;

procedure prettify;
var
  tileCounter: smallint;
  i2: byte;
begin
  { Redraw border around the map }
  for i2 := 1 to MAXCOLUMNS do
  begin
    dungeonArray[1][i2] := '#';
    dungeonArray[MAXROWS][i2] := '#';
  end;
  { draw left and right border }
  for i2 := 1 to MAXROWS do
  begin
    dungeonArray[i2][1] := '#';
    dungeonArray[i2][MAXCOLUMNS] := '#';
  end;

  (* First pass for adding the walls *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        tileCounter := 0;
        if (dungeonArray[r - 1][c] = '#') then // NORTH
          tileCounter := tileCounter + 1;
        if (dungeonArray[r][c + 1] = '#') then // EAST
          tileCounter := tileCounter + 4;
        if (dungeonArray[r + 1][c] = '#') then // SOUTH
          tileCounter := tileCounter + 8;
        if (dungeonArray[r][c - 1] = '#') then // WEST
          tileCounter := tileCounter + 2;
        case tileCounter of
          0: processed_dungeon[r][c] := 'A';
          1: processed_dungeon[r][c] := 'B';
          2: processed_dungeon[r][c] := 'C';
          3: processed_dungeon[r][c] := 'D';
          4: processed_dungeon[r][c] := 'E';
          5: processed_dungeon[r][c] := 'F';
          6: processed_dungeon[r][c] := 'G';
          7: processed_dungeon[r][c] := 'H';
          8: processed_dungeon[r][c] := 'I';
          9: processed_dungeon[r][c] := 'J';
          10: processed_dungeon[r][c] := 'K';
          11: processed_dungeon[r][c] := 'L';
          12: processed_dungeon[r][c] := 'M';
          13: processed_dungeon[r][c] := 'N';
          14: processed_dungeon[r][c] := 'O';
          15: processed_dungeon[r][c] := 'P';
          else
            processed_dungeon[r][c] := 'A';
        end;
      end
      else
        processed_dungeon[r][c] := '.';
  end;

  (* Top left corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r - 1][c] = '#') and (dungeonArray[r - 1][c + 1] = '#') and
          (dungeonArray[r][c + 1] = '#') and (dungeonArray[r + 1][c + 1] = '.') and
          (dungeonArray[r + 1][c] = '#') and (dungeonArray[r + 1][c - 1] = '#') and
          (dungeonArray[r][c - 1] = '#') and (dungeonArray[r - 1][c - 1] = '#') then
          processed_dungeon[r][c] := 'M';
      end;
  end;
  (* Top right corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r - 1][c] = '#') and (dungeonArray[r - 1][c + 1] = '#') and
          (dungeonArray[r][c + 1] = '#') and (dungeonArray[r + 1][c + 1] = '#') and
          (dungeonArray[r + 1][c] = '#') and (dungeonArray[r + 1][c - 1] = '.') and
          (dungeonArray[r][c - 1] = '#') and (dungeonArray[r - 1][c - 1] = '#') then
          processed_dungeon[r][c] := 'K';
      end;
  end;
  (* Bottom left corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r - 1][c] = '#') and (dungeonArray[r - 1][c + 1] = '.') and
          (dungeonArray[r][c + 1] = '#') and (dungeonArray[r + 1][c + 1] = '#') and
          (dungeonArray[r + 1][c] = '#') and (dungeonArray[r + 1][c - 1] = '#') and
          (dungeonArray[r][c - 1] = '#') and (dungeonArray[r - 1][c - 1] = '#') then
          processed_dungeon[r][c] := 'F';
      end;
  end;
  (* Bottom right corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r - 1][c] = '#') and (dungeonArray[r - 1][c + 1] = '#') and
          (dungeonArray[r][c + 1] = '#') and (dungeonArray[r + 1][c + 1] = '#') and
          (dungeonArray[r + 1][c] = '#') and (dungeonArray[r + 1][c - 1] = '#') and
          (dungeonArray[r][c - 1] = '#') and (dungeonArray[r - 1][c - 1] = '.') then
          processed_dungeon[r][c] := 'D';
      end;
  end;

  { Top row corners }

  (* Top left corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r][c + 1] = '#') and (dungeonArray[r + 1][c + 1] = '.') and
          (dungeonArray[r + 1][c] = '#') and (dungeonArray[r + 1][c - 1] = '#') and
          (dungeonArray[r][c - 1] = '#') then
          processed_dungeon[r][c] := 'M';
      end;
  end;
  (* Top right corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r][c + 1] = '#') and (dungeonArray[r + 1][c + 1] = '#') and
          (dungeonArray[r + 1][c] = '#') and (dungeonArray[r + 1][c - 1] = '.') and
          (dungeonArray[r][c - 1] = '#') then
          processed_dungeon[r][c] := 'K';
      end;
  end;

  { Bottom row corners }

  (* Bottom left corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r - 1][c] = '#') and (dungeonArray[r - 1][c + 1] = '.') and
          (dungeonArray[r][c + 1] = '#') and (dungeonArray[r][c - 1] = '#') and
          (dungeonArray[r - 1][c - 1] = '#') then
          processed_dungeon[r][c] := 'F';
      end;
  end;
  (* Bottom right corner *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (dungeonArray[r][c] = '#') then
      begin
        if (dungeonArray[r - 1][c] = '#') and (dungeonArray[r - 1][c + 1] = '#') and
          (dungeonArray[r][c + 1] = '#') and (dungeonArray[r][c - 1] = '#') and
          (dungeonArray[r - 1][c - 1] = '.') then
          processed_dungeon[r][c] := 'D';
      end;
  end;

  // put the stairs back in
end;


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

procedure createCorridor(fromX, fromY, toX, toY: smallint);
var
  direction: byte;
begin
  // flip a coin to decide whether to first go horizontally or vertically
  direction := Random(2);
  // horizontally first
  if direction = 1 then
  begin
    carveHorizontally(fromX, toX, fromY);
    carveVertically(fromY, toY, toX);
  end
  // vertically first
  else
  begin
    carveVertically(fromY, toY, toX);
    carveHorizontally(fromX, toX, fromY);
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
      ;
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
  for drawHeight := 0 to roomHeight do
  begin
    for drawWidth := 0 to roomWidth do
    begin
      dungeonArray[(topLeftY + nudgeDown) + drawHeight][(topLeftX + nudgeAcross) +
        drawWidth] := '.';
    end;
  end;
end;

procedure generate(idNumber: smallint; totalDepth: byte);
var
  i: byte;
begin
  for i := 1 to totalDepth do
  begin
    buildLevel(i);
    { First floor only }
    if (i = 1) then
    begin
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

      (* Improve the walls of the dungeon *)
      prettify;

      (* write the first level to universe.currentDungeon *)
      for r := 1 to globalUtils.MAXROWS do
      begin
        for c := 1 to globalUtils.MAXCOLUMNS do
        begin
          universe.currentDungeon[r][c] := processed_dungeon[r][c];
        end;
      end;
      universe.totalRooms := totalRooms;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tDungeon);
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
      (* Place the stairs *)
      dungeonArray[r][c] := '>';
      (* Save location of stairs *)
      stairX := c;
      stairY := r;
      (* Improve the walls of the dungeon *)
      prettify;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tDungeon);
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
      (* Place the stairs *)
      dungeonArray[r][c] := '>';
      (* Save location of stairs *)
      stairX := c;
      stairY := r;
      (* Improve the walls of the dungeon *)
      prettify;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tDungeon);
    end
    else
      (* Last floor *)
    begin
      (* Keep generating levels until the stairs can be placed *)
      repeat
        buildLevel(i);
      until dungeonArray[stairY][stairX] = '.';
      dungeonArray[stairY][stairX] := '<';
      (* Improve the walls of the dungeon *)
      prettify;
      file_handling.writeNewDungeonLevel(idNumber, i, totalDepth, totalRooms, tDungeon);
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
    //////////////////////////////

    /////////////////////////////
    // Write map to text file for testing
    //filename := 'dungeon_processed_level_' + IntToStr(i) + '.txt';
    //AssignFile(myfile, filename);
    //rewrite(myfile);
    //for r := 1 to MAXROWS do
    //begin
    //  for c := 1 to MAXCOLUMNS do
    //  begin
    //    Write(myfile, processed_dungeon[r][c]);
    //  end;
    //  Write(myfile, sLineBreak);
    //end;
    //closeFile(myfile);
    //////////////////////////////
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
