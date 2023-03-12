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
  SysUtils, globalUtils, player_stats, universe, plot_gen, logging;

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
  cryptNames: array[0..3] of
  shortstring = ('abandoned crypt', 'spooky tomb', 'haunted mausoleum', 'Cursed Sepulchre');
  dungeonNames: array[0..5] of
  shortstring = ('Abandoned tunnels', 'Abandoned ruins', 'Unknown dungeon', 'Ruins of Cal Arath', 'Whispering ruins', 'Derelict tunnels');
  stoneNames: array[0..4] of
  shortstring = ('rock cave', 'stony cavern', 'granite caves', 'Cursed Sepulchre', 'gravelly grotto');
  choice: byte;
  placeName: shortstring;
  placeX, placeY, i, t, j, x: smallint;
  placeHolder, randOrder: array of smallint;
begin
  placeX := 0;
  placeY := 0;
  t := 0;
  j := 0;
  x := 0;
  placeName := '';
  locationBuilderID := 2;
  placeHolder := [0, 1, 2];
  randOrder := [0, 0, 0];
  i := length(placeHolder);

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
  placeY := globalUtils.randomRange(50, 57);

  { Randomise order locations are placed using Sattolo cycle
    Then place one location on the left and two on the right }

  while i > 0 do
  begin
    Dec(i);
    j := randomrange(0, i);
    t := placeHolder[i];
    placeHolder[i] := placeHolder[j];
    placeHolder[j] := t;
    randOrder[i] := placeHolder[i];
  end;
  { Place the locations }
  for x := 0 to 3 do
  begin
    case randOrder[x] of
      0: (* Place a dungeon *)
      begin
        choice := Random(Length(dungeonNames));
        placeName := dungeonNames[choice];
        { Place the location }
        repeat
          if (x = 0) then
            placeX := globalUtils.randomRange(11, 37)
          else
            placeX := globalUtils.randomRange(39, 74);
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
      end;
      1: (* Place a crypt *)
      begin
        choice := Random(Length(cryptNames));
        placeName := cryptNames[choice];
        { Place the location }
        repeat
          if (x = 0) then
            placeX := globalUtils.randomRange(11, 37)
          else
            placeX := globalUtils.randomRange(39, 74);
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
      end;
      2: (* Place a stone cavern *)
      begin
        choice := Random(Length(stoneNames));
        placeName := stoneNames[choice];
        { Place the location }
        repeat
          if (x = 0) then
            placeX := globalUtils.randomRange(11, 37)
          else
            placeX := globalUtils.randomRange(39, 74);
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
    end;
  end;
  { End of Sattolo cycle }
end;

procedure seedLocations;
begin
  firstRow;
end;

end.
