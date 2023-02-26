(* A crude, iron dagger. Easily broken if thrown *)

unit crude_dagger;

{$mode fpc}{$H+}

interface

uses
  SysUtils, globalutils;

(* Create a dagger *)
procedure createDagger(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean; ident: smallint);
(* Remove weapon from inventory when thrown *)
procedure throw(itemID: smallint);
(* Check if weapon is damaged when thrown *)
procedure thrownDamaged(itmID: smallint; inventory: boolean);

implementation

uses
  items, entities, ui, player_inventory;

procedure createDagger(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'crude dagger';
    itemDescription := 'adds 1D6+2 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matIron;
    useID := 2;
    glyph := chr(24);
    glyphColour := 'lightGrey';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 3;
    value := 2;
    onMap := True;
    throwable := True;
    throwDamage := 5;
    dice := 1;
    adds := 2;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem(equipped: boolean; ident: smallint);
var
  info: shortstring;
begin
  info := 'You unequip the crude dagger.';
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    info := 'You equip the crude dagger.';
    if (player_inventory.inventory[ident].adds > 0) then
       info := info + ' The dagger adds 1D6+' + IntToStr(player_inventory.inventory[ident].adds) + ' to your attack'
    else
       info := info + ' The dagger adds 1D6 to your attack';
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage(info);
    ui.equippedWeapon := 'Crude dagger';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    Dec(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage(info);
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
  end;
end;

procedure throw(itemID: smallint);
begin
  entityList[0].weaponEquipped := False;
  Dec(entityList[0].weaponDice);
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
      player_inventory.inventory[itmID].description := 'adds 1D+1 to attack';
    end
    else
    begin
      player_inventory.inventory[itmID].throwDamage := 1;
      player_inventory.inventory[itmID].adds := 0;
      player_inventory.inventory[itmID].description := '[blunt] adds 1D to attack';
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
      itemList[itmID].itemDescription := 'adds 1D+1 to attack';
    end
    else
    begin
      itemList[itmID].throwDamage := 1;
      itemList[itmID].adds := 0;
      itemList[itmID].itemDescription := '[blunt] adds 1D to attack';
    end;
  end;
end;

end.
