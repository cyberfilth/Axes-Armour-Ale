(* Handles player inventory and associated functions *)

unit player_inventory;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, StrUtils, video, items, item_lookup, player_stats, staff_minor_scorch,
  pixie_jar, gold_pieces, staff_bewilder, vampiric_staff;

type
  (* Items in inventory *)
  Equipment = record
    id, useID, sortIndex, numUses, buy, sell, throwDamage, dice, adds: smallint;
    Name, description, article, glyph, glyphColour: shortstring;
    itemType: tItem;
    itemMaterial: tMaterial;
    throwable: boolean;
    (* Is the item still in the inventory *)
    inInventory: boolean;
    (* Is the item being worn or wielded *)
    equipped: boolean;
  end;

var
  inventory: array[0..9] of Equipment;

(* Initialise empty player inventory *)
procedure initialiseInventory;
(* Setup equipped items when loading a saved game *)
procedure loadEquippedItems;
(* Add items to an inventory when new game starts *)
procedure startingInventory;
(* Add to inventory *)
function addToInventory(itemNumber: smallint): boolean;
(* Add to an empty slot in inventory *)
function addToInventory_emptySlot(itemNumber: smallint; skip: boolean): boolean;
(* Remove from inventory *)
function removeFromInventory(itemNumber: smallint): boolean;
(* Sort inventory *)
procedure sortInventory(iLo, iHi: integer);
(* Display the inventory screen *)
procedure showInventory;
(* Display more information about an item *)
procedure examineInventory(selection: smallint);
(* Drop menu *)
procedure drop;
(* Drop selected item *)
procedure dropSelection(selection: smallint);
(* Quaff menu *)
procedure quaff;
(* Quaff selected item *)
procedure quaffSelection(selection: smallint);
(* Wear / Wield menu *)
procedure wield(message: char);
(* Wear / Wield selected item *)
procedure wearWieldSelection(selection: smallint);
(* Zap equipped item *)
procedure Zzap(item: smallint);
(* Check if arrows are in inventory *)
function carryingArrows: boolean;
(* Remove an arrow from inventory *)
procedure removeArrow;
(* Equipped weapon is destroyed *)
procedure destroyWeapon;

implementation

uses
  scrInventory, ui, entities;

procedure initialiseInventory;

var
  i: byte;
begin
  for i := 0 to 9 do
  begin
    inventory[i].id := i;
    inventory[i].sortIndex := 10;
    inventory[i].Name := 'Empty';
    inventory[i].equipped := False;
    inventory[i].description := 'x';
    inventory[i].article := 'x';
    inventory[i].itemType := itmEmptySlot;
    inventory[i].itemMaterial := matEmpty;
    inventory[i].glyph := 'x';
    inventory[i].glyphColour := 'x';
    inventory[i].numUses := 0;
    inventory[i].buy := 0;
    inventory[i].sell := 0;
    inventory[i].inInventory := False;
    inventory[i].throwable := False;
    inventory[i].throwDamage := 0;
    inventory[i].dice := 0;
    inventory[i].adds := 0;
    inventory[i].useID := 0;
  end;
end;

procedure loadEquippedItems;
var
  i: smallint;
begin
  for i := 0 to 9 do
  begin
    if (inventory[i].equipped = True) then
    begin
      (* Check for weapons *)
      if (inventory[i].itemType = itmWeapon) or (inventory[i].itemType = itmProjectileWeapon) then
      begin
        ui.equippedWeapon := inventory[i].Name;
        ui.updateWeapon;
      end
      (* Check for armour *)
      else if (inventory[i].itemType = itmArmour) then
      begin
        ui.equippedArmour := inventory[i].Name;
        ui.updateArmour;
      end;
    end;
  end;
end;

