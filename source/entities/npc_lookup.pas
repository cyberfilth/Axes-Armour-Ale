(* Lookup table for NPC's, based on the environment *)

unit npc_lookup;

{$mode fpc}{$H+}

interface

uses
  globalUtils, universe, map, smell,
  { List of creatures }
  cave_rat, giant_cave_rat, blood_bat, large_blood_bat, green_fungus, mushroom_person,
  redcap_lesser, redcap_lesser_lobber, small_green_fungus, small_hyena, redcap_fungus,
  hyena_fungus, small_hornet, small_corpse_spider;

const
  (* Array of creatures found in a cave, ordered by cave level *)
  caveNPC1: array[1..5] of string =
    ('caveRat', 'smallHyena', 'caveRat', 'bloodBat', 'greenFungus');
  caveNPC2: array[1..7] of string =
    ('smallHyena', 'giantRat', 'largeBat', 'redcapLesser', 'giantRat',
    'greenFungus', 'hobFungus');
  caveNPC3: array[1..7] of string =
    ('smallGrFungus', 'redcapLesser', 'giantRat', 'redcapLesser',
    'redcapLsrLbr', 'matango', 'hyenaFungus');
  (* Array of creatures found in a dungeon, ordered by dungeon level *)
  dgnNPC1: array[1..5] of string =
    ('smallHornet', 'smlCorpseSpider', 'smallHornet', 'bloodBat', 'smlCorpseSpider');
  dgnNPC2: array[1..7] of string =
    ('smallHyena', 'giantRat', 'largeBat', 'redcapLesser', 'giantRat',
    'greenFungus', 'hobFungus');
  dgnNPC3: array[1..7] of string =
    ('smallGrFungus', 'redcapLesser', 'giantRat', 'redcapLesser',
    'redcapLsrLbr', 'matango', 'hyenaFungus');

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
    (* choose a location that is not a wall, occupied or stair, also not next to the player *)
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
      if (universe.currentDepth = 1) then
      begin
        randSelect := globalUtils.randomRange(1, Length(dgnNPC1));
        monster := dgnNPC1[randSelect];
      end { Level 2 }
      else if (universe.currentDepth = 2) then
      begin
        randSelect := globalUtils.randomRange(1, Length(dgnNPC2));
        monster := dgnNPC2[randSelect];
      end { Level 3 }
      else if (universe.currentDepth = 3) then
      begin
        randSelect := globalUtils.randomRange(1, Length(dgnNPC3));
        monster := dgnNPC3[randSelect];
      end;
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
    'matango': mushroom_person.createMushroomPerson(i, c, r);
    'redcapLesser': redcap_lesser.createRedcap(i, c, r);
    'redcapLsrLbr': redcap_lesser_lobber.createRedcap(i, c, r);
    'hobFungus': redcap_fungus.createRedcapFungus(i, c, r);
    'smallHyena': small_hyena.createSmallHyena(i, c, r);
    'hyenaFungus': hyena_fungus.createInfectedHyena(i, c, r);
    'smlCorpseSpider': small_corpse_spider.createCorpseSpider(i, c, r);
    'smallHornet': small_hornet.createSmallHornet(i, c, r);
  end;
end;

end.