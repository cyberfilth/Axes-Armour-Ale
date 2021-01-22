(* Generate a cave with tunnels *)

unit cave;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  globalutils, map, process_cave;

type
  coordinates = record
    x, y: smallint;
  end;

var
  r, c, i, p, t, listLength, firstHalf, lastHalf, iterations, tileCounter: smallint;
  caveArray, tempArray: array[1..globalutils.MAXROWS, 1..globalutils.MAXCOLUMNS] of char;
  totalRooms, roomSquare: smallint;
  (* Player starting position *)
  startX, startY: smallint;
  (* start creating corridors once this rises above 1 *)
  roomCounter: smallint;
  (* TESTING - Write cave to text file *)
  filename: ShortString;
  myfile: Text;

(* Draw straight line between 2 points *)
procedure drawLine(x1, y1, x2, y2: smallint);
(* Draw a circular room *)
procedure drawCircle(centreX, centreY, radius: smallint);
(* Carve a horizontal tunnel *)
procedure carveHorizontally(x1, x2, y: smallint);
(* Carve a vertical tunnel *)
procedure carveVertically(y1, y2, x: smallint);
(* Create a room *)
procedure createRoom(gridNumber: smallint);
(* Generate a cave *)
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
      if globalutils.currentDgncentreList[j].x >
        globalutils.currentDgncentreList[j + 1].x then
      begin
        tempX := globalutils.currentDgncentreList[j].x;
        tempY := globalutils.currentDgncentreList[j].y;
        globalutils.currentDgncentreList[j].x :=
          globalutils.currentDgncentreList[j + 1].x;
        globalutils.currentDgncentreList[j].y :=
          globalutils.currentDgncentreList[j + 1].y;
        globalutils.currentDgncentreList[j + 1].x := tempX;
        globalutils.currentDgncentreList[j + 1].y := tempY;
      end;
end;

procedure drawLine(x1, y1, x2, y2: smallint);
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: smallint;
begin
  (* Calculate delta X and delta Y for initialisation *)
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);
  (* Initialize all vars based on which is the independent variable *)
  if deltax >= deltay then
  begin
    (* x is independent variable *)
    numpixels := deltax + 1;
    d := (2 * deltay) - deltax;
    dinc1 := deltay shl 1;
    dinc2 := (deltay - deltax) shl 1;
    xinc1 := 1;
    xinc2 := 1;
    yinc1 := 0;
    yinc2 := 1;
  end
  else
  begin
    (* y is independent variable *)
    numpixels := deltay + 1;
    d := (2 * deltax) - deltay;
    dinc1 := deltax shl 1;
    dinc2 := (deltax - deltay) shl 1;
    xinc1 := 0;
    xinc2 := 1;
    yinc1 := 1;
    yinc2 := 1;
  end;
  (* Make sure x and y move in the right directions *)
  if x1 > x2 then
  begin
    xinc1 := -xinc1;
    xinc2 := -xinc2;
  end;
  if y1 > y2 then
  begin
    yinc1 := -yinc1;
    yinc2 := -yinc2;
  end;
  (* Start drawing at *)
  x := x1;
  y := y1;
  (* Draw the pixels *)
  for i := 1 to numpixels do
  begin
    caveArray[y][x] := ':';
    if d < 0 then
    begin
      d := d + dinc1;
      x := x + xinc1;
      y := y + yinc1;
    end
    else
    begin
      d := d + dinc2;
      x := x + xinc2;
      y := y + yinc2;
    end;
  end;
end;

procedure drawCircle(centreX, centreY, radius: smallint);
var
  d, x, y: smallint;
begin
  d := 3 - (2 * radius);
  x := 0;
  y := radius;
  while (x <= y) do
  begin
    drawLine(centreX, centreY, centreX + X, centreY + Y);
    drawLine(centreX, centreY, centreX + X, centreY - Y);
    drawLine(centreX, centreY, centreX - X, centreY + Y);
    drawLine(centreX, centreY, centreX - X, centreY - Y);
    drawLine(centreX, centreY, centreX + Y, centreY + X);
    drawLine(centreX, centreY, centreX + Y, centreY - X);
    drawLine(centreX, centreY, centreX - Y, centreY + X);
    drawLine(centreX, centreY, centreX - Y, centreY - X);
    if (d < 0) then
      d := d + (4 * x) + 6
    else
    begin
      d := d + 4 * (x - y) + 10;
      y := y - 1;
    end;
    Inc(x);
  end;
end;

procedure carveHorizontally(x1, x2, y: smallint);
var
  x: byte;
begin
  if x1 < x2 then
  begin
    for x := x1 to x2 do
      caveArray[y][x] := ':';
  end;
  if x1 > x2 then
  begin
    for x := x2 to x1 do
      caveArray[y][x] := ':';
  end;
end;

procedure carveVertically(y1, y2, x: smallint);
var
  y: byte;
begin
  if y1 < y2 then
  begin
    for y := y1 to y2 do
      caveArray[y][x] := ':';
  end;
  if y1 > y2 then
  begin
    for y := y2 to y1 do
      caveArray[y][x] := ':';
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
  topLeftX, topLeftY, roomHeight, roomWidth, drawHeight, drawWidth: smallint;
