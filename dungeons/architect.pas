(* Unit responsible for selecting themed dungeons and caves.
   The types of locations are:
   tCave - underground cave with no obstacles
   tCavern - underground cave with rubble
   tDungeon - rooms connected by corridors
   tCrypt - dungeon populated by undead
   tVillage - small settlement
*)

unit architect;

{$mode fpc}{$H+}

interface

uses
  SysUtils, universe, island;

(* Arrays containing location types for certain areas of the island.
  The further north the player goes, the more difficult the locations become *)
var
  locations1: array[1..3] of dungeonTerrain = (tDungeon, tVillage, tCavern);

(* Bottom row of the island *)
procedure firstRow;
(* Sprinkle locations over the island *)
procedure seedLocations;

implementation

procedure firstRow;
begin
  // the first, bottom row of the island
end;

procedure seedLocations;
begin
  // add locations on each row of the island
end;

end.

