(* A magical staff of minor scorch, area effect *)

unit staff_minor_scorch;

{$mode fpc}{$H+}

interface

uses
  magicEffects;

(* Create a staff *)
procedure createStaff(uniqueid, itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem(equipped: boolean);
(* Use the staff to zap nearby enemies *)
procedure Zap;

implementation

uses
  items, entities, ui, player_stats;

(* Description of item depends on player race *)
procedure createStaff(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    if (player_stats.playerRace <> 'Dwarf') then
    begin
      itemName := 'Staff of minor scorch';
      itemDescription := '+1D6 to attack, scorches nearby enemies';
    end
    else
    begin
      itemName := 'Wooden staff';
      itemDescription := 'adds 1D6 to attack';
    end;
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matWood;
    useID := 8;
    glyph := chr(186);
    glyphColour := 'red';
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
    if (player_stats.playerRace <> 'Dwarf') then
    begin
      ui.displayMessage('You equip the enchanted staff. The staff can scorch nearby enemies [z]');
      ui.equippedWeapon := 'Staff of scorch';
    end
    else
    begin
      ui.displayMessage('You equip the staff. You sense it has magical powers beyond your ability');
      ui.equippedWeapon := 'Wooden staff';
    end;
    ui.writeBufferedMessages;
    player_stats.enchantedWeaponEquipped := True;
    player_stats.enchWeapType := 8;
  end
  else
    (* To unequip the weapon *)
  begin
    entityList[0].weaponEquipped := False;
    Dec(entityList[0].weaponDice);
    if (player_stats.playerRace <> 'Dwarf') then
      ui.displayMessage('You unequip the enchanted staff.')
    else
      ui.displayMessage('You unequip the staff.');
    ui.equippedWeapon := 'No weapon equipped';
    ui.writeBufferedMessages;
    player_stats.enchantedWeaponEquipped := False;
    player_stats.enchWeapType := 0;
  end;
end;

procedure Zap;
begin
  (* Check mana amount *)

  magicEffects.minorScorch;
end;

end.
