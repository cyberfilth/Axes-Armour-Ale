(* Common functions / utilities *)

unit globalUtils;

{$mode objfpc}{$H+}

interface

type
  coordinates = record
    x, y: smallint;
  end;

const
  (* Version info - a = Alpha, d = Debug, r = Release *)
  VERSION = '45a';
  (* Columns of the game map *)
  MAXCOLUMNS = 80;
  (* Rows of the game map *)
  MAXROWS = 20;
  (* Save game file *)
  saveFile = 'saveGame.dat';

var
  dungeonArray: array[1..MAXROWS, 1..MAXCOLUMNS] of shortstring;
  (* Number of rooms in the current dungeon *)
  currentDgnTotalRooms: smallint;
  (* Save game directory *)
  saveDirectory: string;
  (* Name of entity or item that killed the player *)
  killer: shortstring;

(* Select random number from a range *)
function randomRange(fromNumber, toNumber: smallint): smallint;
(* Simulate dice rolls *)
function rollDice(numberOfDice: byte): smallint;

implementation

function randomRange(fromNumber, toNumber: smallint): smallint;
var
  p: smallint;
begin
  p := toNumber - fromNumber;
  Result := random(p + 1) + fromNumber;
end;

function rollDice(numberOfDice: byte): smallint;
var
  i: byte;
  x: smallint;
begin
  x := 0; { initialise variable }
  if (numberOfDice = 0) then
    Result := 0
  else
  begin
    for i := 0 to numberOfDice do
    begin
      x := Random(6) + 1;
    end;
    Result := x;
  end;
end;

end.
