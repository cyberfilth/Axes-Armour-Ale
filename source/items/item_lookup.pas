(* Lookup table for items, based on the environment *)

unit item_lookup;

{$mode fpc}{$H+}

interface

uses
  universe, globalUtils,
  { List of drinks }
  ale_tankard, wine_flask, large_ale, elven_wine,
  { List of weapons }
  crude_dagger, basic_club, rock, short_bow, pointy_stick, gnomish_dagger, gnomish_mace,
  gnomish_axe, bone_dagger, necro_axe, flint_dagger, terbutje, leather_whip, rusty_sword,
  { List of armour }
  leather_armour1, cloth_armour1, lesser_bone_armour,
  { Quest items }
  smugglersMap, pixie_jar, pixie_jar_dim, parchment, gold_pieces,
  { Magical items }
  staff_minor_scorch, staff_bewilder, vampiric_staff,
  { Ammunition }
  arrow,
  { Traps }
  web_trap, poison_spore;

const
  (* Items found in a cave, ordered by depth *)
  caveItems1: array[1..8] of string = ('aleTankard', 'clothArmour1', 'wineFlask', 'basicClub', 'rock', 'pointyStick', 'arrow', 'gold');
  caveItems2: array[1..7] of string = ('aleTankard', 'aleTankard', 'crudeDagger', 'leatherArmour1', 'rock', 'arrow', 'shortBow');
  caveItems3: array[1..6] of string = ('gold', 'crudeDagger', 'aleTankard', 'leatherArmour1', 'wineFlask', 'arrow');

  (* Items found in a stone cavern, ordered by depth *)
  stoneCavernItems1: array[1..7] of string = ('aleTankard', 'leatherArmour1', 'wineFlask', 'basicClub', 'rock', 'arrow', 'gold');
  stoneCavernItems2: array[1..6] of string = ('aleTankard', 'crudeDagger', 'leatherArmour1', 'rock', 'arrow', 'shortBow');
  stoneCavernItems3: array[1..6] of string = ('gold', 'crudeDagger', 'aleTankard', 'leatherArmour1', 'wineFlask', 'arrow');

  (* Items found in a crypt, ordered by depth *)
  cptItems1: array[1..6] of string = ('aleTankard', 'stickyWeb', 'wineFlask', 'arrow', 'dimPixieJar', 'gold');
  cptItems2: array[1..8] of string = ('rock', 'aleTankard', 'crudeDagger', 'staffBewilder', 'gold', 'dimPixieJar', 'arrow', 'shortBow');
  cptItems3: array[1..7] of string = ('aleTankard', 'staffVampire', 'aleTankard', 'rock', 'wineFlask', 'arrow', 'gold');

  (* Items found in a grid dungeon, ordered by depth *)
  dgnItems1: array[1..5] of string = ('aleTankard', 'stickyWeb', 'wineFlask', 'arrow', 'dimPixieJar');
  dgnItems2: array[1..8] of string = ('aleTankard', 'aleTankard', 'crudeDagger', 'leatherArmour1', 'dimPixieJar', 'arrow', 'shortBow', 'gold');
  dgnItems3: array[1..7] of string = ('aleTankard', 'crudeDagger', 'aleTankard', 'staffBewilder', 'wineFlask', 'arrow', 'gold');

  (* Items reserved for future dungeons - not yet in spawn tables *)
  (* flintDagger, terbutje, bullwhip, largeAle, rustySword, ElvenWine,  *)
  (* gnomishDagger, gnomishMace, gnomishAxe, boneDagger, lesserBoneArmour, necroAxe *)

(* Choose an item and call the generate code directly *)
procedure dispenseItem(dungeon: dungeonTerrain);
(* Execute useItem procedure *)
procedure lookupUse(x: smallint; equipped: boolean; id: smallint);
(* Used to drop a specific special item on each level *)
procedure dropFirstItem;

implementation

uses
  items, map;

(* Find a random empty, unoccupied tile and return its coordinates *)
procedure findEmptyTile(var r, c: smallint);
begin
  r := 0;
  c := 0;
  repeat
    r := globalUtils.randomRange(3, (MAXROWS - 3));
    c := globalUtils.randomRange(3, (MAXCOLUMNS - 3));
  until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False);
end;

(* Pick a random item name from a 1-indexed array of strings *)
function pickFromTable(const table: array of string): string;
var
  lo, hi: smallint;
  picked: string;
begin
  lo := Low(table);
  hi := High(table);
  picked := table[globalUtils.randomRange(lo, hi)];
  pickFromTable := picked;
end;

