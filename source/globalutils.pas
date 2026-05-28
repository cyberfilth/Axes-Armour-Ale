(* Common functions / utilities *)

unit globalUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes;

type
  coordinates = record
    x, y: smallint;
  end;

(* Types of locations that can be explored. See 'architect' unit for explanation *)
type
  dungeonTerrain = (tCave, tStoneCavern, tDungeon, tCrypt, tVillage);

type (* Pathfinding - Path to player *)
  path = array[1..30] of TPoint;

const
  (* Version info - a = Alpha, d = Debug, r = Release *)
  VERSION = '60a';
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
  (* Stores whether the player is underground or overground ;-) *)
  womblingFree: shortstring;
  (* Last overworld coordinates the player was at *)
  OWx, OWy: smallint;

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
  total: smallint;
begin
  total := 0;
  for i := 1 to numberOfDice do
    Inc(total, Random(6) + 1);
  Result := total;
end;

end.
