(* Low quality leather armour *)

unit leather_armour1;

{$mode fpc}{$H+}

interface

(* Create armour *)
procedure createLeatherArmour(itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui, player_stats;

procedure createLeatherArmour(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Leather armour';
    itemDescription := 'adds 2 to defence';
    itemArticle := 'some';
    itemType := itmArmour;
    itemMaterial := matLeather;
    useID := 3;
    glyph := '[';
    glyphColour := 'lightMagenta';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 5;
    onMap := True;
    throwable := False;
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
    (* To wear the armour *)
  begin
    entityList[0].armourEquipped := True;
    Inc(entityList[0].defence, 2);
    Inc(player_stats.armourPoints, 2);
    ui.displayMessage('You don the leather armour. The armour adds 2 points to your defence');
    ui.equippedArmour:='Leather armour';
    ui.writeBufferedMessages;
  end
  else
    (* To remove the armour *)
  begin
    entityList[0].armourEquipped := False;
    Dec(entityList[0].defence, 2);
    Dec(player_stats.armourPoints, 2);
    ui.displayMessage('You remove the leather armour.');
    ui.equippedArmour:='No armour worn';
    ui.writeBufferedMessages;
  end;
end;

end.

