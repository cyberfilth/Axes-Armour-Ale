(* Generate a cavern, not linked by tunnels *)

unit cavern;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  globalutils, map;

type
  coordinates = record
    x, y: smallint;
  end;

var
  terrainArray, tempArray, tempArray2: array[1..MAXROWS, 1..MAXCOLUMNS] of char;
  r, c, i, iterations, tileCounter: smallint;
  (* TESTING - Write cavern to text file *)
  filename: ShortString;
  myfile: Text;

(* Fill array with walls *)
procedure fillWithWalls;
(* Fill array with random tiles *)
procedure randomTileFill;
(* Generate a cavern *)
procedure generate;

implementation

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

procedure generate;
begin
  // fill map with walls
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
          terrainArray[r][c] := '#';
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
  // set player start coordinates
  repeat
    map.startX := Random(19) + 1;
    map.startY := Random(19) + 1;
  until (terrainArray[map.startY][map.startX] = '.');

  /////////////////////////////
  // Write map to text file for testing
  //filename:='output_cavern.txt';
  //AssignFile(myfile, filename);
  // rewrite(myfile);
  // for r := 1 to MAXROWS do
  //begin
  //  for c := 1 to MAXCOLUMNS do
  //  begin
  // write(myfile,terrainArray[r][c]);
  // end;
  //  write(myfile, sLineBreak);
  //  end;
  // closeFile(myfile);
  //////////////////////////////

  // Copy array to main dungeon
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      globalutils.dungeonArray[r][c] := terrainArray[r][c];
    end;
  end;
  (* Set 'room number' to set NPC amount *)
  globalutils.currentDgnTotalRooms := 12;
  (* Set flag for type of map *)
  map.mapType := 2;
end;

end.
