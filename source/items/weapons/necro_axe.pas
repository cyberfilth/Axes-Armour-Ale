(* Necrotic axe *)

unit necro_axe;

{$mode fpc}{$H+}
{$WARN 5024 off : Parameter "$1" not used}
interface

uses
  SysUtils;

(* Create an axe *)
procedure createNecroAxe(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean; ident: smallint);
(* Remove weapon from inventory when thrown *)
procedure throw(itemID: smallint);
(* Check if weapon is damaged when thrown *)
procedure thrownDamaged(itmID: smallint; inventory: boolean);

implementation

uses
  items, entities, ui, player_inventory;

procedure createNecroAxe(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Necro axe';
    itemDescription := 'adds 2D6+1 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matSteel;
    useID := 24;
    glyph := chr(194);
    glyphColour := 'lightMagenta';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 10;
    value := 4;
    onMap := True;
    throwable := True;
    throwDamage := 7;
    dice := 2;
    adds := 1;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem(equipped: boolean; ident: smallint);
var
  info: shortstring;
begin
  info := 'You unequip the Necro axe.';
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    info := 'You equip the Necro axe.';
    if (player_inventory.inventory[ident].adds > 0) then
       info := info + ' The axe adds 2D6+' + IntToStr(player_inventory.inventory[ident].adds) + ' to your attack'
    else
       info := info + ' The axe adds 2D6 to your attack';
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds, player_inventory.inventory[ident].adds);
    ui.displayMessage(info);
    ui.equippedWeapon := 'Necro axe';
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
  Dec(entityList[0].weaponDice, 2);
  ui.equippedWeapon := 'No weapon equipped';
end;

procedure thrownDamaged(itmID: smallint; inventory: boolean);
begin
  if (inventory = True) then
    player_inventory.inventory[itmID].throwDamage := 6;
end;

end.
