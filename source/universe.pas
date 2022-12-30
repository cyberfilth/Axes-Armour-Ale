(* Generate the game world, caves, dungeons, its levels and related info *)

unit universe;

{$mode objfpc}{$H+}
{$modeswitch UnicodeStrings}

interface

uses
  SysUtils, globalUtils, cave, smell, player_stats, pixie_jar, smallGrid, crypt, stone_cavern, village;

var
  (* Number of dungeons *)
  dlistLength, uniqueID: smallint;
  (* Info about current dungeon *)
  totalRooms, currentDepth, totalDepth: byte;
  dungeonType: dungeonTerrain;
  (* Name of the current dungeon *)
  title: string;
  (* Used when a dungeon is first generated *)
  currentDungeon: array[1..MAXROWS, 1..MAXCOLUMNS] of shortstring;
  (* Flag to show if this level has been visited before *)
  levelVisited: boolean;
  (* Has the the overworld been generated before *)
  OWgen: boolean;
  homeland: string;

(* Creates a dungeon of a specified type *)
procedure createNewDungeon(title: string; levelType: dungeonTerrain; dID: smallint);
(* Spawn creatures based on dungeon type and player level *)
procedure spawnDenizens;
(* Drop items based on dungeon type and player level *)
procedure litterItems;
(* Generate the overworld *)
procedure createEllanToll;


implementation

uses
  map, npc_lookup, entities, items, item_lookup, file_handling, overworld;

procedure createNewDungeon(title: string; levelType: dungeonTerrain; dID: smallint);
begin
  r := 1;
  c := 1;
  (* First dungeon is locked when you enter *)
  if (dID = 1) then
    player_stats.canExitDungeon := False
  else
    player_stats.canExitDungeon := True;
  (* Dungeons unique ID number becomes the highest dungeon amount number *)
  uniqueID := dID;
  universe.title := title;
  { First cave }
  dungeonType := levelType;
  if (dungeonType = tVillage) then
    totalDepth := 1
  else
    totalDepth := 3;
  currentDepth := 1;

  (* generate the dungeon *)
  case levelType of
    tCave: cave.generate(UTF8Encode(title), dID, totalDepth);
    tDungeon: smallGrid.generate(UTF8Encode(title), dID, totalDepth);
    tCrypt: crypt.generate(UTF8Encode(title), dID, totalDepth);
    tStoneCavern: stone_cavern.generate(UTF8Encode(title), dID, totalDepth);
    tVillage: village.generate(UTF8Encode(title), dID);
  end;

  (* Copy the 1st floor of the current dungeon to the game map *)
  map.setupMap;
end;

procedure spawnDenizens;
var
  { Number of NPC's to create }
  NPCnumber, i: byte;
begin
  NPCnumber := 0;
  { Generate a smell map so NPC's aren't initially placed next to the player }
  sniff;
  { Based on number of rooms in current level, dungeon type & dungeon level
     Caves have more lower level enemies, dungeons have fewer but stronger }
  if (dungeonType = tCave) or (dungeonType = tStoneCavern) then
    NPCnumber := totalRooms + currentDepth
  else if (dungeonType = tDungeon) or (dungeonType = tCrypt) then
    NPCnumber := (totalRooms div 2) + currentDepth
  else if (dungeonType = tVillage) then
    NPCnumber := 9;
  { player level is considered when generating the NPCs }
  entities.npcAmount := NPCnumber;
  { First npcAmount-1 number of enemies are scattered on the floor }
  for i := 1 to (NPCnumber - 1) do
  begin
    { create an encounter table: Monster type: Dungeon type: floor number }
    { NPC generation will take the Player level into account when creating stats }
    npc_lookup.NPCpicker(i, False, dungeonType);
  end;

  { Unique enemy is added to each floor }
  npc_lookup.NPCpicker(NPCnumber, True, dungeonType);
end;

procedure litterItems;
var
  { Number of items to create }
  ItemNumber, i: byte;
begin
  { Drop a unique item on level }
  item_lookup.dropFirstItem;
  { Based on number of rooms in current level, dungeon type & dungeon level }
  ItemNumber := (totalRooms div 3) + currentDepth;

  (* Create the items *);
  for i := 0 to (ItemNumber - 1) do
  begin
    item_lookup.dispenseItem(dungeonType);
  end;
  (* Drop a single light source on each floor *)
  pixie_jar.createPixieJar;
end;

procedure createEllanToll;
begin
  file_handling.saveGame;
  (* Generate the island *)
  overworld.generate;
  (* Save the island to disk *)
  file_handling.saveOverworldMap;
  OWgen := True;
end;

end.