begin
  // initialise variables
  topLeftX := 0;
  topLeftY := 0;
  roomHeight := 0;
  roomWidth := 0;
  drawHeight := 0;
  drawWidth := 0;
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
  (* Save coordinates of the centre of the room *)
  listLength := Length(globalutils.currentDgncentreList);
  SetLength(globalutils.currentDgncentreList, listLength + 1);
  globalutils.currentDgncentreList[listLength].x := topLeftX + (roomWidth div 2);
  globalutils.currentDgncentreList[listLength].y := topLeftY + (roomHeight div 2);
  (* Draw room within the grid square *)
  drawCircle(globalutils.currentDgncentreList[listLength].x,
    globalutils.currentDgncentreList[listLength].y, roomHeight);
  for drawHeight := 0 to roomHeight do
  begin
    for drawWidth := 0 to roomWidth do
    begin
      caveArray[topLeftY + drawHeight][topLeftX + drawWidth] := ':';
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
      caveArray[r][c] := '*';
    end;
  end;

  for r := 2 to (globalutils.MAXROWS - 1) do
  begin
    for c := 2 to (globalutils.MAXCOLUMNS - 1) do
    begin
      (* 50% chance of drawing a wall tile *)
      if (Random(100) <= 50) then
        caveArray[r][c] := '*'
      else
        caveArray[r][c] := ':';
    end;
  end;
  (* Run through the process 5 times *)
  for iterations := 1 to 5 do
  begin
    for r := 2 to globalutils.MAXROWS - 1 do
    begin
      for c := 2 to globalutils.MAXCOLUMNS - 1 do
      begin
      (* A tile becomes a wall if it was a wall and 4 or more of its 8
      neighbours are walls, or if it was not but 5 or more neighbours were *)
        tileCounter := 0;
        if (caveArray[r - 1][c] = '*') then // NORTH
          Inc(tileCounter);
        if (caveArray[r - 1][c + 1] = '*') then // NORTH EAST
          Inc(tileCounter);
        if (caveArray[r][c + 1] = '*') then // EAST
          Inc(tileCounter);
        if (caveArray[r + 1][c + 1] = '*') then // SOUTH EAST
          Inc(tileCounter);
        if (caveArray[r + 1][c] = '*') then // SOUTH
          Inc(tileCounter);
        if (caveArray[r + 1][c - 1] = '*') then // SOUTH WEST
          Inc(tileCounter);
        if (caveArray[r][c - 1] = '*') then // WEST
          Inc(tileCounter);
        if (caveArray[r - 1][c - 1] = '*') then // NORTH WEST
          Inc(tileCounter);
        (* Set tiles in temporary array *)
        if (caveArray[r][c] = '*') then
        begin
          if (tileCounter >= 4) then
            tempArray[r][c] := '*'
          else
            tempArray[r][c] := ':';
        end;
        if (caveArray[r][c] = ':') then
        begin
          if (tileCounter >= 5) then
            tempArray[r][c] := '*'
          else
            tempArray[r][c] := ':';
        end;
      end;
    end;
    (* Copy temporary map back to main dungeon map array *)
    for r := 1 to globalutils.MAXROWS do
    begin
      for c := 1 to globalutils.MAXCOLUMNS do
      begin
        caveArray[r][c] := tempArray[r][c];
      end;
    end;
  end;
  // Random(Range End - Range Start) + Range Start;
  totalRooms := Random(5) + 10; // between 10 - 15 rooms
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
    createCorridor(globalutils.currentDgncentreList[i].x,
      globalutils.currentDgncentreList[i].y, globalutils.currentDgncentreList[i + 1].x,
      globalutils.currentDgncentreList[i + 1].y);
  end;
  // connect random rooms so the map isn't totally linear
  // from the first half of the room list
  firstHalf := (totalRooms div 2);
  p := random(firstHalf - 1) + 1;
  t := random(firstHalf - 1) + 1;
  createCorridor(globalutils.currentDgncentreList[p].x,
    globalutils.currentDgncentreList[p].y, globalutils.currentDgncentreList[t].x,
    globalutils.currentDgncentreList[t].y);
  // from the second half of the room list
  lastHalf := (totalRooms - firstHalf);
  p := random(lastHalf) + firstHalf;
  t := random(lastHalf) + firstHalf;
  createCorridor(globalutils.currentDgncentreList[p].x,
    globalutils.currentDgncentreList[p].y, globalutils.currentDgncentreList[t].x,
    globalutils.currentDgncentreList[t].y);

  (* draw top and bottom border *)
  for i := 1 to globalutils.MAXCOLUMNS do
  begin
    caveArray[1][i] := '*';
    caveArray[globalutils.MAXROWS][i] := '*';
  end;
  (* draw left and right border *)
  for i := 1 to globalutils.MAXROWS do
  begin
    caveArray[i][1] := '*';
    caveArray[i][globalutils.MAXCOLUMNS] := '*';
  end;
  // set player start coordinates
  map.startX := globalutils.currentDgncentreList[1].x;
  map.startY := globalutils.currentDgncentreList[1].y;

  /////////////////////////////
  // Write map to text file for testing
  //filename := 'output_cave.txt';
  //AssignFile(myfile, filename);
  //rewrite(myfile);
  //for r := 1 to MAXROWS do
  //begin
  //  for c := 1 to MAXCOLUMNS do
  //  begin
  //    Write(myfile, caveArray[r][c]);
  //  end;
  //  Write(myfile, sLineBreak);
  //end;
  //closeFile(myfile);
  //////////////////////////////

  process_cave.prettify;

  /////////////////////////////
  // Write map to text file for testing
  //filename := 'output_processed_cave.txt';
  //AssignFile(myfile, filename);
  //rewrite(myfile);
  //for r := 1 to MAXROWS do
  //begin
  //  for c := 1 to MAXCOLUMNS do
  //  begin
  //    Write(myfile, globalutils.dungeonArray[r][c]);
  //  end;
  //  Write(myfile, sLineBreak);
  //end;
  //closeFile(myfile);
  //////////////////////////////


  (* Copy total rooms to main dungeon *)
  globalutils.currentDgnTotalRooms := totalRooms;
  (* Set flag for type of dungeon *)
  map.mapType := 0;
end;

end.
