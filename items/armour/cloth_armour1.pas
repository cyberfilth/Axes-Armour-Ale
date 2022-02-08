(* Low quality cloth armour *)

unit cloth_armour1;

{$mode fpc}{$H+}

interface

(* Create armour *)
procedure createClothArmour(uniqueid, itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui;

procedure createClothArmour(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'Cloth armour';
    itemDescription := 'adds 1 to defence';
    itemArticle := 'some';
    itemType := itmArmour;
    itemMaterial := matWool;
    useID := 5;
    glyph := '(';
    glyphColour := 'magenta';
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
    Inc(entityList[0].defence);
    ui.displayMessage('You don the cloth armour. The armour adds 1 point to your defence');
    ui.equippedArmour:='Cloth armour';
    ui.writeBufferedMessages;
  end
  else
    (* To remove the armour *)
  begin
    entityList[0].armourEquipped := False;
    Dec(entityList[0].defence);
    ui.displayMessage('You remove the cloth armour.');
    ui.equippedArmour:='No armour worn';
    ui.writeBufferedMessages;
  end;
end;

end.
