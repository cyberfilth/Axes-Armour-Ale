unit merchant_inventory;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, items, globalutils;

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

procedure populateVillageInventory;
var
	randChoice: smallint;
begin
	randChoice := 0;
  with villageInv[0] do
  begin
    id := 0;
    Name := 'Bullwhip';
    description := 'Leather whip, 1D6+9 to attack';
    article := 'a';
    itemType := itmWeapon;
    itemMaterial := matLeather;
    glyph := chr(24);
    glyphColour := 'brown';
    numUses := 5;
    value := 7;
    throwable := True;
    throwDamage := 2;
    dice := 1;
    adds := 9;
    useID := 28;
  end;
  randChoice := randomRange(0, 1);
  if (randChoice = 0) then
  begin
   with villageInv[1] do
		begin
		  id := 1;
		  Name := 'large ale';
		  description := 'restores 12 health points';
		  article := 'a';
		  itemType := itmDrink;
		  itemMaterial := matFlammable;
		  glyph := '!';
		  glyphColour := 'lightCyan';
		  numUses := 5;
		  value := 3;
		  throwable := False;
		  throwDamage := 0;
		  dice := 0;
		  adds := 0;
		  useID := 29; 
		end;
	end
		else
		begin
			with villageInv[1] do
			begin
				id := 1;
				Name := 'Rusty sword';
				description := 'adds 2D6 to attack';
				article := 'a';
				itemType := itmWeapon;
				itemMaterial := matIron;
				glyph := chr(24);
				glyphColour := 'white';
				numUses := 5;
				value := 9;
				throwable := True;
				throwDamage := 9;
				dice := 2;
				adds := 0;
				useID := 30; 
			end;
		end;	
  with villageInv[2] do
  begin
    id := 2;
    Name := 'flask of wine';
    description := 'cures poison effects';
    article := 'a';
    itemType := itmDrink;
    itemMaterial := matFlammable;
    glyph := '!';
    glyphColour := 'green';
    numUses := 5;
    value := 2;
    throwable := False;
    throwDamage := 0;
    dice := 0;
    adds := 0;
    useID := 6;
  end;
end;

end.
