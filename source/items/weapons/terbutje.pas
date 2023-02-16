(* A wooden club studded with spikes made of obsidian*)

unit terbutje;

{$mode fpc}{$H+}

interface

(* Create a terbutje *)
procedure createTerbutje(itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);
(* Remove weapon from inventory when thrown *)
procedure throw;

implementation

uses
  items, entities, ui;

procedure createTerbutje(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Terbutje';
    itemDescription := 'Club covered in obsidian spikes, 1D6+9 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matWood;
    useID := 27;
    glyph := chr(24);
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 5;
    onMap := True;
    throwable := True;
    throwDamage := 8;
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
    ui.displayMessage('You equip the terbutje. The terbutje adds 1D6+9 to your attack');
    ui.equippedWeapon := 'Terbutje';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    Dec(entityList[0].weaponAdds,9);
    ui.displayMessage('You unequip the terbutje.');
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