(* Low quality leather armour *)

unit leather_armour1;

{$mode fpc}{$H+}

interface

(* Create armour *)
procedure createLeatherArmour(uniqueid, itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui;

procedure createLeatherArmour(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'Leather armour';
    itemDescription := 'adds 2 to defence';
    itemArticle := 'some';
    itemType := itmArmour;
    itemMaterial := matLeather;
    useID := 3;
    glyph := '(';
    glyphColour := 'lightMagenta';
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
    (* To wear the armour *)
  begin
    entityList[0].armourEquipped := True;
    Inc(entityList[0].defence, 2);
    ui.displayMessage('You don the leather armour. The armour adds 2 points to your defence');
    ui.equippedArmour:='Leather armour';
    ui.writeBufferedMessages;
  end
  else
    (* To remove the armour *)
  begin
    entityList[0].armourEquipped := False;
    Dec(entityList[0].defence, 2);
    ui.displayMessage('You remove the leather armour.');
    ui.equippedArmour:='No armour worn';
    ui.writeBufferedMessages;
  end;
end;

end.

