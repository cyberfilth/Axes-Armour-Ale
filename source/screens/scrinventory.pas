(* Inventory screen *)

unit scrInventory;

{$mode fpc}{$H+}

interface

uses
  SysUtils, entities, player_stats, globalUtils;

(* Draw the outline of the screen *)
procedure drawOutline;
(* Show the main inventory screen *)
procedure displayInventoryScreen;
(* Show the drop menu *)
procedure displayDropMenu;
(* Show the quaff menu *)
procedure displayQuaffMenu;
(* Show the wear / wield menu *)
procedure displayWieldMenu;

implementation

uses
  ui, player_inventory, items;

procedure drawOutline;
begin
  { Header }
  TextOut(10, 2, 'cyan', chr(218));
  for x := 11 to 69 do
    TextOut(x, 2, 'cyan', chr(196));
  TextOut(70, 2, 'cyan', chr(191));
  TextOut(10, 3, 'cyan', chr(180));
  TextOut(70, 3, 'cyan', chr(195));
  TextOut(10, 4, 'cyan', chr(192));
  for x := 11 to 69 do
    TextOut(x, 4, 'cyan', chr(196));
  TextOut(70, 4, 'cyan', chr(217));
end;

procedure displayInventoryScreen;
var
  y, invItem: byte;
  letter: char;
begin
  invItem := 0;
  { draw outline }
  drawOutline;
  { Inventory title }
  TextOut(15, 3, 'cyan', 'Inventory ' + chr(240) + ' [a - j] select item to examine');

  { Footer menu }
  TextOut(6, 23, 'cyanBGblackTXT', ' D - Drop item ');
  TextOut(23, 23, 'cyanBGblackTXT', ' Q - Quaff/drink ');
  TextOut(42, 23, 'cyanBGblackTXT', ' W - Weapons/Armour ');
  TextOut(64, 23, 'cyanBGblackTXT', ' X - Exit ');

  { Display items in inventory }
  y := 6;
  for letter := 'a' to 'j' do
  begin
    (* Empty slots *)
    if (player_inventory.inventory[invItem].Name = 'Empty') then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + chr(174) + ' empty slot ' + chr(175))
    (* Several arrows *)
    else if (player_inventory.inventory[invItem].Name = 'arrow') and (player_inventory.inventory[invItem].numUses > 1) then
      TextOut(10, y, 'cyan', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name + ' x' + IntToStr(player_inventory.inventory[invItem].numUses))
    (* Equipped items *)
    else if (player_inventory.inventory[invItem].equipped = True) then
      TextOut(10, y, 'cyan', '[' + letter + ']  ' + '[equipped] ' + player_inventory.inventory[invItem].Name)
    else
      TextOut(10, y, 'cyan', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name);
    Inc(y);
    Inc(invItem);
  end;

  (* Display light source stats *)
  if (player_stats.lightEquipped = True) then
    begin
         TextOut(55, 6, 'yellow', chr(232));
         TextOut(57, 6, 'cyan', 'Pixie in a jar');
         TextOut(55, 7, 'cyan', 'Used as a lantern');
         TextOut(55, 8, 'cyan', IntToStr(player_stats.lightCounter) + ' turns remaining');
    end;

  (* Display treasure *)
  TextOut(55, 11, 'cyan', 'Total treasure:');
  if (player_stats.treasure = 0) then
    TextOut(55, 12, 'darkGrey', '0')
  else
    TextOut(55, 12, 'cyan', IntToStr(player_stats.treasure) + ' Gold');

  (* Display current health *)
  TextOut(55, 14, 'cyan', 'Current health:');
  TextOut(55, 15, 'cyan', IntToStr(entityList[0].currentHP) + '/' + IntToStr(entityList[0].maxHP));
end;

procedure displayDropMenu;
var
  y, invItem: byte;
  letter: char;
begin
  invItem := 0;
  drawOutline;
  { Inventory title }
  TextOut(15, 3, 'cyan', 'Drop      ' + chr(240) + ' [a - j] select item to drop');
  { Footer menu }
  TextOut(5, 23, 'cyanBGblackTXT', ' I - Examine item ');
  TextOut(25, 23, 'cyanBGblackTXT', ' Q - Quaff/drink ');
  TextOut(44, 23, 'cyanBGblackTXT', ' W - Weapons/Armour ');
  TextOut(66, 23, 'cyanBGblackTXT', ' X - Exit ');

  { Display items in inventory }
  y := 6;
  for letter := 'a' to 'j' do
  begin
    { Empty slots }
    if (player_inventory.inventory[invItem].Name = 'Empty') then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + chr(174) + ' empty slot ' + chr(175))
    { Several arrows }
    else if (player_inventory.inventory[invItem].Name = 'arrow') and (player_inventory.inventory[invItem].numUses > 1) then
      TextOut(10, y, 'cyan', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name + ' x' + IntToStr(player_inventory.inventory[invItem].numUses))
    { Equipped items cannot be dropped }
    else if (player_inventory.inventory[invItem].equipped = True) then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + '[equipped] ' + player_inventory.inventory[invItem].Name)
    { Items that can be dropped }
    else
      TextOut(10, y, 'cyan', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name);
    Inc(y);
    Inc(invItem);
  end;

  (* Display light source stats *)
  if (player_stats.lightEquipped = True) then
    begin
         TextOut(55, 6, 'grey', chr(232));
         TextOut(57, 6, 'darkGrey', 'Pixie in a jar');
         TextOut(55, 7, 'darkGrey', 'Used as a lantern');
         TextOut(55, 8, 'darkGrey', IntToStr(player_stats.lightCounter) + ' turns remaining');
    end;

  (* Display current health *)
  TextOut(55, 14, 'cyan', 'Current health:');
  TextOut(55, 15, 'cyan', IntToStr(entityList[0].currentHP) + '/' + IntToStr(entityList[0].maxHP));
