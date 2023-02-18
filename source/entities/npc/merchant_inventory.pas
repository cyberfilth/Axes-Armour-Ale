unit merchant_inventory;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, items;

type
  (* Items in inventory *)
  Equipment = record
    id, useID, numUses, value, throwDamage, dice, adds: smallint;
    Name, description, article, glyph, glyphColour: shortstring;
    itemType: tItem;
    itemMaterial: tMaterial;
    throwable: boolean;
  end;

var
  (* Inventory of village merchant *)
  villageInv: array[0..9] of Equipment;
  (* Purse of village merchant *)
  villagePurse: integer;

(* Initialise village merchant inventory *)
procedure initialiseVillageInventory;
(* Add items to inventory *)
procedure populateVillageInventory;

implementation

procedure initialiseVillageInventory;
var
  i: byte;
begin
  for i := 0 to 9 do
      {$I merchant_inventoryemptyslot}
end;

// TEST CODE: this will be replaced by a randomly generated list of items
procedure populateVillageInventory;
begin
  with villageInv[0] do
  begin
    id := 0;
    Name := 'pointy stick';
    description := 'adds 1D6+1 to attack';
    article := 'a';
    itemType := itmWeapon;
    itemMaterial := matWood;
    glyph := chr(173);
    glyphColour := 'brown';
    numUses := 5;
    value := 1;
    throwable := True;
    throwDamage := 4;
    dice := 1;
    adds := 1;
    useID := 11;
  end;
end;

end.
