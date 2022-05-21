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

{$mode fpc}{$H+}

interface

uses
  SysUtils, universe, island, globalUtils;

var
  (* Unique location ID for the locationLookup table *)
  locationBuilderID: smallint;

(* Bottom row of the island *)
procedure firstRow;
(* Sprinkle locations over the island *)
procedure seedLocations;

implementation

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
begin
   villSelected := False
   locationBuilderID := 2;
   total := globalUtils.randomRange(3, 4);
   i := 0 to total do
   begin
     { Choose a location type }
     choice := Random(2);
     if (villSelected = False) then
       placeType := locations1(choice)
     else
       placeType := locations2(choice);

     if (placeType = tVillage) then
       villSelected := True;
     { Generate a name }
     if (selection = tVillage) then
       begin
         choice := Random(3);
         placeName := villageNames(choice);
       end
     else if (selection = tDungeon) then
     begin
         choice := Random(Length(dungeonNames));
         placeName := dungeonNames(choice);
         Delete(dungeonNames, choice, 1);
     end
     else if (selection = tCavern) then
     begin
         choice := Random(Length(cavernNames));
         placeName := cavernNames(choice);
         Delete(cavernNames, choice, 1);
     end;
     { Place the location }
   end;
end;

procedure seedLocations;
begin
  firstRow;
end;

end.

