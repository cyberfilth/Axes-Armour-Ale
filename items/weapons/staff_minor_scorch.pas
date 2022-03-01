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
(* Remove weapon from inventory when thrown *)
procedure throw;
(* Use the staff to zap nearby enemies *)
procedure Zap;

implementation

uses
  items, entities, ui, player_stats, player_inventory, globalUtils;

(* Description of item depends on player race *)
procedure createStaff(uniqueid, itmx, itmy: smallint);
var
  randUses: smallint;
begin
  (* Number of times the staff can be used *)
  randUses := randomRange(5, 8);
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
    NumberOfUses := randUses;
    onMap := True;
    throwable := False;
    throwDamage := 0;
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
      ui.displayMessage(
        'You equip the enchanted staff. The staff can scorch nearby enemies [z]');
      ui.equippedWeapon := 'Staff of scorch';
    end
    else
    begin
      ui.displayMessage(
        'You equip the staff. You sense it has magical powers beyond your ability');
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

procedure throw;
begin
  entityList[0].weaponEquipped := False;
  Dec(entityList[0].weaponDice);
  ui.equippedWeapon := 'No weapon equipped';
  player_stats.enchantedWeaponEquipped := False;
  player_stats.enchWeapType := 0;
end;

procedure Zap;
var
  damageChance, dmgAmount: smallint;
begin
  if (player_stats.playerRace <> 'Dwarf') then
  begin
    damageChance := 1;
    dmgAmount := 2 + player_stats.playerLevel;
    magicEffects.minorScorch;
    (* Staff integrity begins to break down *)
    Dec(player_stats.numEquippedUses);
    if (player_stats.numEquippedUses = 1) then
      ui.displayMessage('Your staff begins to splinter and spark')
    else if (player_stats.numEquippedUses <= 0) then
    begin
      { Determine if player is hurt when staff explodes }
      damageChance := randomRange(1, 5);
      if (damageChance = 3) then
      begin
        { Damage amount is 2 + players level }
        entityList[0].currentHP := (entityList[0].currentHP - dmgAmount);
        if (entities.entityList[0].currentHP < 1) then
          killer := 'an exploding magickal staff';
      end;
      { Remove the staff from inventory }
      ui.displayMessage('Magickal energy shatters your staff into splinters!');
      player_inventory.destroyWeapon;
      entityList[0].weaponEquipped := False;
      ui.equippedWeapon := 'No weapon equipped';
      ui.updateWeapon;
      player_stats.enchantedWeaponEquipped := False;
      player_stats.enchWeapType := 0;
    end;
  end;
end;

end.
