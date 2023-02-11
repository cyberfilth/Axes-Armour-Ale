unit merchant_inventory;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, items;

type
  (* Items in inventory *)
  Equipment = record
    id, useID, numUses, buy, sell, throwDamage, dice, adds: smallint;
    Name, description, article, glyph, glyphColour: shortstring;
    itemType: tItem;
    itemMaterial: tMaterial;
    throwable: boolean;
  end;

var
  (* Inventory of village merchant *)
  villageInv: array[0..9] of Equipment;

(* Initialise village merchant inventory *)
procedure initialiseVillageInventory;

implementation

procedure initialiseVillageInventory;
var
  i: byte;
begin
  for i := 0 to 9 do
  begin
    villageInv[i].id := i;
    villageInv[i].Name := 'Empty';
    villageInv[i].description := 'x';
    villageInv[i].article := 'x';
    villageInv[i].itemType := itmEmptySlot;
    villageInv[i].itemMaterial := matEmpty;
    villageInv[i].glyph := 'x';
    villageInv[i].glyphColour := 'x';
    villageInv[i].numUses := 0;
    villageInv[i].buy := 0;
    villageInv[i].sell := 0;
    villageInv[i].throwable := False;
    villageInv[i].throwDamage := 0;
    villageInv[i].dice := 0;
    villageInv[i].adds := 0;
    villageInv[i].useID := 0;
  end;
end;

end.
