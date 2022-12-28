(* Unit responsible for selecting themed dungeons and caves.
   The types of locations are:
   tCave - underground cave with no obstacles
   tStoneCavern - underground cave with rubble
   tDungeon - rooms connected by corridors
   tCrypt - dungeon populated by undead
   tVillage - small settlement

  Arrays containing location types for certain areas of the island.
  The further north the player goes, the more difficult the locations become
*)

unit architect;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, globalUtils, player_stats, universe, plot_gen;

var
  (* Unique location ID for the locationLookup table *)
  locationBuilderID: smallint;

(* Check surrounding tiles to make sure 2 locations aren't placed next to each other *)
function validLocation(x, y: smallint): boolean;
(* Bottom row of the island *)
procedure firstRow;
(* Sprinkle locations over the island *)
procedure seedLocations;

implementation

uses
  island, overworld;

function validLocation(x, y: smallint): boolean;
begin
  Result := False;
  if (terrainArray[y][x] <> '>') and (terrainArray[y][x] <> '~') and
    (terrainArray[y][x] <> '-') and (terrainArray[y + 1][x] <> '>') and
    (terrainArray[y - 1][x] <> '>') and (terrainArray[y][x + 1] <> '>') and
    (terrainArray[y][x - 1] <> '>') then
    Result := True;
end;

procedure firstRow;
var
  cryptNames: array[0..3] of shortstring = ('abandoned crypt', 'spooky tomb', 'haunted mausoleum', 'Cursed Sepulchre');
  dungeonNames: array[0..5] of shortstring = ('Abandoned tunnels', 'Abandoned ruins', 'Unknown dungeon',
    'Ruins of Cal Arath', 'Whispering ruins', 'Derelict tunnels');
  stoneNames: array[0..4] of shortstring = ('rock cave', 'stony cavern', 'granite caves', 'Cursed Sepulchre', 'gravelly grotto');
  choice: byte;
  placeName: shortstring;
  placeX, placeY: smallint;
begin
  placeX := 0;
  placeY := 0;
  placeName := '';
  locationBuilderID := 2;

  (* Generate a village *)
  if (player_stats.playerRace = 'human') then
    placeName := UTF8Encode(universe.homeland)
  else
    placeName := UTF8Encode(plot_gen.smallVillage);
  placeX := 19;
  placeY := 49;
  { Store location in locationLookup table }
  SetLength(island.locationLookup, length(island.locationLookup) + 1);
  with island.locationLookup[locationBuilderID - 1] do
  begin
    X := placeX;
    Y := placeY;
    id := locationBuilderID;
    Name := placeName;
    generated := False;
    theme := tVillage;
  end;
  Inc(locationBuilderID);
  terrainArray[placeY][placeX] := '>';

  (* Place a dungeon *)
  choice := Random(Length(dungeonNames));
  placeName := dungeonNames[choice];
  { Place the location }
  repeat
    placeX := globalUtils.randomRange(11, 74);
    placeY := globalUtils.randomRange(50, 57);
  until validLocation(placeX, placeY) = True;
  { Store location in locationLookup table }
  SetLength(island.locationLookup, length(island.locationLookup) + 1);
  with island.locationLookup[locationBuilderID - 1] do
  begin
    X := placeX;
    Y := placeY;
    id := locationBuilderID;
    Name := placeName;
    generated := False;
    theme := tDungeon;
  end;
  Inc(locationBuilderID);
  terrainArray[placeY][placeX] := '>';

  (* Place a crypt *)
  choice := Random(Length(cryptNames));
  placeName := cryptNames[choice];
  { Place the location }
  repeat
    placeX := globalUtils.randomRange(11, 74);
    placeY := globalUtils.randomRange(50, 57);
  until validLocation(placeX, placeY) = True;
  { Store location in locationLookup table }
  SetLength(island.locationLookup, length(island.locationLookup) + 1);
  with island.locationLookup[locationBuilderID - 1] do
  begin
    X := placeX;
    Y := placeY;
    id := locationBuilderID;
    Name := placeName;
    generated := False;
    theme := tCrypt;
  end;
  Inc(locationBuilderID);
  terrainArray[placeY][placeX] := '>';

  (* Place a stone cavern *)
  choice := Random(Length(stoneNames));
  placeName := stoneNames[choice];
  { Place the location }
  repeat
    placeX := globalUtils.randomRange(11, 74);
    placeY := globalUtils.randomRange(50, 57);
  until validLocation(placeX, placeY) = True;
  { Store location in locationLookup table }
  SetLength(island.locationLookup, length(island.locationLookup) + 1);
  with island.locationLookup[locationBuilderID - 1] do
  begin
    X := placeX;
    Y := placeY;
    id := locationBuilderID;
    Name := placeName;
    generated := False;
    theme := tStoneCavern;
  end;
  Inc(locationBuilderID);
  terrainArray[placeY][placeX] := '>';
end;

procedure seedLocations;
begin
  firstRow;
end;

end.
