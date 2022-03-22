(* A pointy stick *)

unit pointy_stick;

{$mode fpc}{$H+}

interface

(* Create a pointy stick *)
procedure createPointyStick(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);
(* Remove weapon from inventory when thrown *)
procedure throw;

implementation

uses
  items, entities, ui;

procedure createPointyStick(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'pointy stick';
    itemDescription := 'adds 1D6+1 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matWood;
    useID := 11;
    glyph := chr(173);
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    onMap := True;
    throwable := True;
    throwDamage := 4;
    dice := 1;
    adds := 1;
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
    Inc(entityList[0].weaponAdds);
    ui.displayMessage('You equip the pointy stick. The stick adds 1D6+1 to your attack');
    ui.equippedWeapon := 'Pointy stick';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    Dec(entityList[0].weaponAdds);
    ui.displayMessage('You unequip the pointy stick.');
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
  end;
end;

procedure throw;
begin
  entityList[0].weaponEquipped := False;
  Dec(entityList[0].weaponDice);
  Dec(entityList[0].weaponAdds);
  ui.equippedWeapon := 'No weapon equipped';
  ui.writeBufferedMessages;
end;

end.
