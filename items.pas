(* Items and objects in the game world *)

unit items;

{$mode objfpc}{$H+}

interface

uses
  ui;

type
  tItem = (itmDrink, itmWeapon, itmArmour, itmEnchantedWeapon, itmQuest, itmEmptySlot);

type
  tMaterial = (matSteel, matIron, matWood, matLeather, matWool, matPaper, matEmpty);

(* Store information about items *)
type
  Item = record
    (* Unique ID *)
    itemID: smallint;
    (* Item name, description and article *)
    itemName, itemDescription, itemArticle: shortstring;
    (* drink, weapon, armour, missile *)
    itemType: tItem;
    (* Item material *)
    itemMaterial: tMaterial;
    (* Used for lookup table *)
    useID: smallint;
    (* Position on game map *)
    posX, posY: smallint;
    (* Character used to represent item on game map *)
    glyph: shortstring;
    (* Colour of the glyph *)
    glyphColour: shortstring;
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

(* Generate list of items on the map *)
procedure initialiseItems;
(* Update the map display to show all items *)
procedure drawItemsOnMap(id: byte);
(* Is there an item at coordinates *)
function containsItem(x, y: smallint): boolean;
(* Get name of item at coordinates *)
function getItemName(x, y: smallint): shortstring;
(* Get description of item at coordinates *)
function getItemDescription(x, y: smallint): shortstring;
(* Count non-empty items in array *)
function countNonEmptyItems: byte;
(* Redraw all items *)
procedure redrawItems;

implementation

uses
  map;

procedure initialiseItems;
begin
  itemAmount := 0;
  { initialise array }
  SetLength(itemList, 0);
end;

procedure drawItemsOnMap(id: byte);
begin
  (* Redraw all items on the map display *)
  if (itemList[id].inView = True) then
  begin
    map.mapDisplay[itemList[id].posY, itemList[id].posX].glyphColour :=
      itemList[id].glyphColour;
    map.mapDisplay[itemList[id].posY, itemList[id].posX].glyph :=
      itemList[id].glyph;
  end;
end;

function containsItem(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 1 to itemAmount do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
    begin
      Result := True;
      exit;
    end;
  end;
end;

function getItemName(x, y: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
  for i := 1 to itemAmount do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemName;
  end;
end;

function getItemDescription(x, y: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
  for i := 1 to itemAmount do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemDescription;
  end;
end;

function countNonEmptyItems: byte;
var
  i, Count: byte;
begin
  Count := 0;
  for i := 1 to items.itemAmount do
    if (itemList[i].itemType <> itmEmptySlot) then
      Inc(Count);
  Result := Count;
end;

procedure redrawItems;
var
  i: byte;
begin
  for i := 1 to items.itemAmount do
  begin
    { Don't draw used items on the map }
    if (items.itemList[i].itemType <> itmEmptySlot) then
      if (map.canSee(items.itemList[i].posX, items.itemList[i].posY) = True) and
        (items.itemList[i].onMap = True) then
      begin
        items.itemList[i].inView := True;
        items.drawItemsOnMap(i);
        (* Display a message if this is the first time seeing this item *)
        if (items.itemList[i].discovered = False) then
        begin
          ui.displayMessage('You see ' + items.itemList[i].itemArticle + ' ' + items.itemList[i].itemName);
          items.itemList[i].discovered := True;
        end;
      end
      else
      begin
        items.itemList[i].inView := False;
        map.drawTile(itemList[i].posX, itemList[i].posY, 0);
      end;
  end;
end;

end.
