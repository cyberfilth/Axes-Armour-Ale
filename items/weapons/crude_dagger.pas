(* A crude, iron dagger *)

unit crude_dagger;

{$mode fpc}{$H+}

interface

uses
  SysUtils, logging;

(* Create a dagger *)
procedure createDagger(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean; ident: smallint);
(* Remove weapon from inventory when thrown *)
procedure throw;
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
    itemDescription := 'adds 1D+2 to attack';
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
begin
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage('You equip the crude dagger.');
    ui.equippedWeapon := 'Crude dagger';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    Dec(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage('You unequip the crude dagger.');
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
  end;
end;

procedure throw;
begin
  entityList[0].weaponEquipped := False;
  Dec(entityList[0].weaponDice);
  Dec(entityList[0].weaponAdds, 2);
  ui.equippedWeapon := 'No weapon equipped';
end;

procedure thrownDamaged(itmID: smallint; inventory: boolean);
begin
  logAction('thrownDamaged');
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
    logAction('Not in inventory');
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
