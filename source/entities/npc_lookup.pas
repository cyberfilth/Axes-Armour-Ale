(* Lookup table for NPC's, based on the environment *)

unit npc_lookup;

{$mode fpc}{$H+}

interface

uses
  globalUtils, universe, map, smell,
  { List of creatures }
  cave_rat, giant_cave_rat, blood_bat, large_blood_bat, green_fungus, mushroom_person,
  redcap_lesser, redcap_lesser_lobber, small_green_fungus, small_hyena, redcap_fungus,
  hyena_fungus, small_hornet, small_corpse_spider, gnome_warrior, gnome_assassin,
  crypt_wolf, blue_fungus, embalming_spider, gnome_cultist, bogle_drunk, ghoul_lvl1,
  skeleton_lvl1, zombie_weak, goblin_necromancer;

(* randomly choose a creature and call the generate code directly *)
procedure NPCpicker(i: byte; unique: boolean; dungeon: dungeonTerrain);

implementation

procedure NPCpicker(i: byte; unique: boolean; dungeon: dungeonTerrain);
const
  (* Array of creatures found in a cave, ordered by cave level *)
  caveNPC1: array[1..5] of string =
    ('caveRat', 'smallHyena', 'caveRat', 'bloodBat', 'greenFungus');
  caveNPC2: array[1..7] of string =
    ('smallHyena', 'giantRat', 'largeBat', 'redcapLesser', 'giantRat',
    'greenFungus', 'hobFungus');
  caveNPC3: array[1..7] of string =
    ('smallGrFungus', 'redcapLesser', 'giantRat', 'redcapLesser',
    'greenFungus', 'matango', 'hyenaFungus');
  caveUnique1: array[1..2] of string =
    ('largeBat', 'bloodBat');
  caveUnique2: array[1..2] of string =
    ('redcapLsrLbr', 'largeBat');
  caveUnique3: array[1..2] of string =
    ('redcapLsrLbr', 'redcapLsrLbr');

  (* Array of creatures found in a dungeon, ordered by dungeon level *)
  dgnNPC1: array[1..4] of string =
    ('smallHornet', 'smlCorpseSpider', 'GnmWarr', 'GnmWarr');
  dgnNPC2: array[1..5] of string =
    ('smlCorpseSpider', 'GnmCult', 'GnmWarr', 'GnmWarr', 'blueFungus');
  dgnNPC3: array[1..5] of string =
    ('GnmCult', 'GnmWarr', 'giantRat', 'bloodBat', 'smlCorpseSpider');
  dgnUnique1: array[1..2] of string =
    ('blueFungus', 'GnmAss');
  dgnUnique2: array[1..2] of string =
    ('embalmSpider', 'GnmAss');
  dgnUnique3: array[1..2] of string =
    ('drunkBogle', 'drunkBogle');

  (* Array of creatures found in a crypt, ordered by dungeon level *)
    cptNPC1: array[1..4] of string =
      ('bloodBat', 'smlCorpseSpider', 'ghoulLVL1', 'skeletonLVL1');
    cptNPC2: array[1..5] of string =
      ('zombieWeak', 'ghoulLVL1', 'zombieWeak', 'skeletonLVL1', 'blueFungus');
    cptNPC3: array[1..5] of string =
      ('GnmCult', 'GnmWarr', 'giantRat', 'bloodBat', 'smlCorpseSpider');
    cptUnique1: array[1..2] of string =
      ('greenFungus', 'zombieWeak');
    cptUnique2: array[1..2] of string =
      ('embalmSpider', 'skeletonLVL1');
    cptUnique3: array[1..2] of string =
      ('GobNecro', 'GobNecro');

var
  r, c: smallint;
  randSelect: byte;
  monster: string;
begin
  r := 0;
  c := 0;
  monster := '';
  (* Choose random location on the map *)
  repeat
    r := globalutils.randomRange(2, (MAXROWS - 1));
    c := globalutils.randomRange(2, (MAXCOLUMNS - 1));
    (* choose a location that is not a wall, occupied or stair, also not next to the player *)
  until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False) and
    (smellmap[r][c] > 4) and (maparea[r][c].Glyph = '.');

  (* Randomly choose an NPC based on dungeon depth *)
  if (unique = False) then
  begin
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
      tCrypt:
      begin
        if (universe.currentDepth = 1) then
        begin
          randSelect := globalUtils.randomRange(1, Length(cptNPC1));
          monster := cptNPC1[randSelect];
        end { Level 2 }
        else if (universe.currentDepth = 2) then
        begin
          randSelect := globalUtils.randomRange(1, Length(cptNPC2));
          monster := cptNPC2[randSelect];
        end { Level 3 }
        else if (universe.currentDepth = 3) then
        begin
          randSelect := globalUtils.randomRange(1, Length(cptNPC3));
          monster := cptNPC3[randSelect];
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
  end
  else
    (* Select a unique NPC *)
  begin
    case dungeon of
      tCave:
      begin { Level 1}
        if (universe.currentDepth = 1) then
        begin
          randSelect := globalUtils.randomRange(1, Length(caveUnique1));
          monster := caveUnique1[randSelect];
        end { Level 2 }
        else if (universe.currentDepth = 2) then
        begin
          randSelect := globalUtils.randomRange(1, Length(caveUnique2));
          monster := caveUnique2[randSelect];
        end { Level 3 }
        else if (universe.currentDepth = 3) then
        begin
          randSelect := globalUtils.randomRange(1, Length(caveUnique3));
          monster := caveUnique3[randSelect];
        end;
      end;
      tCrypt:
      begin
        if (universe.currentDepth = 1) then
        begin
          randSelect := globalUtils.randomRange(1, Length(cptUnique1));
          monster := cptUnique1[randSelect];
        end { Level 2 }
        else if (universe.currentDepth = 2) then
        begin
          randSelect := globalUtils.randomRange(1, Length(cptUnique2));
          monster := cptUnique2[randSelect];
        end { Level 3 }
        else if (universe.currentDepth = 3) then
        begin
          randSelect := globalUtils.randomRange(1, Length(cptUnique3));
          monster := cptUnique3[randSelect];
        end;
      end;
      tDungeon:
      begin
        if (universe.currentDepth = 1) then
        begin
          randSelect := globalUtils.randomRange(1, Length(dgnUnique1));
          monster := dgnUnique1[randSelect];
        end { Level 2 }
        else if (universe.currentDepth = 2) then
        begin
          randSelect := globalUtils.randomRange(1, Length(dgnUnique2));
          monster := dgnUnique2[randSelect];
        end { Level 3 }
        else if (universe.currentDepth = 3) then
        begin
          randSelect := globalUtils.randomRange(1, Length(dgnUnique3));
          monster := dgnUnique3[randSelect];
        end;
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
    'GnmWarr': gnome_warrior.createGnomeWarrior(i, c, r);
    'GnmAss': gnome_assassin.createGnomeAssassin(i, c, r);
    'cryptWolf': crypt_wolf.createCryptWolf(i, c, r);
    'blueFungus': blue_fungus.createBlueFungus(i, c, r);
    'embalmSpider': embalming_spider.createEmbalmSpider(i, c, r);
    'GnmCult': gnome_cultist.createGnomeCultist(i, c, r);
    'drunkBogle': bogle_drunk.createDrunkBogle(i, c, r);
    'ghoulLVL1': ghoul_lvl1.createGhoul(i, c, r);
    'skeletonLVL1': skeleton_lvl1.createSkeleton(i, c, r);
    'zombieWeak': zombie_weak.createZombie(i, c, r);
    'GobNecro': goblin_necromancer.createNecromancer(i, c, r);
  end;
end;

end.
