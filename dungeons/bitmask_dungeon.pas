(* Generates a grid based dungeon with wider spaces between rooms, this is then processed to apply bitmasked walls *)

unit bitmask_dungeon;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, process_dungeon, globalutils, map;

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
  (* list of coordinates of centre of each room *)
  centreList: array of coordinates;
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
  if (gridNumber >= 1) and (gridNumber <= 9) then
  begin
    topLeftX := (gridNumber * 7) - 4;
    topLeftY := 3;
  end;
  // row 2
  if (gridNumber >= 10) and (gridNumber <= 18) then
  begin
    topLeftX := (gridNumber * 7) - 67;
    topLeftY := 10;
  end;
  // row 3
  if (gridNumber >= 19) and (gridNumber <= 27) then
  begin
    topLeftX := (gridNumber * 7) - 130;
    topLeftY := 17;
  end;
  // row 4
  if (gridNumber >= 28) and (gridNumber <= 36) then
  begin
    topLeftX := (gridNumber * 7) - 193;
    topLeftY := 24;
  end;
  // row 5
  if (gridNumber >= 37) and (gridNumber <= 45) then
  begin
    topLeftX := (gridNumber * 7) - 256;
    topLeftY := 31;
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

procedure generate;
begin
  roomCounter := 0;
  // initialise the array
  SetLength(centreList, 1);
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
    // randomly choose grid location from 1 to 45
    roomSquare := Random(44) + 1;
    createRoom(roomSquare);
    Inc(roomCounter);
  end;
  leftToRight();
  for i := 1 to (totalRooms - 1) do
  begin
    createCorridor(centreList[i].x, centreList[i].y, centreList[i + 1].x,
      centreList[i + 1].y);
  end;
  // connect random rooms so the map isn't totally linear
  // from the first half of the room list
  firstHalf := (totalRooms div 2);
  p := random(firstHalf - 1) + 1;
  t := random(firstHalf - 1) + 1;
  createCorridor(centreList[p].x, centreList[p].y, centreList[t].x,
    centreList[t].y);
  // from the second half of the room list
  lastHalf := (totalRooms - firstHalf);
  p := random(lastHalf) + firstHalf;
  t := random(lastHalf) + firstHalf;
  createCorridor(centreList[p].x, centreList[p].y, centreList[t].x,
    centreList[t].y);
  // set player start coordinates
  map.startX := centreList[1].x;
  map.startY := centreList[1].y;

  /////////////////////////////
  // Write map to text file for testing
  filename := 'output_bitmask_dungeon.txt';
  AssignFile(myfile, filename);
  rewrite(myfile);
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      Write(myfile, dungeonArray[r][c]);
    end;
    Write(myfile, sLineBreak);
  end;
  closeFile(myfile);
  //////////////////////////////

  process_dungeon.prettify;

    /////////////////////////////
  // Write map to text file for testing
  filename := 'output_processed_dungeon.txt';
  AssignFile(myfile, filename);
  rewrite(myfile);
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      Write(myfile, globalutils.dungeonArray[r][c]);
    end;
    Write(myfile, sLineBreak);
  end;
  closeFile(myfile);
  //////////////////////////////

  (* Copy total rooms to main dungeon *)
  globalutils.currentDgnTotalRooms := totalRooms;
  (* Set flag for type of dungeon *)
  map.mapType := 3;
end;

end.

