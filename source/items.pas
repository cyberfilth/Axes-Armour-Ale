(* Items and objects in the game world *)

unit items;

{$mode objfpc}{$H+}

interface

uses
  ui, web_trap, poison_spore, globalutils;

type
  tItem = (itmDrink, itmWeapon, itmArmour, itmQuest, itmProjectile, itmEmptySlot, itmProjectileWeapon, itmAmmo, itmLightSource, itmTrap, itmTreasure);

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
    (* Number of uses for magic items / durability for breakable items *)
    NumberOfUses: smallint;
    (* Value of buying / selling items *)
    value: smallint;
    (* Character used to represent item on game map *)
    glyph: shortstring;
    (* Colour of the glyph *)
    glyphColour: shortstring;
    (* Is the item in the players FoV *)
    inView: boolean;
    (* Is the item on the map *)
    onMap: boolean;
    (* Can the item be thrown *)
    throwable: boolean;
    (* Damage when thrown *)
    throwDamage: smallint;
    (* Weapon damage *)
    dice, adds: smallint;
    (* Displays a message the first time item is seen *)
    discovered: boolean;
  end;

type
  TitemList = array of Item;

var
  itemList: TitemList;
  indexID: smallint;

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
(* Get item ID at coordinates *)
function getItemID(x, y: smallint): smallint;
(* Get the item glyph at coordinates *)
function getItemGlyph(x, y: smallint): shortstring;
(* Get the glyph colour at coordinates *)
function getItemColour(x, y: smallint): shortstring;
(* Get item type *)
function getItemType(x, y: smallint): tItem;
(* Is item on floor throwable *)
function isItemThrowable(x, y: smallint): boolean;
(* Get the Throw Damage at coordinates *)
function getThrowDamage(x, y: smallint): smallint;
(* Check to see if a trap has been triggered *)
procedure checkForTraps;
(* Count non-empty items in array *)
function countNonEmptyItems: byte;
(* Redraw all items *)
procedure redrawItems;

implementation

uses
  map;

procedure initialiseItems;
begin
  SetLength(itemList, 0);
end;

procedure drawItemsOnMap(id: byte);
begin
  (* Redraw all items on the map display *)
  if (itemList[id].inView = True) then
  begin
    map.mapDisplay[itemList[id].posY, itemList[id].posX].glyphColour := itemList[id].glyphColour;
    map.mapDisplay[itemList[id].posY, itemList[id].posX].glyph := itemList[id].glyph;
  end;
end;

function containsItem(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 0 to High(itemList) do
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
  for i := 0 to High(itemList) do
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
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemDescription;
  end;
end;

function getItemID(x, y: smallint): smallint;
var
  i: smallint;
begin
  Result := 0;
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemID;
  end;
end;

function getItemGlyph(x, y: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].glyph;
  end;
end;

function getItemColour(x, y: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].glyphColour;
  end;
end;

function getItemType(x, y: smallint): tItem;
var
  i: smallint;
begin
  Result := itmEmptySlot;
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemType;
  end;
end;

function isItemThrowable(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
    begin
      if (itemList[i].throwable = True) then
        Result := True;
      exit;
    end;
  end;
end;

function getThrowDamage(x, y: smallint): smallint;
var
  i: smallint;
begin
  Result := 0;
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
    begin
        Result := itemList[i].throwDamage;
      exit;
    end;
  end;
end;

procedure checkForTraps;
var
  i: byte;
begin
  if (Length(itemList) <> 0) then
  begin
  for i := 0 to High(itemList) do
  begin
    if (itemList[i].itemType = itmTrap) then
    begin
       if (itemList[i].itemName = 'web') then
          web_trap.triggered(i)
       else if (itemList[i].itemName = 'spore') then
          poison_spore.triggered(i);
    end;
  end;
  end;
end;

function countNonEmptyItems: byte;
var
  i, Count: byte;
begin
  Result := 0;
  if (Length(itemList) <> 0) then
  begin
  Count := 0;
  for i := 0 to High(itemList) do
    if (itemList[i].itemType <> itmEmptySlot) and (itemList[i].itemName <> '') then
      Inc(Count);
  Result := Count;
  end;
end;

procedure redrawItems;
var
  i: byte;
begin
  if (Length(itemList) <> 0) then
  begin
  for i := 0 to High(itemList) do
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
end;

end.