procedure startingInventory;
begin
  (* Humans start off with a pointy stick *)
  if (player_stats.playerRace = 'Human') then
  begin
    with inventory[0] do
    begin
      id := 0;
      sortIndex := 1;
      Name := 'pointy stick';
      equipped := True;
      description := 'adds 1D6+1 to attack';
      article := 'a';
      itemType := itmWeapon;
      itemMaterial := matWood;
      glyph := chr(173);
      glyphColour := 'brown';
      numUses := 5;
      buy := 0;
      sell := 0;
      inInventory := True;
      throwable := True;
      throwDamage := 4;
      dice := 1;
      adds := 1;
      useID := 11;
    end;
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    Inc(entityList[0].weaponAdds);
    ui.equippedWeapon := 'Pointy stick';
    end
    (* Dwarves start off with a basic club *)
    else if (player_stats.playerRace = 'Dwarf') then
    begin
    with inventory[0] do
    begin
      id := 0;
      sortIndex := 1;
      Name := 'wooden club';
      equipped := True;
      description := 'adds 1D6 to attack';
      article := 'a';
      itemType := itmWeapon;
      itemMaterial := matWood;
      glyph := chr(24);
      glyphColour := 'brown';
      numUses := 5;
      buy := 0;
      sell := 0;
      inInventory := True;
      throwable := True;
      throwDamage := 4;
      dice := 1;
      adds := 0;
      useID := 4;
    end;
    entityList[0].weaponEquipped := True;
    Inc(entityList[0].weaponDice);
    ui.equippedWeapon := 'Wooden club';
  end
  (* Elves start off with a short bow and some arrows *)
  else
  begin
    with inventory[0] do
    begin
      id := 0;
      sortIndex := 1;
      Name := 'short bow';
      equipped := True;
      description := 'small hunting bow';
      article := 'a';
      itemType := itmProjectileWeapon;
      itemMaterial := matWood;
      glyph := '}';
      glyphColour := 'brown';
      numUses := 1;
      buy := 0;
      sell := 0;
      inInventory := True;
      throwable := True;
      throwDamage := 1;
      dice := 0;
      adds := 0;
      useID := 10;
    end;
    entityList[0].weaponEquipped := True;
    player_stats.projectileWeaponEquipped := True;
    ui.equippedWeapon := 'Short bow';
    with inventory[1] do
    begin
      id := 1;
      sortIndex := 6;
      Name := 'arrow';
      equipped := False;
      description := 'wooden flight arrow';
      article := 'an';
      itemType := itmAmmo;
      itemMaterial := matWood;
      glyph := '|';
      glyphColour := 'brown';
      numUses := 5;
      buy := 0;
      sell := 0;
      inInventory := True;
      throwable := False;
      throwDamage := 5;
      dice := 0;
      adds := 0;
      useID := 12;
    end;
  end;
end;

(* Returns TRUE if successfully added, FALSE if the inventory is full *)
function addToInventory(itemNumber: smallint): boolean;
var
  i: smallint;
  stacked, skip: boolean;
