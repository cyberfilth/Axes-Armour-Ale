(* Low quality cloth armour *)

unit cloth_armour1;

{$mode fpc}{$H+}

interface

(* Create armour *)
procedure createClothArmour(itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui, player_stats;

procedure createClothArmour(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Cloth armour';
    itemDescription := 'adds 1 to defence';
    itemArticle := 'some';
    itemType := itmArmour;
    itemMaterial := matWool;
    useID := 5;
    glyph := '[';
    glyphColour := 'magenta';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
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
    Inc(entityList[0].defence);
    Inc(player_stats.armourPoints);
    ui.displayMessage('You don the cloth armour. The armour adds 1 point to your defence');
    ui.equippedArmour:='Cloth armour';
    ui.writeBufferedMessages;
  end
  else
    (* To remove the armour *)
  begin
    entityList[0].armourEquipped := False;
    Dec(entityList[0].defence);
    Dec(player_stats.armourPoints);
    ui.displayMessage('You remove the cloth armour.');
    ui.equippedArmour:='No armour worn';
    ui.writeBufferedMessages;
  end;
end;

end.
