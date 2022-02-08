(* Lookup table for NPC's, based on the environment *)

unit npc_lookup;

{$mode fpc}{$H+}

interface

uses
  globalUtils, universe, map, smell,
  { List of creatures }
  cave_rat, giant_cave_rat, blood_bat, large_blood_bat, green_fungus,
  redcap_lesser, redcap_lesser_lobber, small_green_fungus;

const
  (* Array of creatures found in a cave, ordered by cave level *)
  caveNPC1: array[1..4] of string = ('caveRat', 'caveRat', 'bloodBat', 'greenFungus');
  caveNPC2: array[1..6] of string =
    ('caveRat', 'giantRat', 'largeBat', 'redcapLesser', 'giantRat', 'greenFungus');
  caveNPC3: array[1..5] of string =
    ('smallGrFungus', 'redcapLesser', 'giantRat', 'redcapLesser', 'redcapLsrLbr');


(* randomly choose a creature and call the generate code directly *)
procedure NPCpicker(i: byte; dungeon: dungeonTerrain);

implementation

procedure NPCpicker(i: byte; dungeon: dungeonTerrain);
var
  r, c: smallint;
  randSelect: byte;
  monster: string;
begin
  monster := '';
  (* Choose random location on the map *)
  repeat
    r := globalutils.randomRange(2, (MAXROWS - 1));
    c := globalutils.randomRange(2, (MAXCOLUMNS - 1));
    (* choose a location that is not a wall, occupied or stair *)
  until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False) and
    (smellmap[r][c] > 4) and (maparea[r][c].Glyph = '.');

  (* Randomly choose an NPC based on dungeon depth *)
  case dungeon of
    tCave:
    begin { Level 1}
      if (universe.currentDepth = 1) then
      begin
        randSelect := globalUtils.randomRange(1, Length(caveNPC1));
        monster := caveNPC1[randSelect];
      end { Level 2 }
      else if (universe.currentDepth = 2) then
      begin
        randSelect := globalUtils.randomRange(1, Length(caveNPC2));
        monster := caveNPC2[randSelect];
      end { Level 3 }
      else if (universe.currentDepth = 3) then
      begin
        randSelect := globalUtils.randomRange(1, Length(caveNPC3));
        monster := caveNPC3[randSelect];
      end;
    end;
    tDungeon:
    begin
      { Placeholder }
    end;
  end;

  (* Create NPC *)
  case monster of
    'caveRat': cave_rat.createCaveRat(i, c, r);
    'giantRat': giant_cave_rat.createGiantCaveRat(i, c, r);
    'bloodBat': blood_bat.createBloodBat(i, c, r);
    'largeBat': large_blood_bat.createBloodBat(i, c, r);
    'greenFungus': green_fungus.createGreenFungus(i, c, r);
    'smallGrFungus': small_green_fungus.createSmallGreenFungus(i, c, r);
    'redcapLesser': redcap_lesser.createRedcap(i, c, r);
    'redcapLsrLbr': redcap_lesser_lobber.createRedcap(i, c, r);
  end;
end;

end.
