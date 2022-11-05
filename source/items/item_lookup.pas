(* Lookup table for items, based on the environment *)

unit item_lookup;

{$mode fpc}{$H+}

interface

uses
  universe, globalUtils,
  { List of drinks }
  ale_tankard, wine_flask,
  { List of weapons }
  crude_dagger, basic_club, rock, short_bow, pointy_stick, gnomish_dagger, gnomish_mace,
  gnomish_axe, bone_dagger,
  { List of armour }
  leather_armour1, cloth_armour1,
  { Quest items }
  smugglersMap, pixie_jar, pixie_jar_dim, parchment, gold_pieces,
  { Magical items }
  staff_minor_scorch, staff_bewilder, vampiric_staff,
  { Ammunition }
  arrow,
  { Traps }
  web_trap, poison_spore;

const
  (* Array of items found in a cave, ordered by cave level *)
  caveItems1: array[1..8] of string =
    ('aleTankard', 'clothArmour1', 'wineFlask', 'basicClub', 'rock',
    'pointyStick', 'arrow', 'gold');
  caveItems2: array[1..7] of string =
    ('aleTankard', 'aleTankard', 'crudeDagger', 'leatherArmour1',
    'rock', 'arrow', 'shortBow');
  caveItems3: array[1..6] of string =
    ('gold', 'crudeDagger', 'aleTankard', 'leatherArmour1', 'wineFlask', 'arrow');

  (* Array of items found in a crypt, ordered by dungeon level *)
  cptItems1: array[1..6] of string =
    ('aleTankard', 'stickyWeb', 'wineFlask', 'arrow', 'dimPixieJar', 'gold');
  cptItems2: array[1..8] of string =
    ('rock', 'aleTankard', 'crudeDagger', 'staffBewilder', 'gold',
    'dimPixieJar', 'arrow', 'shortBow');
  cptItems3: array[1..7] of string =
    ('aleTankard', 'staffVampire', 'aleTankard', 'rock', 'wineFlask', 'arrow', 'gold');

  (* Array of items found in a dungeon, ordered by dungeon level *)
  dgnItems1: array[1..5] of string =
    ('aleTankard', 'stickyWeb', 'wineFlask', 'arrow', 'dimPixieJar');
  dgnItems2: array[1..8] of string =
    ('aleTankard', 'aleTankard', 'crudeDagger', 'leatherArmour1',
    'dimPixieJar', 'arrow', 'shortBow', 'gold');
  dgnItems3: array[1..7] of string =
    ('aleTankard', 'crudeDagger', 'aleTankard', 'staffBewilder', 'wineFlask', 'arrow', 'gold');

(* Choose an item and call the generate code directly *)
procedure dispenseItem(dungeon: dungeonTerrain);
(* Execute useItem procedure *)
procedure lookupUse(x: smallint; equipped: boolean; id: smallint);
(* Used to drop a specific special item on each level *)
procedure dropFirstItem;

implementation

uses
  items, map;

procedure dispenseItem(dungeon: dungeonTerrain);
var
  r, c: smallint;
  randSelect: byte;
  thing: string;
