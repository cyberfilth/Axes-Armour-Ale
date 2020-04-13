(* Items and objects in the game world *)
unit items;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  Graphics, globalutils, map,
  (* Import the items *)
  ale_tankard;

type
  (* eunm for types of item *)
  itemCategory = (drink, weapon, armour, missile);

  (* Store information about items *)
  Item = record
    (* Unique ID *)
    itemID: smallint;
    (* Item name & description *)
    itemName, itemDescription: shortstring;
    (* drink, weapon, armour, missile *)
    itemType: itemCategory;
    (* Used for lookup table *)
    useID: smallint;
    (* Position on game map *)
    posX, posY: smallint;
    (* Character used to represent item on game map *)
    glyph: char;
    (* Is the item in the players FoV *)
    inView: boolean;
    (* Is the item on the map *)
    onMap: boolean;
    (* Displays a message the first time item is seen *)
    discovered: boolean;
  end;


var
  itemList: array of Item;
  itemAmount, listLength: smallint;
  aleTankard: TBitmap;

(* Load item textures *)
procedure setupItems;
(* Generate list of items on the map *)
procedure spawnItem;
(* Draw item on screen *)
procedure drawItem(c, r: smallint; glyph: char);
(* Redraw all items *)
procedure redrawItems;
(* Execute useItem procedure *)
procedure lookupUse(x: smallint);

implementation

procedure setupItems;
begin
  aleTankard := TBitmap.Create;
  aleTankard.LoadFromResourceName(HINSTANCE, 'ALE1');
end;

procedure spawnItem;
var
  i, p: smallint;
begin
  itemAmount := 1;
  // initialise array, 1 based
  SetLength(itemList, 1);
  p := 2; // used to space out item location
  // place the item
  for i := 1 to itemAmount do
  begin
    createAleTankard(i, globalutils.currentDgncentreList[p + 2].x,
      globalutils.currentDgncentreList[p + 2].y);
  end;
end;

procedure drawItem(c, r: smallint; glyph: char);
begin { TODO : When more items are created, swap this out for a CASE statement }
  if (glyph = '!') then
    drawToBuffer(mapToScreen(c), mapToScreen(r), aleTankard);
end;

procedure redrawItems;
var
  i: smallint;
begin
  for i := 1 to itemAmount do
  begin
    if (itemList[i].inView = True) and (itemList[i].onMap = True) then
    begin
      drawItem(itemList[i].posX, itemList[i].posY, itemList[i].glyph);
    end;
  end;
end;

{ TODO : To be replaced by calling the useItem procedure of an advanced record. This lookup table is just for testing }
procedure lookupUse(x: smallint);
begin
  case x of
    1: ale_tankard.useItem;
  end;
end;

end.
