(* An iron dagger of Gnomish design *)

unit gnomish_dagger;

{$mode fpc}{$H+}

interface

uses
  SysUtils;

(* Create a dagger *)
procedure createGnomishDagger(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean; ident: smallint);
(* Remove weapon from inventory when thrown *)
procedure throw(itemID: smallint);
(* Check if weapon is damaged when thrown *)
procedure thrownDamaged(itmID: smallint; inventory: boolean);

implementation

uses
  items, entities, ui, player_inventory;

procedure createGnomishDagger(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Gnomish dagger';
    itemDescription := 'adds 1D6+6 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matIron;
    useID := 14;
    glyph := chr(24);
    glyphColour := 'lightMagenta';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 6;
    value := 4;
    onMap := True;
    throwable := True;
    throwDamage := 7;
    dice := 1;
    adds := 6;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem(equipped: boolean; ident: smallint);
var
  info: shortstring;
begin
  info := 'You unequip the Gnomish dagger.';
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    info := 'You equip the Gnomish dagger.';
    if (player_inventory.inventory[ident].adds > 0) then
       info := info + ' The dagger adds 1D6+' + IntToStr(player_inventory.inventory[ident].adds) + ' to your attack'
    else
       info := info + ' The dagger adds 1D6 to your attack';
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage(info);
    ui.equippedWeapon := 'Gnomish dagger';
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
    if (player_inventory.inventory[itmID].numUses = 6) then
    begin
      player_inventory.inventory[itmID].numUses := 5;
      player_inventory.inventory[itmID].throwDamage := 6;
    end
    else if (player_inventory.inventory[itmID].numUses = 5) then
    begin
      player_inventory.inventory[itmID].numUses := 4;
      player_inventory.inventory[itmID].throwDamage := 5;
    end
    else if (player_inventory.inventory[itmID].numUses = 4) then
      player_inventory.inventory[itmID].numUses := 3;
      player_inventory.inventory[itmID].throwDamage := 4;
    end
    else if (player_inventory.inventory[itmID].numUses = 3) then
    begin
      player_inventory.inventory[itmID].numUses := 2;
      player_inventory.inventory[itmID].throwDamage := 3;
      player_inventory.inventory[itmID].adds := 1;
      player_inventory.inventory[itmID].description := 'adds 1D+1 to attack';
    end
    else
    begin
      player_inventory.inventory[itmID].throwDamage := 1;
      player_inventory.inventory[itmID].adds := 0;
      player_inventory.inventory[itmID].description := '[blunt] adds 1D to attack';
    end;
end;

end.
