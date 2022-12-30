(* Generates a small village of shacks and a village hall *)

unit village;

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
  x, y: array [1..MAXCOLUMNS, 1..MAXROWS, 1..5] of char;
  dungeonArray: array[1..MAXROWS, 1..MAXCOLUMNS] of char;
  xx: array[1..MAXCOLUMNS, 1..MAXROWS] of integer;
  i, j, q, qq, ii, jj, ax, ay, k, choose, r, c, listLength: integer;
  (* list of coordinates of centre of each building *)
  centreList: array of coordinates;

(* Create a building *)
procedure createRoom(gridNumber: smallint);
(* Generate shacks on the left of the map *)
procedure leftShacks;
(* Generate shacks on the right of the map *)
procedure rightShacks;
(* Generate a village map *)
procedure generate(title: string; idNumber: smallint);

implementation

uses
  universe, file_handling;

procedure createRoom(gridNumber: smallint);
var
  topLeftX, topLeftY, roomHeight, roomWidth, drawHeight, drawWidth: smallint;
begin
  case gridNumber of
    1: begin
      topLeftX := 34;
      topLeftY := 2;
      roomWidth := 9;
      roomHeight := 7;
    end;
    2: begin
      topLeftX := 34;
      topLeftY := 12;
      roomWidth := 9;
      roomHeight := 7;
    end;
    3:
    begin
      topLeftX := 15;
      topLeftY := 2;
      roomWidth := 4;
      roomHeight := 4;
    end;
    4:
    begin
      topLeftX := 14;
      topLeftY := 9;
      roomWidth := 4;
      roomHeight := 4;
    end;
    5:
    begin
      topLeftX := 21;
      topLeftY := 6;
      roomWidth := 4;
      roomHeight := 4;
    end;
    6:
    begin
      topLeftX := 21;
      topLeftY := 13;
      roomWidth := 4;
      roomHeight := 4;
    end;
    7:
    begin
      topLeftX := 28;
      topLeftY := 2;
      roomWidth := 4;
      roomHeight := 4;
    end;
    8:
    begin
      topLeftX := 28;
      topLeftY := 9;
      roomWidth := 4;
      roomHeight := 4;
    end;
    9:
    begin
      topLeftX := 28;
      topLeftY := 15;
      roomWidth := 4;
      roomHeight := 4;
    end;
    10:
    begin
      topLeftX := 46;
      topLeftY := 2;
      roomWidth := 4;
      roomHeight := 4;
    end;
    11:
    begin
      topLeftX := 48;
      topLeftY := 8;
      roomWidth := 4;
      roomHeight := 4;
    end;
    12:
    begin
      topLeftX := 45;
      topLeftY := 15;
      roomWidth := 4;
      roomHeight := 4;
    end;
    13:
    begin
      topLeftX := 54;
      topLeftY := 2;
      roomWidth := 4;
      roomHeight := 4;
    end;
    14:
    begin
      topLeftX := 54;
      topLeftY := 8;
      roomWidth := 4;
      roomHeight := 4;
    end;
    15:
    begin
      topLeftX := 53;
      topLeftY := 14;
      roomWidth := 4;
      roomHeight := 4;
    end
    else
    begin
      topLeftX := 61;
      topLeftY := 7;
      roomWidth := 4;
      roomHeight := 4;
    end;
  end;

  (* Save coordinates of the centre of the room *)
  listLength := Length(centreList);
  SetLength(centreList, listLength + 1);
  centreList[listLength].x := topLeftX + (roomWidth div 2);
  centreList[listLength].y := topLeftY + (roomHeight div 2);
  (* Draw room within the grid square *)
  for drawHeight := 0 to roomHeight do
  begin
    for drawWidth := 0 to roomWidth do
    begin
      dungeonArray[topLeftY + drawHeight][topLeftX + drawWidth] := '#';
    end;
  end;
  (* Draw inner room *)
  for drawHeight := 1 to roomHeight - 1 do
  begin
    for drawWidth := 1 to roomWidth - 1 do
    begin
      dungeonArray[topLeftY + drawHeight][topLeftX + drawWidth] := '.';
    end;
  end;
  (* Draw doorway *)
  case gridNumber of
    1:
    begin
      dungeonArray[9, 38] := '.';
      dungeonArray[9, 39] := '.';
      dungeonArray[9, 40] := '.';
    end;
    2:
    begin
      dungeonArray[12, 38] := '.';
      dungeonArray[12, 39] := '.';
      dungeonArray[12, 40] := '.';
    end;
    3: dungeonArray[4, 19] := '.';
    4: dungeonArray[11, 18] := '.';
    5: dungeonArray[8, 25] := '.';
    6: dungeonArray[15, 25] := '.';
    7: dungeonArray[4, 32] := '.';
    8: dungeonArray[11, 32] := '.';
    9: dungeonArray[17, 32] := '.';
    10: dungeonArray[4, 46] := '.';
    11: dungeonArray[10, 48] := '.';
    12: dungeonArray[17, 45] := '.';
    13: dungeonArray[4, 54] := '.';
    14: dungeonArray[10, 54] := '.';
    15: dungeonArray[16, 53] := '.'
    else
      dungeonArray[9, 61] := '.';
  end;
end;

procedure leftShacks;
var
  numberedShacks, randShacks: array of smallint;
  i, j, t, x: smallint;
begin
  numberedShacks := [3, 4, 5, 6, 7, 8, 9];
  randShacks := [0, 0, 0, 0, 0, 0, 0];
  { Randomise order using Sattolo cycle }
  i := length(numberedShacks);
  while i > 0 do
  begin
    Dec(i);
    j := randomrange(0, i);
    t := numberedShacks[i];
    numberedShacks[i] := numberedShacks[j];
    numberedShacks[j] := t;
    randShacks[i] := numberedShacks[i];
  end;
  { Draw the first 4 shacks }
  for x := 0 to 3 do
    createRoom(randShacks[x]);
