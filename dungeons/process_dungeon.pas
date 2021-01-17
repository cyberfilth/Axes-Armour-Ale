(* Processes the bitmask_dungeon map to add features *)

unit process_dungeon;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, globalutils;

var
  processed_dungeon: array[1..globalutils.MAXROWS, 1..globalutils.MAXCOLUMNS] of char;

(* Process generated dungeon to add shaped walls *)
procedure prettify;

implementation

uses
  bitmask_dungeon;

procedure prettify;
var
  tileCounter: smallint;
begin
  (* Don't scan the outer border as there will be NULL tiles on their edges *)
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
      if (bitmask_dungeon.dungeonArray[r][c] = '#') then
      begin
        tileCounter := 0;
        if (bitmask_dungeon.dungeonArray[r - 1][c] <> '.') then // NORTH
          tileCounter := tileCounter + 1;
        if (bitmask_dungeon.dungeonArray[r][c + 1] <> '.') then // EAST
          tileCounter := tileCounter + 4;
        if (bitmask_dungeon.dungeonArray[r + 1][c] <> '.') then // SOUTH
          tileCounter := tileCounter + 8;
        if (bitmask_dungeon.dungeonArray[r][c - 1] <> '.') then // WEST
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
  // Update the original dungeon
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      globalutils.dungeonArray[r][c] := processed_dungeon[r][c];
    end;
  end;
end;

end.
