(* Cuirass made from a ribcage *)

unit lesser_bone_armour;

{$mode fpc}{$H+}

interface
(* Create armour *)
procedure createBoneArmour(itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui, player_stats;

procedure createBoneArmour(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Bone armour';
    itemDescription := 'adds 3 to defence';
    itemArticle := 'some';
    itemType := itmArmour;
    itemMaterial := matBone;
    useID := 21;
    glyph := '[';
    glyphColour := 'white';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 6;
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
    Inc(entityList[0].defence, 3);
    Inc(player_stats.armourPoints, 3);
    ui.displayMessage('You don the bone armour. The armour adds 3 points to your defence');
    ui.equippedArmour:='Bone armour';
    ui.writeBufferedMessages;
  end
  else
    (* To remove the armour *)
  begin
    entityList[0].armourEquipped := False;
    Dec(entityList[0].defence, 3);
    Dec(player_stats.armourPoints, 3);
    ui.displayMessage('You remove the bone armour.');
    ui.equippedArmour:='No armour worn';
    ui.writeBufferedMessages;
  end;
end;

end.
