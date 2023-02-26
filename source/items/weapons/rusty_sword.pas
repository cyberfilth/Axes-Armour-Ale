(* A rusty, iron sword. Easily broken if thrown *)

unit rusty_sword;

{$mode fpc}{$H+}

interface

uses
  SysUtils, globalutils;

(* Create a sword *)
procedure createSword(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean; ident: smallint);
(* Remove weapon from inventory when thrown *)
procedure throw(itemID: smallint);
(* Check if weapon is damaged when thrown *)
procedure thrownDamaged(itmID: smallint; inventory: boolean);

implementation

uses
  items, entities, ui, player_inventory;

procedure createSword(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Rusty sword';
    itemDescription := 'adds 2D6+4 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matIron;
    useID := 30;
    glyph := chr(24);
    glyphColour := 'white';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 6;
    onMap := True;
    throwable := True;
    throwDamage := 9;
    dice := 2;
    adds := 4;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem(equipped: boolean; ident: smallint);
var
  info: shortstring;
begin
  info := 'You unequip the rusty sword';
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    info := 'You equip the rusty sword';
    if (player_inventory.inventory[ident].adds > 0) then
       info := info + ' The sword adds 2D6+' + IntToStr(player_inventory.inventory[ident].adds) + ' to your attack'
    else
       info := info + ' The sword adds 2D6 to your attack';
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice, 2);
    Inc(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage(info);
    ui.equippedWeapon := 'Rusty sword';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice, 2);
    Dec(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage(info);
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
  end;
end;

procedure throw(itemID: smallint);
begin
  entityList[0].weaponEquipped := False;
  Dec(entityList[0].weaponDice, 2);
  Dec(entityList[0].weaponAdds, player_inventory.inventory[itemID].adds);
  ui.equippedWeapon := 'No weapon equipped';
end;

procedure thrownDamaged(itmID: smallint; inventory: boolean);
begin
  if (inventory = True) then
  begin
    if (player_inventory.inventory[itmID].numUses = 3) then
    begin
      player_inventory.inventory[itmID].numUses := 2;
      player_inventory.inventory[itmID].throwDamage := 4;
    end
    else if (player_inventory.inventory[itmID].numUses = 2) then
    begin
      player_inventory.inventory[itmID].numUses := 1;
      player_inventory.inventory[itmID].throwDamage := 2;
      player_inventory.inventory[itmID].adds := 1;
      player_inventory.inventory[itmID].description := 'adds 2D+1 to attack';
    end
    else
    begin
      player_inventory.inventory[itmID].throwDamage := 1;
      player_inventory.inventory[itmID].adds := 0;
      player_inventory.inventory[itmID].description := '[blunt] adds 2D to attack';
    end;
  end
  else
  begin
     if (itemList[itmID].NumberOfUses = 3) then
    begin
      itemList[itmID].NumberOfUses := 2;
      itemList[itmID].throwDamage := 4;
    end
    else if (itemList[itmID].NumberOfUses = 2) then
    begin
      itemList[itmID].NumberOfUses := 1;
      itemList[itmID].throwDamage := 2;
      itemList[itmID].adds := 1;
      itemList[itmID].value := 3;   
      itemList[itmID].itemDescription := 'adds 2D+1 to attack';
    end
    else
    begin
      itemList[itmID].throwDamage := 1;
      itemList[itmID].adds := 0;
      itemList[itmID].value := 2;      
      itemList[itmID].itemDescription := '[blunt] adds 2D to attack';
    end;
  end;
end;

end.