begin
  Result := False;
  { Are items stacked }
  stacked := False;
  { Don't add to a new slot if item is stacked }
  skip := False;
  (* Player cannot pick up traps *)
  if (itemList[itemNumber].itemType <> itmTrap) then
  begin
  (* If this is not a quest item *)
  if (itemList[itemNumber].itemType <> itmQuest) and (itemList[itemNumber].itemType <> itmLightSource) and (itemList[itemNumber].itemType <> itmTreasure) then
  begin
    Result := False;
    (* Check for adding an arrow to existing arrow slot *)
    if (itemList[itemNumber].itemName = 'arrow') then
    begin
      for i := 0 to 9 do
      begin
           if (inventory[i].Name = 'arrow') then
           begin
             Inc(inventory[i].numUses, itemList[itemNumber].NumberOfUses);
             stacked := True;
             skip := True;
             if (itemList[itemNumber].NumberOfUses > 1) then
                ui.displayMessage('You pick up the ' + inventory[i].Name + 's')
             else
                ui.displayMessage('You pick up the ' + inventory[i].Name);
           end;
      end;
    end;
    (* Check for an empty inventory slot *)
    if (addToInventory_emptySlot(itemNumber, skip) = True) or (stacked = True) then
    begin
    (* Set an empty flag for the item on the map, this gets deleted when saving the map *)
        with itemList[itemNumber] do
        {$I emptyslot }
        (* Sort items in inventory *)
        sortInventory(0, high(inventory));
        Result := True;
        exit;
      end;
  end
  else if (itemList[itemNumber].itemType = itmLightSource) then
  begin { Pixie in a Jar }
    Inc(player_stats.lightCounter, itemList[itemNumber].NumberOfUses);
    (* Set an empty flag for the item on the map, this gets deleted when saving the map *)
    with itemList[itemNumber] do
    {$I emptyslot }
    Result := True;
    pixie_jar.useItem;
  end
  else if (itemList[itemNumber].itemType = itmTreasure) then
  begin { Treasure }
        Inc(player_stats.treasure, itemList[itemNumber].NumberOfUses);
    (* Set an empty flag for the item on the map, this gets deleted when saving the map *)
    with itemList[itemNumber] do
    {$I emptyslot }
    Result := True;
    gold_pieces.useItem;
  end
  else  { Quest item }
  begin
    item_lookup.lookupUse(itemList[itemNumber].useID, False, 0);
(* Set an empty flag for the item on the map, this gets deleted when saving the map *)
    with itemList[itemNumber] do
    {$I emptyslot }
    Result := True;
  end;
  end;
end;

function addToInventory_emptySlot(itemNumber: smallint; skip: boolean):boolean;
var i: smallint;
begin
  Result := False;
  if (skip = False) then
  begin
  for i := 0 to 9 do
    begin
      if (inventory[i].Name = 'Empty') then
      begin
        itemList[itemNumber].onMap := False;
        (* Populate inventory with item description *)
        inventory[i].id := i;
        (* Set sortIndex for sorting inventory *)
        if (itemList[itemNumber].itemType = itmWeapon) then
          inventory[i].sortIndex := 1
        else if (itemList[itemNumber].itemType = itmProjectileWeapon) then
          inventory[i].sortIndex := 2
        else if (itemList[itemNumber].itemType = itmArmour) then
          inventory[i].sortIndex := 3
        else if (itemList[itemNumber].itemType = itmDrink) then
          inventory[i].sortIndex := 4
        else if (itemList[itemNumber].itemType = itmProjectile) then
          inventory[i].sortIndex := 5
        else if (itemList[itemNumber].itemType = itmAmmo) then
          inventory[i].sortIndex := 6;
        inventory[i].Name := itemList[itemNumber].itemname;
        inventory[i].description := itemList[itemNumber].itemDescription;
        inventory[i].article := itemList[itemNumber].itemArticle;
        inventory[i].itemType := itemList[itemNumber].itemType;
        inventory[i].itemMaterial := itemList[itemNumber].itemMaterial;
        inventory[i].useID := itemList[itemNumber].useID;
        inventory[i].glyph := itemList[itemNumber].glyph;
        inventory[i].glyphColour := itemList[itemNumber].glyphColour;
        inventory[i].numUses := itemList[itemNumber].NumberOfUses;
        inventory[i].buy := itemList[itemNumber].buy;
        inventory[i].sell := itemList[itemNumber].sell;
        inventory[i].throwable := itemList[itemNumber].throwable;
        inventory[i].throwDamage := itemList[itemNumber].throwDamage;
        inventory[i].dice := itemList[itemNumber].dice;
        inventory[i].adds := itemList[itemNumber].adds;
        inventory[i].inInventory := True;
        if (itemList[itemNumber].itemName = 'arrow') and (itemList[itemNumber].NumberOfUses > 1) then
           ui.displayMessage('You pick up the ' + inventory[i].Name + 's')
        else
            ui.displayMessage('You pick up the ' + inventory[i].Name);
        Result := True;
        exit;
      end;
    end;
  end;
end;

function removeFromInventory(itemNumber: smallint): boolean;
var
  newItem: item;
  ss: shortstring;
begin
  Result := False;
  (* Check if there is already an item on the floor here *)
  if (items.containsItem(entityList[0].posX, entityList[0].posY) = False) then
    { Create an item }
  begin
    newItem.itemID := indexID;
    newItem.itemName := inventory[itemNumber].Name;
    newItem.itemDescription := inventory[itemNumber].description;
    newItem.itemArticle := inventory[itemNumber].article;
    newItem.itemType := inventory[itemNumber].itemType;
    newItem.itemMaterial := inventory[itemNumber].itemMaterial;
    newItem.useID := inventory[itemNumber].useID;
    newItem.glyph := inventory[itemNumber].glyph;
    newItem.glyphColour := inventory[itemNumber].glyphColour;
    newItem.inView := True;
    newItem.posX := entities.entityList[0].posX;
    newItem.posY := entities.entityList[0].posY;
    newItem.NumberOfUses := inventory[itemNumber].numUses;
    newItem.buy := inventory[itemNumber].buy;
    newItem.sell := inventory[itemNumber].sell;
    newItem.onMap := True;
    newItem.throwable := inventory[itemNumber].throwable;
    newItem.throwDamage := inventory[itemNumber].throwDamage;
    newItem.dice := inventory[itemNumber].dice;
    newItem.adds := inventory[itemNumber].adds;
    newItem.discovered := True;
    Inc(indexID);

    { Place item on the game map }
    SetLength(itemList, Length(itemList) + 1);
    Insert(newitem, itemList, Length(itemList));
    WriteStr(ss, 'You drop the ', newItem.itemName);
    ui.bufferMessage(ss);

    (* Remove from inventory *)
    inventory[itemNumber].sortIndex := 10;
    inventory[itemNumber].Name := 'Empty';
    inventory[itemNumber].equipped := False;
    inventory[itemNumber].description := 'x';
    inventory[itemNumber].article := 'x';
    inventory[itemNumber].itemType := itmEmptySlot;
    inventory[itemNumber].itemMaterial := matEmpty;
    inventory[itemNumber].glyph := 'x';
    inventory[itemNumber].glyphColour := 'x';
    inventory[itemNumber].inInventory := False;
    inventory[itemNumber].numUses := 0;
    inventory[itemNumber].buy := 0;
    inventory[itemNumber].sell := 0;
    inventory[itemNumber].throwable := False;
    inventory[itemNumber].throwDamage := 0;
    inventory[itemNumber].dice := 0;
    inventory[itemNumber].adds := 0;
    inventory[itemNumber].useID := 0;
    (* Sort items in inventory *)
    sortInventory(0, high(inventory));
    Result := True;
    (* Redraw the Drop menu *)
    drop;
  end
  else
  begin
    { prepare changes to the screen }
    LockScreenUpdate;
    (* Clear the message line *)
    TextOut(6, 20, 'black', '                                                  ');
    { Display message }
    TextOut(6, 20, 'cyan', 'There is no room to drop this item here');
    { Write those changes to the screen }
    UnlockScreenUpdate;
    { only redraws the parts that have been updated }
    UpdateScreen(False);
  end;
end;

procedure sortInventory(iLo, iHi: integer);
var
  t: Equipment;
  lo, hi, mid: integer;
begin
  lo := iLo;
  hi := iHi;
  mid := inventory[(lo + hi) shr 1].sortIndex;
  repeat
    while inventory[lo].sortIndex < mid do
      Inc(lo);
    while inventory[hi].sortIndex > mid do
      Dec(hi);
    if lo <= hi then
    begin
      t := inventory[lo];
      inventory[lo] := inventory[hi];
      inventory[hi] := t;
      Inc(lo);
      Dec(hi);
    end;
  until lo > hi;
  if hi > iLo then
    sortInventory(iLo, hi);
  if lo < iHi then
    sortInventory(lo, iHi);
end;

procedure showInventory;
begin
  { prepare changes to the screen }
  LockScreenUpdate;
  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrInventory.displayInventoryScreen;
  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure examineInventory(selection: smallint);
var
  material: shortstring;
begin
  (* Check that the slot is not empty *)
  if (inventory[selection].inInventory = True) then
  begin
    (* Get the item material *)
    material := '';
    if (inventory[selection].itemType <> itmDrink) then
    begin
      if (inventory[selection].itemMaterial = matIron) then
        material := ' [iron]';
      if (inventory[selection].itemMaterial = matSteel) then
        material := ' [steel]';
      if (inventory[selection].itemMaterial = matWood) then
        material := ' [wooden]';
      if (inventory[selection].itemMaterial = matLeather) then
        material := ' [leather]';
    end;
    { prepare changes to the screen }
    LockScreenUpdate;
    (* Clear the name & description lines *)
    TextOut(6, 20, 'black',
      '                                                                 ');
    TextOut(6, 21, 'black',
      '                                                                 ');
    { glyph }
    TextOut(6, 20, inventory[selection].glyphColour, inventory[selection].glyph);
    { name }
    TextOut(8, 20, 'lightCyan', AnsiProperCase(inventory[selection].Name, StdWordDelims) + material);
    { description }
    TextOut(7, 21, 'cyan', chr(16) + ' ' + inventory[selection].description);
    { Write those changes to the screen }
    UnlockScreenUpdate;
    { only redraws the parts that have been updated }
    UpdateScreen(False);
  end;
end;

procedure drop;
begin
  (* Sort items in inventory *)
  sortInventory(0, high(inventory));
  { prepare changes to the screen }
  LockScreenUpdate;
  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrInventory.displayDropMenu;
  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure dropSelection(selection: smallint);
begin
  (* Cannot drop an equipped item *)
  if (inventory[selection].equipped = True) then
  begin
    LockScreenUpdate;
    TextOut(6, 20, 'cyan', 'You must unequip an item before dropping it');
    UnlockScreenUpdate;
    UpdateScreen(False);
  end
  (* Check that the slot is not empty *)
  else if (inventory[selection].inInventory = True) and (inventory[selection].equipped = False) then
    removeFromInventory(selection);
end;

procedure quaff;
begin
  { prepare changes to the screen }
  LockScreenUpdate;
  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrInventory.displayQuaffMenu;
  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure quaffSelection(selection: smallint);
begin
  (* Check that the slot is not empty *)
  if (inventory[selection].inInventory = True) and
    (inventory[selection].itemType = itmDrink) then
  begin
    item_lookup.lookupUse(inventory[selection].useID, False, 0);
    (* Increase turn counter for this action *)
    Inc(entityList[0].moveCount);
    (* Remove from inventory *)
    inventory[selection].Name := 'Empty';
    inventory[selection].equipped := False;
    inventory[selection].description := 'x';
    inventory[selection].article := 'x';
    inventory[selection].itemType := itmEmptySlot;
    inventory[selection].itemMaterial := matEmpty;
    inventory[selection].glyph := 'x';
    inventory[selection].glyphColour := 'x';
    inventory[selection].inInventory := False;
    inventory[selection].numUses := 0;
    inventory[selection].buy := 0;
    inventory[selection].sell := 0;
    inventory[selection].throwable := False;
    inventory[selection].throwDamage := 0;
    inventory[selection].dice := 0;
    inventory[selection].adds := 0;
    inventory[selection].useID := 0;
    (* Sort items in inventory *)
    sortInventory(0, high(inventory));
    (* Redraw the Quaff menu *)
    quaff;
  end;
end;

procedure wield(message: char);
begin
  { prepare changes to the screen }
  LockScreenUpdate;
  (* Clear the screen *)
  ui.screenBlank;
  (* Draw the game screen *)
  scrInventory.displayWieldMenu;
  (* Check if there is a message to show *)
  if (message = 'w') then
    TextOut(6, 20, 'cyan', 'You must first unequip the weapon you already hold')
  else if (message = 'a') then
    TextOut(6, 20, 'cyan', 'You must first remove the armour you already wear')
  else if (message = 'i') then
    TextOut(6, 20, 'cyan', 'You are unable to use iron items');
  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure wearWieldSelection(selection: smallint);
var
  { Flag to display message if unable to equip item }
  msg: char;
begin
  (* Set default flag *)
  msg := 'n';

  (* Check that the slot is not empty *)
  if (inventory[selection].inInventory = True) then
  begin
    (* Check that the selected item is armour or a weapon *)
    if (inventory[selection].itemType = itmWeapon) or (inventory[selection].itemType = itmProjectileWeapon) or (inventory[selection].itemType = itmArmour) then
    begin

      (* Check if an elf is trying to use an iron item *)
      if (inventory[selection].itemMaterial = matIron) and
        (player_stats.playerRace = 'Elf') then
      begin
        wield('i');
        exit;
      end;

    (* If the item is an unequipped weapon, and the player already has a weapon
    equipped prompt the player to unequip their weapon first *)
      if (inventory[selection].equipped = False) and
        (inventory[selection].itemType = itmWeapon) and
        (entityList[0].weaponEquipped = True) then
        msg := 'w'

    (* If the item is an unequipped projectie weapon, and the player already has
    a weapon equipped prompt the player to unequip their weapon first *)
      else if (inventory[selection].equipped = False) and
        (inventory[selection].itemType = itmProjectileWeapon) and
        (entityList[0].weaponEquipped = True) then
        msg := 'w'

    (* If the item is unworn armour, and the player is already wearing armour
         prompt the player to unequip their armour first *)
      else if (inventory[selection].equipped = False) and
        (inventory[selection].itemType = itmArmour) and
        (entityList[0].armourEquipped = True) then
        msg := 'a'

      (* Check whether the item is already equipped or not *)
      else if (inventory[selection].equipped = False) then
      begin
        (* Equip *)
        inventory[selection].equipped := True;
        item_lookup.lookupUse(inventory[selection].useID, False, selection);
        player_stats.numEquippedUses := inventory[selection].numUses;
      end
      else
      begin
        (* Unequip *)
        inventory[selection].equipped := False;
        item_lookup.lookupUse(inventory[selection].useID, True, selection);
        inventory[selection].numUses := player_stats.numEquippedUses;
      end;
      { Increment turn counter }
      Inc(entityList[0].moveCount);
      wield(msg);
    end;
  end;
end;

procedure Zzap(item: smallint);
begin
  case item of
    8: { Staff of Minor Scorch }
      staff_minor_scorch.Zap;
    23: { Staff of Flummox }
        staff_bewilder.Zap;
    25: { Vampiric staff }
        vampiric_staff.Zap
    else { No enchanted weapon equipped }
      ui.displayMessage('You have no magical weapon equipped');
  end;
end;

function carryingArrows: boolean;
var i: byte;
begin
  i := 0;
  Result := False;
  for i := 0 to 9 do
    begin
      if (inventory[i].itemType = itmAmmo) then
         Result := True;
    end;
end;

procedure removeArrow;
var i: byte;
begin
   i := 0;
   for i := 0 to 9 do
    begin
      if (inventory[i].itemType = itmAmmo) then
      begin
      (* If it's the last arrow, remove from inventory *)
      if (inventory[i].numUses = 1) then
      begin
         (* Remove from inventory *)
         inventory[i].Name := 'Empty';
         inventory[i].equipped := False;
         inventory[i].description := 'x';
         inventory[i].article := 'x';
         inventory[i].itemType := itmEmptySlot;
         inventory[i].itemMaterial := matEmpty;
         inventory[i].glyph := 'x';
         inventory[i].glyphColour := 'x';
         inventory[i].inInventory := False;
         inventory[i].numUses := 0;
         inventory[i].buy := 0;
         inventory[i].sell := 0;
         inventory[i].throwable := False;
         inventory[i].throwDamage := 0;
         inventory[i].dice := 0;
         inventory[i].adds := 0;
         inventory[i].useID := 0;
      end
      (* If it's not the last arrow, decrement the number of arrows *)
      else
          Dec(inventory[i].numUses);
    end;
   end;
end;

procedure destroyWeapon;
var
  i: smallint;
begin
  for i := 0 to 9 do
  begin
    (* Find the equipped weapon *)
    if (inventory[i].equipped = True) and (inventory[i].itemType = itmWeapon) then
    begin
      (* Remove weapon from inventory *)
      inventory[i].sortIndex := 10;
      inventory[i].Name := 'Empty';
      inventory[i].equipped := False;
      inventory[i].description := 'x';
      inventory[i].article := 'x';
      inventory[i].itemType := itmEmptySlot;
      inventory[i].itemMaterial := matEmpty;
      inventory[i].glyph := 'x';
      inventory[i].glyphColour := 'x';
      inventory[i].inInventory := False;
      inventory[i].numUses := 0;
      inventory[i].buy := 0;
      inventory[i].sell := 0;
      inventory[i].throwable := False;
      inventory[i].throwDamage := 0;
      inventory[i].dice := 0;
      inventory[i].adds := 0;
      inventory[i].useID := 0;
    end;
  end;
end;

end.