(* Spawn the named item at map coordinates (c, r) *)
procedure createItem(const thing: string; c, r: smallint);
begin
  case thing of
    'aleTankard':    ale_tankard.createAleTankard(c, r);
    'rock':          rock.createRock(c, r);
    'wineFlask':     wine_flask.createWineFlask(c, r);
    'crudeDagger':   crude_dagger.createDagger(c, r);
    'leatherArmour1':leather_armour1.createLeatherArmour(c, r);
    'basicClub':     basic_club.createClub(c, r);
    'clothArmour1':  cloth_armour1.createClothArmour(c, r);
    'staffMnrScorch':staff_minor_scorch.createStaff(c, r);
    'shortBow':      short_bow.createShortBow(c, r);
    'pointyStick':   pointy_stick.createPointyStick(c, r);
    'arrow':         arrow.createArrow(c, r);
    'stickyWeb':     web_trap.createWebTrap(c, r);
    'dimPixieJar':   pixie_jar_dim.createPixieJarDim(c, r);
    'parchment':     parchment.createParchment(c, r);
    'gold':          gold_pieces.createGP(c, r);
    'staffBewilder': staff_bewilder.createStaff(c, r);
    'staffVampire':  vampiric_staff.createStaff(c, r);
    'flintDagger':   flint_dagger.createFlintDagger(c, r);
    'terbutje':      terbutje.createTerbutje(c, r);
    'bullwhip':      leather_whip.createWhip(c, r);
    'largeAle':      large_ale.createLargeAle(c, r);
    'rustySword':    rusty_sword.createSword(c, r);
    'ElvenWine':     elven_wine.createWineFlask(c, r);
  end;
end;

procedure dispenseItem(dungeon: dungeonTerrain);
var
  r, c: smallint;
  thing: string;
begin
  r := 0;
  c := 0;
  findEmptyTile(r, c);
  thing := '';

  case dungeon of
    tCave:
      case universe.currentDepth of
        1: thing := pickFromTable(caveItems1);
        2: thing := pickFromTable(caveItems2);
        3: thing := pickFromTable(caveItems3);
      end;
    tStoneCavern:
      case universe.currentDepth of
        1: thing := pickFromTable(stoneCavernItems1);
        2: thing := pickFromTable(stoneCavernItems2);
        3: thing := pickFromTable(stoneCavernItems3);
      end;
    tCrypt:
      case universe.currentDepth of
        1: thing := pickFromTable(cptItems1);
        2: thing := pickFromTable(cptItems2);
        3: thing := pickFromTable(cptItems3);
      end;
    tDungeon:
      case universe.currentDepth of
        1: thing := pickFromTable(dgnItems1);
        2: thing := pickFromTable(dgnItems2);
        3: thing := pickFromTable(dgnItems3);
      end;
  end;

  createItem(thing, c, r);
end;

procedure lookupUse(x: smallint; equipped: boolean; id: smallint);
begin
  case x of
    1:  ale_tankard.useItem;
    2:  crude_dagger.useItem(equipped, id);
    3:  leather_armour1.useItem(equipped);
    4:  basic_club.useItem(equipped);
    5:  cloth_armour1.useItem(equipped);
    6:  wine_flask.useItem;
    7:  smugglersMap.obtainMap;
    8:  staff_minor_scorch.useItem(equipped);
    9:  rock.useItem;
    10: short_bow.useItem(equipped);
    11: pointy_stick.useItem(equipped);
    12: arrow.useItem;
    13: pixie_jar.useItem;
    14: gnomish_dagger.useItem(equipped, id);
    15: web_trap.useItem;
    16: poison_spore.useItem;
    17: gnomish_mace.useItem(equipped, id);
    18: gnomish_axe.useItem(equipped, id);
    19: parchment.collectParchment;
    20: bone_dagger.useItem(equipped, id);
    21: lesser_bone_armour.useItem(equipped);
    22: gold_pieces.useItem;
    23: staff_bewilder.useItem(equipped);
    24: necro_axe.useItem(equipped, id);
    25: vampiric_staff.useItem(equipped);
    26: flint_dagger.useItem(equipped, id);
    27: terbutje.useItem(equipped);
    28: leather_whip.useItem(equipped);
    29: large_ale.useItem;
    30: rusty_sword.useItem(equipped, id);
    31: elven_wine.useItem;
  end;
end;

procedure dropFirstItem;
var
  r, c: smallint;
begin
  r := 0;
  c := 0;
  findEmptyTile(r, c);

  case dungeonType of
    tCave:
      case universe.currentDepth of
        3: smugglersMap.createSmugglersMap(c, r);
        2: staff_minor_scorch.createStaff(c, r);
        else rock.createRock(c, r);
      end;
    tDungeon:
      case universe.currentDepth of
        3: gnomish_axe.createGnomishAxe(c, r);
        2: parchment.createParchment(c, r);
        else wine_flask.createWineFlask(c, r);
      end;
    tCrypt:
      case universe.currentDepth of
        3: web_trap.createWebTrap(c, r);
        2: parchment.createParchment(c, r);
        else wine_flask.createWineFlask(c, r);
      end;
    tStoneCavern:
      case universe.currentDepth of
        3: basic_club.createClub(c, r);
        2: gold_pieces.createGP(c, r);
        else wine_flask.createWineFlask(c, r);
      end;
  end;
end;

end.