end;

procedure displayQuaffMenu;
var
  y, invItem: byte;
  letter: char;
begin
  invItem := 0;
  drawOutline;
  { Inventory title }
  TextOut(15, 3, 'cyan', 'Quaff     ' + chr(240) + ' [a - j] select item to drink');
  { Footer menu }
  TextOut(5, 23, 'cyanBGblackTXT', ' I - Examine item ');
  TextOut(25, 23, 'cyanBGblackTXT', ' D - Drop item ');
  TextOut(42, 23, 'cyanBGblackTXT', ' W - Weapons/Armour ');
  TextOut(64, 23, 'cyanBGblackTXT', ' X - Exit ');

  { Display items in inventory }
  y := 6;
  for letter := 'a' to 'j' do
  begin
    { Empty slots }
    if (player_inventory.inventory[invItem].Name = 'Empty') then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + chr(174) + ' empty slot ' + chr(175))
    { Several arrows }
    else if (player_inventory.inventory[invItem].Name = 'arrow') and (player_inventory.inventory[invItem].numUses > 1) then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name + ' x' + IntToStr(player_inventory.inventory[invItem].numUses))
    { Equipped items }
    else if (player_inventory.inventory[invItem].equipped = True) then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + '[equipped] ' + player_inventory.inventory[invItem].Name)
    { Non-drinkable items }
    else if (player_inventory.inventory[invItem].itemType <> itmDrink) then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name)
    { Items that can be drunk }
    else
      TextOut(10, y, 'cyan', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name);
    Inc(y);
    Inc(invItem);
  end;

  (* Display light source stats *)
  if (player_stats.lightEquipped = True) then
    begin
         TextOut(55, 6, 'grey', chr(232));
         TextOut(57, 6, 'darkGrey', 'Pixie in a jar');
         TextOut(55, 7, 'darkGrey', 'Used as a lantern');
         TextOut(55, 8, 'darkGrey', IntToStr(player_stats.lightCounter) + ' turns remaining');
    end;

  (* Display current health *)
  TextOut(55, 14, 'cyan', 'Current health:');
  TextOut(55, 15, 'cyan', IntToStr(entityList[0].currentHP) + '/' + IntToStr(entityList[0].maxHP));
end;

procedure displayWieldMenu;
var
  y, invItem: byte;
  letter: char;
begin
  invItem := 0;
  drawOutline;
  { Inventory title }
  TextOut(14, 3, 'cyan', 'Wear/Wield ' + chr(240) + ' [a - j] select item to equip');
  { Footer menu }
  TextOut(7, 23, 'cyanBGblackTXT', ' I - Examine item ');
  TextOut(27, 23, 'cyanBGblackTXT', ' D - Drop item ');
  TextOut(44, 23, 'cyanBGblackTXT', ' Q - Quaff menu ');
  TextOut(62, 23, 'cyanBGblackTXT', ' X - Exit ');

  { Display items in inventory }
  y := 6;
  for letter := 'a' to 'j' do
  begin
    { Empty slots }
    if (player_inventory.inventory[invItem].Name = 'Empty') then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + chr(174) + ' empty slot ' + chr(175))
    { Items that can be wielded or worn }
    else if (player_inventory.inventory[invItem].itemType = itmWeapon) or
         (player_inventory.inventory[invItem].itemType = itmProjectileWeapon) or
         (player_inventory.inventory[invItem].itemType = itmArmour) then
    begin
      (* Show equipped items *)
      if (player_inventory.inventory[invItem].equipped = True) then
        TextOut(10, y, 'cyan', '[' + letter + ']  ' + '[equipped] ' + player_inventory.inventory[invItem].Name)
      else
        (* Show non-equipped items *)
        TextOut(10, y, 'cyan', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name);
    end
    { if not a weapon or armour }
    { Several arrows }
    else if (player_inventory.inventory[invItem].Name = 'arrow') and (player_inventory.inventory[invItem].numUses > 1) then
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name + ' x' + IntToStr(player_inventory.inventory[invItem].numUses))
    else
      TextOut(10, y, 'darkGrey', '[' + letter + ']  ' + player_inventory.inventory[invItem].Name);
    Inc(y);
    Inc(invItem);
  end;

  (* Display light source stats *)
  if (player_stats.lightEquipped = True) then
    begin
         TextOut(55, 6, 'grey', chr(232));
         TextOut(57, 6, 'darkGrey', 'Pixie in a jar');
         TextOut(55, 7, 'darkGrey', 'Used as a lantern');
         TextOut(55, 8, 'darkGrey', IntToStr(player_stats.lightCounter) + ' turns remaining');
    end;

  (* Display current health *)
  TextOut(55, 14, 'cyan', 'Current health:');
  TextOut(55, 15, 'cyan', IntToStr(entityList[0].currentHP) + '/' + IntToStr(entityList[0].maxHP));
end;

end.
