(* Generate the game world, caves, dungeons, its levels and related info *)

unit universe;

{$mode objfpc}{$H+}
{$modeswitch UnicodeStrings}
{$IFOPT D+} {$DEFINE DEBUG} {$ENDIF}

interface

uses
  SysUtils, globalUtils, cave, smell, player_stats, pixie_jar;

(* Types of locations that can be explored. See 'architect' unit for explanation *)
type
  dungeonTerrain = (tCave, tCavern, tDungeon, tCrypt, tVillage);

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

(* Creates a dungeon of a specified type *)
procedure createNewDungeon(levelType: dungeonTerrain);
(* Spawn creatures based on dungeon type and player level *)
procedure spawnDenizens;
(* Drop items based on dungeon type and player level *)
procedure litterItems;
(* Generate the overworld *)
procedure createEllanToll;


implementation

uses
  map, npc_lookup, entities, items, item_lookup, file_handling, overworld;

procedure createNewDungeon(levelType: dungeonTerrain);
begin
  r := 1;
  c := 1;
  (* Increment the number of dungeons *)
  Inc(dlistLength);
  (* First dungeon is locked when you enter *)
  if (dlistLength = 1) then
    player_stats.canExitDungeon := False
  else
    player_stats.canExitDungeon := True;
  (* Dungeons unique ID number becomes the highest dungeon amount number *)
  uniqueID := dlistLength;
  { First cave }
  title := 'Smugglers cave';
  dungeonType := levelType;
  totalDepth := 3;
  currentDepth := 1;

  (* generate the dungeon *)
  case levelType of
    tCave: cave.generate(dlistLength, totalDepth);
    tDungeon: ;
  end;

  (* Copy the 1st floor of the current dungeon to the game map *)
  map.setupMap;
end;

procedure spawnDenizens;
var
  { Number of NPC's to create }
  NPCnumber, i: byte;
begin
  { Generate a smell map so NPC's aren't initially placed next to the player }
  sniff;
  { Based on number of rooms in current level, dungeon type & dungeon level }
  NPCnumber := totalRooms + currentDepth;
  { player level is considered when generating the NPCs }
  entities.npcAmount := NPCnumber;

  case dungeonType of
    tDungeon: ;
    tCave: { Cave }
    begin
      (* Create the NPC's *);
      for i := 1 to NPCnumber do
      begin
        { create an encounter table: Monster type: Dungeon type: floor number }
        { NPC generation will take the Player level into account when creating stats }
        npc_lookup.NPCpicker(i, tCave);
      end;
    end;
  end;
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

  case dungeonType of
    tDungeon: ;
    tCave: { Cave }
    begin
      (* Create the items *);
      for i := 0 to (ItemNumber - 1) do
      begin
        item_lookup.dispenseItem(tCave);
      end;
      (* Drop a single light source on each floor *)
      pixie_jar.createPixieJar;
    end;
  end;
end;

procedure createEllanToll;
begin
  (* Generate the island *)
  overworld.generate;
  (* Save the island to disk *)
  file_handling.saveOverworldMap;
  OWgen := True;
end;

end.