end;

procedure rightShacks;
var
  numberedShacks, randShacks: array of smallint;
  i, j, t, x: smallint;
begin
  numberedShacks := [10, 11, 12, 13, 14, 15, 16];
  randShacks := [0, 0, 0, 0, 0, 0, 0];
  { Randomise order using Sattolo cycle }
  i := length(numberedShacks);
  while i > 0 do
  begin
    Dec(i);
    j := randomrange(0, i);
    t := numberedShacks[i];
    numberedShacks[i] := numberedShacks[j];
    numberedShacks[j] := t;
    randShacks[i] := numberedShacks[i];
  end;
  { Draw the first 4 shacks }
  for x := 0 to 3 do
    createRoom(randShacks[x]);
end;

procedure generate(title: string; idNumber: smallint);
begin
  choose := 0;
  { Create a dirt path in the centre of the village }
  for i := 1 to MAXROWS do
    for j := 1 to MAXCOLUMNS do
    begin
      if (i = 1) or (i = MAXROWS) or (j = 1) or (j = MAXCOLUMNS) then xx[j, i] := -1
      else
        xx[j, i] := 0;
    end;
  for i := 1 to MAXROWS do
    for j := 1 to MAXCOLUMNS do
    begin
      if (i = 1) or (i = MAXROWS) or (j = 1) or (j = MAXCOLUMNS) then
      begin
        x[j, i, 1] := '"';
        x[j, i, 5] := '"';
        y[j, i, 1] := '"';
      end
      else
      begin
        q := random(100);
        if q < 39 then x[j, i, 1] := '"'
        else
          x[j, i, 1] := '.';
        qq := random(100);
        if qq < 39 then y[j, i, 1] := '"'
        else
          y[j, i, 1] := '.';
      end;
    end;
  for k := 2 to 5 do
  begin
    for i := 2 to (MAXROWS - 1) do
    begin
      for j := 2 to (MAXCOLUMNS - 1) do
      begin
        ax := 0;
        ay := 0;
        for ii := (i - 1) to (i + 1) do
        begin
          for jj := (j - 1) to (j + 1) do
          begin
            if (x[jj, ii, k - 1] = '"') then ax := ax + 1;
            if (y[jj, ii, k - 1] = '"') then ay := ay + 1;
          end;
        end;
        if ((x[j, i, k - 1] = '"') and (ax > 3)) or (ax > 4) then
        begin
          x[j, i, k] := '"';
        end
        else
        begin
          x[j, i, k] := '.';
        end;
        if ((y[j, i, k - 1] = '"') and (ay > 3)) or (ay > 4) then
        begin
          y[j, i, k] := '"';
        end
        else
        begin
          y[j, i, k - 1] := '.';
        end;
      end;
    end;
  end;
  for i := 2 to (MAXROWS - 1) do
  begin
    for j := 2 to (MAXCOLUMNS - 1) do
    begin
      case x[j, i, 5] of
        '"': if x[j, i, 5] = y[j, i, 5] then
          begin
            x[j, i, 5] := '.';
            xx[j, i] := 0;
          end
          else
          begin
            x[j, i, 5] := '"';
            xx[j, i] := -1;
          end;
        '.': if x[j, i, 5] = y[j, i, 5] then
          begin
            x[j, i, 5] := '"';
            xx[j, i] := -1;
          end
          else
          begin
            x[j, i, 5] := '.';
            xx[j, i] := 0;
          end;
      end;
    end;
  end;
  for i := 10 to 15 do
    for j := 35 to 40 do
    begin
      x[j, i, 5] := '.';
      xx[j, i] := 0;
    end;
  xx[MAXCOLUMNS div 2, MAXROWS div 2] := 1;
  for k := 1 to MAXROWS do
    for i := 2 to (MAXROWS - 1) do
      for j := 2 to (MAXCOLUMNS - 1) do
      begin
        if xx[j, i] = k then
        begin
          for ii := (i - 1) to (i + 1) do
          begin
            for jj := (j - 1) to (j + 1) do
            begin
              if (xx[jj, ii] = 0) then xx[jj, ii] := k + 1;
            end;
          end;
        end;
      end;
  for i := 2 to (MAXROWS - 1) do
    for j := 2 to (MAXCOLUMNS - 1) do
    begin
      if (xx[j, i] = 0) and (x[j, i, 5] = '.') then
      begin
        x[j, i, 5] := '"';
      end;
    end;

  { Copy the terrain to the dungeon array }
  for i := 1 to MAXROWS do
    for j := 1 to MAXCOLUMNS do
    begin
      dungeonArray[i, j] := x[j, i, 5];
    end;

  { Place the village hall }
  choose := randomRange(1, 2);
  if (choose = 1) then
    createRoom(1)
  else
    createRoom(2);

  { Place 4 shacks on the left }
  leftShacks;
  { Place 4 shacks on the left }
  rightShacks;

  { set player start coordinates }
  dungeonArray[3][66] := '<';

  { write the village map to universe.currentDungeon }
  for r := 1 to globalUtils.MAXROWS do
  begin
    for c := 1 to globalUtils.MAXCOLUMNS do
    begin
      universe.currentDungeon[r][c] := dungeonArray[r][c];
    end;
  end;

  universe.totalRooms := 9;
  file_handling.writeNewDungeonLevel(title, idNumber, 1, 1, 9, tVillage);
end;

end.
