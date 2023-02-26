(* A leather bullwhip *)

unit leather_whip;

{$mode fpc}{$H+}

interface

(* Create a whip *)
procedure createWhip(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);
(* Remove weapon from inventory when thrown *)
procedure throw;

implementation

uses
  items, entities, ui, globalutils;

procedure createWhip(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Bullwhip';
    itemDescription := 'Leather whip, 1D6+9 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matLeather;
    useID := 28;
    glyph := chr(24);
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 5;
    onMap := True;
    throwable := True;
    throwDamage := 2;
    dice := 1;
    adds := 9;
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
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds,9);
    ui.displayMessage('You equip the bullwhip. The whip adds 1D6+9 to your attack');
    ui.equippedWeapon := 'Bullwhip';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    Dec(entityList[0].weaponAdds,9);
    ui.displayMessage('You unequip the bullwhip.');
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
  end;
end;

procedure throw;
begin
  entityList[0].weaponEquipped := False;
  Dec(entityList[0].weaponDice);
  ui.equippedWeapon := 'No weapon equipped';
  ui.writeBufferedMessages;
end;

end.
