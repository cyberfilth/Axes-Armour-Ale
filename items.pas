(* Items and objects in the game world *)
unit items;

{$mode objfpc}{$H+}

interface

uses
  Graphics, globalutils, map,
  (* Import the items *)
  ale_tankard;

type
  (* Store information about items *)
  Item = record
    (* Unique ID *)
    itemID: smallint;
    (* Item name & description *)
    itemName, itemDescription: shortstring;
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
  end;        { TODO : action:
Consumable
Weapon
Armour
Missile }

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

end.
