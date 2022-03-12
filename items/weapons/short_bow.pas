(* A short bow *)

unit short_bow;

{$mode fpc}{$H+}

interface

(* Create a bow *)
procedure createShortBow(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);
(* Remove weapon from inventory when thrown *)
procedure throw;

implementation

uses
  items, entities, ui, player_stats;

procedure createShortBow(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'short bow';
    itemDescription := 'small hunting bow';
    itemArticle := 'a';
    itemType := itmProjectileWeapon;
    itemMaterial := matWood;
    useID := 10;
    glyph := '}';
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 1;
    onMap := True;
    throwable := True;
    throwDamage := 1;
    dice := 0;
    adds := 0;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem(equipped: boolean);
begin
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    entityList[0].weaponEquipped := True;
    ui.displayMessage('You equip the short bow.');
    ui.equippedWeapon := 'Short bow';
    player_stats.projectileWeaponEquipped := True;
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    ui.displayMessage('You unequip the short bow.');
    ui.equippedWeapon := 'No weapon equipped';
    player_stats.projectileWeaponEquipped := False;
    ui.writeBufferedMessages;
  end;
end;

procedure throw;
begin
  entityList[0].weaponEquipped := False;
  ui.equippedWeapon := 'No weapon equipped';
  ui.writeBufferedMessages;
end;

end.
