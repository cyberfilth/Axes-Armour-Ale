(* Lookup table for items, based on the environment *)

unit item_lookup;

{$mode fpc}{$H+}

interface

uses
  universe, globalUtils,
  { List of drinks }
  ale_tankard, potion_curePoison,
  { List of weapons }
  crude_dagger, basic_club,
  { List of armour }
  leather_armour1, cloth_armour1,
  { Quest items }
  smugglersMap,
  { Magical items }
  staff_minor_scorch;

const
  (* Array of items found in a cave, ordered by cave level *)
  caveItems1: array[1..4] of string =
    ('aleTankard', 'clothArmour1', 'curePotion', 'basicClub');
  caveItems2: array[1..4] of string =
    ('aleTankard', 'aleTankard', 'crudeDagger', 'leatherArmour1');
  caveItems3: array[1..5] of string =
    ('aleTankard', 'crudeDagger', 'aleTankard', 'leatherArmour1', 'curePotion');

(* Choose an item and call the generate code directly *)
procedure dispenseItem(i: byte; dungeon: dungeonTerrain);
(* Execute useItem procedure *)
procedure lookupUse(x: smallint; equipped: boolean);
(* Used to drop a specific special item on each level *)
procedure dropFirstItem;

implementation

uses
  items, map;

procedure dispenseItem(i: byte; dungeon: dungeonTerrain);
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
    tDungeon:
    begin
      { Placeholder }
    end;
  end;

  (* Create Item *)
  case thing of
    'aleTankard': ale_tankard.createAleTankard(i, c, r);
    'curePotion': potion_curePoison.createCurePotion(i, c, r);
    'crudeDagger': crude_dagger.createDagger(i, c, r);
    'leatherArmour1': leather_armour1.createLeatherArmour(i, c, r);
    'basicClub': basic_club.createClub(i, c, r);
    'clothArmour1': cloth_armour1.createClothArmour(i, c, r);
    'staffMnrScorch': staff_minor_scorch.createStaff(itemAmount, c, r);
  end;
end;

procedure lookupUse(x: smallint; equipped: boolean);
begin
  case x of
    1: ale_tankard.useItem;
    2: crude_dagger.useItem(equipped);
    3: leather_armour1.useItem(equipped);
    4: basic_club.useItem(equipped);
    5: cloth_armour1.useItem(equipped);
    6: potion_curePoison.useItem;
    7: smugglersMap.obtainMap;
    8: staff_minor_scorch.useItem(equipped);
  end;
end;

procedure dropFirstItem;
var
  r, c: smallint;
begin
  (* Choose random location on the map *)
  repeat
    r := globalutils.randomRange(3, (MAXROWS - 3));
    c := globalutils.randomRange(3, (MAXCOLUMNS - 3));
    (* choose a location that is not a wall or occupied *)
  until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False);
  items.listLength := Length(items.itemList);
  SetLength(items.itemList, items.itemAmount + 1);
  (* Drop the quest object *)
  if (universe.currentDepth = 3) then
    smugglersMap.createSmugglersMap(itemAmount, c, r)
  else
    //ale_tankard.createAleTankard(itemAmount, c, r);
    staff_minor_scorch.createStaff(itemAmount, c, r);
end;

end.
