(* A wooden club *)

unit basic_club;

{$mode fpc}{$H+}

interface

(* Create a club *)
procedure createClub(uniqueid, itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui;

procedure createClub(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'wooden club';
    itemDescription := 'adds 1D6 to attack';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matWood;
    useID := 4;
    glyph := chr(24);
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    onMap := True;
    discovered := False;
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

end.

