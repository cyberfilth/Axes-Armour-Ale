(* Unit responsible for selecting themed dungeons and caves.
   The types of locations are:
   tCave - underground cave with no obstacles
   tCavern - underground cave with rubble
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
  SysUtils, globalUtils;

var
  (* Unique location ID for the locationLookup table *)
  locationBuilderID: smallint;

(* Check surrounding tiles to make sure 2 locations aren't placed next to each other *)
function validLocation(x, y: smallint):boolean;
(* Bottom row of the island *)
procedure firstRow;
(* Sprinkle locations over the island *)
procedure seedLocations;

implementation

uses
  universe, island;

function validLocation(x, y: smallint): boolean;
begin
  Result := False;
  if (overworldMap[x][y].Glyph <> '>') and (overworldMap[x][y].Glyph <> '~') and
  (overworldMap[x][y].Glyph <> chr(247)) and (overworldMap[x + 1][y].Glyph <> '>')
  and (overworldMap[x - 1][y].Glyph <> '>') and (overworldMap[x][y + 1].Glyph <> '>')
  and (overworldMap[x][y - 1].Glyph <> '>') then
      Result := True;
end;

procedure firstRow;
var
  locations1: array[0..2] of dungeonTerrain = (tDungeon, tVillage, tCavern);
  locations2: array[0..2] of dungeonTerrain = (tDungeon, tCavern, tDungeon);
  villageNames: array[0..3] of shortstring =
    ('village of Barterville', 'village of Flatgrove', 'village of Little Wolding', 'village of Swineford');
  dungeonNames: array[0..5] of shortstring =
    ('Abandoned tunnels', 'Abandoned ruins', 'Unknown dungeon', 'Ruins of Cal Arath', 'Whispering ruins', 'Derelict tunnels');
  cavernNames: array[0..4] of shortstring =
    ('Pooka caves', 'dark cavern', 'Howling caves', 'deep chasm', 'deep grotto');
  i, total, choice: byte;
  (* Used so that no more than one village is created *)
  villSelected: boolean;
  placeType: dungeonTerrain;
  placeName: shortstring;
  placeX, placeY: smallint;
begin
   placeX := 0;
   placeY := 0;
   villSelected := False;
   locationBuilderID := 2;
   total := globalUtils.randomRange(3, 4);
   for i := 0 to total do
   begin
     { Choose a location type }
     choice := Random(2);
     if (villSelected = False) then
       placeType := locations1[choice]
     else
       placeType := locations2[choice];

     if (placeType = tVillage) then
       villSelected := True;
     { Generate a name }
     if (placeType = tVillage) then
       begin
         repeat
         choice := Random(3);
         until villageNames[choice] <> 'used';
         placeName := villageNames[choice];
         villageNames[choice] := 'used';
       end
     else if (placeType = tDungeon) then
     begin
         repeat
         choice := Random(Length(dungeonNames));
         until dungeonNames[choice] <> 'used';
         placeName := dungeonNames[choice];
         dungeonNames[choice] := 'used';
     end
     else if (placeType = tCavern) then
     begin
         repeat
         choice := Random(Length(cavernNames));
         until cavernNames[choice] <> 'used';
         placeName := cavernNames[choice];
         cavernNames[choice] := 'used';
     end;
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
        name := placeName;
        generated := False;
        theme := placeType;
      end;
     Inc(locationBuilderID);
   end;
end;

procedure seedLocations;
begin
  firstRow;
end;

end.

