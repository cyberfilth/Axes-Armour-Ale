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
  items, entities, ui;

procedure createShortBow(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'short bow';
    itemDescription := 'small hunting bow';
    itemArticle := 'a';
    itemType :=
    itemMaterial := matWood;
    useID :=
    glyph := '}';
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 1;
    onMap := True;
    throwable := True;
    throwDamage := 0;
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
    Inc(entityList[0].weaponDice);
    ui.displayMessage('You equip the wooden club. The club adds 1D6 to your attack');
    ui.equippedWeapon := 'Wooden club';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    ui.displayMessage('You unequip the wooden club.');
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
