(* A crude, iron dagger *)

unit crude_dagger;

{$mode fpc}{$H+}

interface

(* Create a dagger *)
procedure createDagger(uniqueid, itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui;

procedure createDagger(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
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
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem(equipped: boolean);
begin
  { TODO : Add Throw Range and Throw Damage }
  if (equipped = False) then
    (* To equip the weapon *)
  begin
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds, 2);
    ui.displayMessage('You equip the crude dagger. The dagger adds 1D6+2 to your attack');
    ui.equippedWeapon := 'Crude dagger';
    ui.writeBufferedMessages;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    Dec(entityList[0].weaponAdds, 2);
    ui.displayMessage('You unequip the crude dagger.');
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
  end;
end;

end.