begin
  thing := '';
  (* Choose random location on the map *)
  repeat
    r := globalutils.randomRange(3, (MAXROWS - 3));
    c := globalutils.randomRange(3, (MAXCOLUMNS - 3));
    (* choose a location that is not a wall or occupied *)
  until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False);

  (* Randomly choose an item based on dungeon depth *)
  case dungeon of
    tCave:
    begin { Level 1}
      if (universe.currentDepth = 1) then
      begin
        randSelect := globalUtils.randomRange(1, Length(caveItems1));
        thing := caveItems1[randSelect];
      end { Level 2 }
      else if (universe.currentDepth = 2) then
      begin
        randSelect := globalUtils.randomRange(1, Length(caveItems2));
        thing := caveItems2[randSelect];
      end { Level 3 }
      else if (universe.currentDepth = 3) then
      begin
        randSelect := globalUtils.randomRange(1, Length(caveItems3));
        thing := caveItems3[randSelect];
      end;
    end;
    tCrypt:
    begin
      if (universe.currentDepth = 1) then
      begin
        randSelect := globalUtils.randomRange(1, Length(cptItems1));
        thing := cptItems1[randSelect];
      end { Level 2 }
      else if (universe.currentDepth = 2) then
      begin
        randSelect := globalUtils.randomRange(1, Length(cptItems2));
        thing := cptItems2[randSelect];
      end { Level 3 }
      else if (universe.currentDepth = 3) then
      begin
        randSelect := globalUtils.randomRange(1, Length(cptItems3));
        thing := cptItems3[randSelect];
      end;
    end;
    tDungeon:
    begin
      if (universe.currentDepth = 1) then
      begin
        randSelect := globalUtils.randomRange(1, Length(dgnItems1));
        thing := dgnItems1[randSelect];
      end { Level 2 }
      else if (universe.currentDepth = 2) then
      begin
        randSelect := globalUtils.randomRange(1, Length(dgnItems2));
        thing := dgnItems2[randSelect];
      end { Level 3 }
      else if (universe.currentDepth = 3) then
      begin
        randSelect := globalUtils.randomRange(1, Length(dgnItems3));
        thing := dgnItems3[randSelect];
      end;
    end;
  end;

  (* Create Item *)
  case thing of
    'aleTankard': ale_tankard.createAleTankard(c, r);
    'rock': rock.createRock(c, r);
    'wineFlask': wine_flask.createWineFlask(c, r);
    'crudeDagger': crude_dagger.createDagger(c, r);
    'leatherArmour1': leather_armour1.createLeatherArmour(c, r);
    'basicClub': basic_club.createClub(c, r);
    'clothArmour1': cloth_armour1.createClothArmour(c, r);
    'staffMnrScorch': staff_minor_scorch.createStaff(c, r);
    'shortBow': short_bow.createShortBow(c, r);
    'pointyStick': pointy_stick.createPointyStick(c, r);
    'arrow': arrow.createArrow(c, r);
    'stickyWeb': web_trap.createWebTrap(c, r);
    'dimPixieJar': pixie_jar_dim.createPixieJarDim(c, r);
    'parchment': parchment.createParchment(c, r);
    'gold': gold_pieces.createGP(c, r);
    'staffBewilder': staff_bewilder.createStaff(c, r);
    'staffVampire': vampiric_staff.createStaff(c, r);
  end;
end;

procedure lookupUse(x: smallint; equipped: boolean; id: smallint);
begin
  case x of
    1: ale_tankard.useItem;
    2: crude_dagger.useItem(equipped, id);
    3: leather_armour1.useItem(equipped);
    4: basic_club.useItem(equipped);
    5: cloth_armour1.useItem(equipped);
    6: wine_flask.useItem;
    7: smugglersMap.obtainMap;
    8: staff_minor_scorch.useItem(equipped);
    9: rock.useItem;
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
    22: gold_pieces.useItem;
    23: staff_bewilder.useItem(equipped);
    25: vampiric_staff.useItem(equipped);
  end;
end;

procedure dropFirstItem;
var
  r, c: smallint;
begin
  if (dungeonType = tCave) then
  begin
    (* Choose random location on the map *)
    repeat
      r := globalutils.randomRange(3, (MAXROWS - 3));
      c := globalutils.randomRange(3, (MAXCOLUMNS - 3));
      (* choose a location that is not a wall or occupied *)
    until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False);
    SetLength(itemList, High(itemList) + 1);
    (* Drop the quest object *)
    if (universe.currentDepth = 3) then
      smugglersMap.createSmugglersMap(c, r)
    else if (universe.currentDepth = 2) then
      staff_minor_scorch.createStaff(c, r)
    else
      rock.createRock(c, r);
  end
  else if (dungeonType = tDungeon) then
  begin
    (* Choose random location on the map *)
    repeat
      r := globalutils.randomRange(3, (MAXROWS - 3));
      c := globalutils.randomRange(3, (MAXCOLUMNS - 3));
      (* choose a location that is not a wall or occupied *)
    until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False);
    SetLength(itemList, High(itemList) + 1);
    (* Drop the quest object *)
    if (universe.currentDepth = 3) then
      gnomish_axe.createGnomishAxe(c, r)
    else if (universe.currentDepth = 2) then
      parchment.createParchment(c, r)
    else
      wine_flask.createWineFlask(c, r);
  end;
end;

end.
