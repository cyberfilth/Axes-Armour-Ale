(* Generates a grid based dungeon level *)

unit grid_dungeon;

{$mode objfpc}{$H+}

interface

uses
  globalutils, map;

type
  coordinates = record
    x, y: smallint;
  end;

var
  r, c, i, p, t, listLength, firstHalf, lastHalf: smallint;
  dungeonArray: array[1..globalutils.MAXROWS, 1..globalutils.MAXCOLUMNS] of char;
  totalRooms, roomSquare: smallint;
  (* start creating corridors once this rises above 1 *)
  roomCounter: smallint;
  (* Player starting position *)
  startX, startY: smallint;
  (* TESTING - Write dungeon to text file *)
  filename: ShortString;
  myfile: Text;

(* Carve a horizontal tunnel *)
procedure carveHorizontally(x1, x2, y: smallint);
(* Carve a vertical tunnel *)
procedure carveVertically(y1, y2, x: smallint);
(* Create a room *)
procedure createRoom(gridNumber: smallint);
(* Generate a dungeon *)
procedure generate;
(* sort room list in order from left to right *)
procedure leftToRight;

implementation

procedure leftToRight;
var
  i, j, n, tempX, tempY: smallint;
begin
  n := length(globalutils.currentDgncentreList) - 1;
  for i := n downto 2 do
    for j := 0 to i - 1 do
      if globalutils.currentDgncentreList[j].x > globalutils.currentDgncentreList[j + 1].x then
      begin
        tempX := globalutils.currentDgncentreList[j].x;
        tempY := globalutils.currentDgncentreList[j].y;
        globalutils.currentDgncentreList[j].x := globalutils.currentDgncentreList[j + 1].x;
        globalutils.currentDgncentreList[j].y := globalutils.currentDgncentreList[j + 1].y;
        globalutils.currentDgncentreList[j + 1].x := tempX;
        globalutils.currentDgncentreList[j + 1].y := tempY;
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
  // row 1
  if (gridNumber >= 1) and (gridNumber <= 13) then
  begin
    topLeftX := (gridNumber * 5) - 3;
    topLeftY := 2;
  end;
  // row 2
  if (gridNumber >= 14) and (gridNumber <= 26) then
  begin
    topLeftX := (gridNumber * 5) - 68;
    topLeftY := 8;
  end;
  // row 3
  if (gridNumber >= 27) and (gridNumber <= 39) then
  begin
    topLeftX := (gridNumber * 5) - 133;
    topLeftY := 14;
  end;
  // row 4
  if (gridNumber >= 40) and (gridNumber <= 52) then
  begin
    topLeftX := (gridNumber * 5) - 198;
    topLeftY := 20;
  end;
  // row 5
  if (gridNumber >= 53) and (gridNumber <= 65) then
  begin
    topLeftX := (gridNumber * 5) - 263;
    topLeftY := 26;
  end;
  // row 6
  if (gridNumber >= 66) and (gridNumber <= 78) then
  begin
    topLeftX := (gridNumber * 5) - 328;
    topLeftY := 32;
  end;
  (* Randomly select room dimensions between 2 - 5 tiles in height / width *)
  roomHeight := Random(2) + 3;
  roomWidth := Random(2) + 3;
  (* Change starting point of each room so they don't all start
     drawing from the top left corner                           *)
  case roomHeight of
    2: nudgeDown := Random(0) + 2;
    3: nudgeDown := Random(0) + 1;
    else
      nudgeDown := 0;
  end;
  case roomWidth of
    2: nudgeAcross := Random(0) + 2;
    3: nudgeAcross := Random(0) + 1;
    else
      nudgeAcross := 0;
  end;
  (* Save coordinates of the centre of the rooms *)
  listLength := Length(globalutils.currentDgncentreList);
  SetLength(globalutils.currentDgncentreList, listLength + 1);
  globalutils.currentDgncentreList[listLength].x := (topLeftX + nudgeAcross) + (roomWidth div 2);
  globalutils.currentDgncentreList[listLength].y := (topLeftY + nudgeDown) + (roomHeight div 2);
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

procedure generate;
begin
  roomCounter := 0;
  // initialise the array
  SetLength(globalutils.currentDgncentreList, 1);
  // fill map with walls
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      dungeonArray[r][c] := '#';
    end;
  end;
  // Random(Range End - Range Start) + Range Start;
  totalRooms := Random(10) + 20; // between 20 - 30 rooms
  for i := 1 to totalRooms do
  begin
    // randomly choose grid location from 1 to 78
    roomSquare := Random(77) + 1;
    createRoom(roomSquare);
    Inc(roomCounter);
  end;
  leftToRight();
  for i := 1 to (totalRooms - 1) do
  begin
    createCorridor(globalutils.currentDgncentreList[i].x, globalutils.currentDgncentreList[i].y, globalutils.currentDgncentreList[i + 1].x,
      globalutils.currentDgncentreList[i + 1].y);
  end;
  // connect random rooms so the map isn't totally linear
  // from the first half of the room list
  firstHalf := (totalRooms div 2);
  p := random(firstHalf - 1) + 1;
  t := random(firstHalf - 1) + 1;
  createCorridor(globalutils.currentDgncentreList[p].x, globalutils.currentDgncentreList[p].y, globalutils.currentDgncentreList[t].x,
    globalutils.currentDgncentreList[t].y);
  // from the second half of the room list
  lastHalf := (totalRooms - firstHalf);
  p := random(lastHalf) + firstHalf;
  t := random(lastHalf) + firstHalf;
  createCorridor(globalutils.currentDgncentreList[p].x, globalutils.currentDgncentreList[p].y, globalutils.currentDgncentreList[t].x,
    globalutils.currentDgncentreList[t].y);
  // set player start coordinates
  map.startX := globalutils.currentDgncentreList[1].x;
  map.startY := globalutils.currentDgncentreList[1].y;

  /////////////////////////////
  // Write map to text file for testing
  //filename := 'output_grid_dungeon.txt';
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

  // Copy array to main dungeon
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      globalutils.dungeonArray[r][c] := dungeonArray[r][c];
    end;
  end;
  (* Copy total rooms to main dungeon *)
  globalutils.currentDgnTotalRooms := totalRooms;
end;

end.
