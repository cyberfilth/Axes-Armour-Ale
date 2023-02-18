(* Buy / Sell merchant dialog box *)

unit dlgMerchant;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, video, merchant_inventory, player_inventory, player_stats, items;

var
  (* cost of selected item *)
  currentCost: smallint;
  (* currently selected item to buy *)
  currentBuy: word;

(* Display village merchant inventory *)
procedure displayVillageWares;
(* Player selects an item from the inventory *)
procedure selectVillageItem(selection: word);
(* Buy the selected item *)
procedure buyVillage;
(* Display a message that the item cannot be bought *)
procedure exitDialogVillage(msg: byte);

implementation

uses
  ui, main;

procedure displayVillageWares;
var
  x, y, i, j, totalEntries: smallint;
  BG, FG, title: shortstring;
begin
  main.gameState := stBarterShowWares;
  totalEntries := 0;
  (* Get the total number of items in inventory
     use this to calculate size of the dialog    *)
  for i := 0 to High(villageInv) do
  begin
    if (villageInv[i].Name <> 'Empty') then
      Inc(totalEntries);
  end;
  title := ' Select item to buy - Gold: ' + IntToStr(player_stats.treasure) + ' ';
  i := 0;
  j := 7;
  x := 3;
  y := 5;
  BG := 'cyan';
  FG := 'white';
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, BG, chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, BG, chr(205));
  TextOut(54, y, BG, chr(187));
  (* End borders around title *)
  TextOut(5, y, BG, chr(181));
  TextOut(6 + Length(title), y, BG, chr(198));
  (* Vertical sides *)
  for y := 6 to (8 + totalEntries) do
    TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
  y := 8 + totalEntries;
  (* Bottom border *)
  TextOut(3, y, BG, chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, y, BG, chr(205));
  TextOut(54, y, BG, chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(6, 5, BG, title);

  (* List items *)
  for i := 0 to High(villageInv) do
  begin
    if (villageInv[i].Name <> 'Empty') then
    begin
      TextOut(5, j, FG, '[' + IntToStr(i) + '] ' + villageInv[i].Name + ' - cost $' + IntToStr(villageInv[i].Value + 1));
      Inc(j);
    end;
  end;
  (* If there are no items in the inventory *)
  if (totalEntries = 0) then
     TextOut(5, j, FG, ' I seem to have run out of stock...');
  TextOut(17, y, BG, ' [0 - 9] to select,  [x] to exit ');
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure selectVillageItem(selection: word);
var
  x, y: smallint;
  BG, FG, itmType: shortstring;
begin
  (* First check if there is anything in the merchants inventory *)
  if (villageInv[selection].Name <> 'Empty') then
  begin
    ui.clearPopup;
    main.gameState := stBarterConfirmBuy;
    if (villageInv[selection].itemType = itmDrink) then
       itmType := 'drink'
    else if (villageInv[selection].itemType = itmWeapon) or (villageInv[selection].itemType = itmProjectileWeapon) then
       itmType := 'weapon'
    else if (villageInv[selection].itemType = itmArmour) then
       itmType := 'armour'
    else if (villageInv[selection].itemType = itmProjectile) then
       itmType := 'projectile'
    else if (villageInv[selection].itemType = itmAmmo) then
       itmType := 'ammunition'
    else
        itmType := 'item';
    x := 3;
    y := 5;
    BG := 'cyan';
    FG := 'white';
    LockScreenUpdate;
    (* Top border *)
    TextOut(x, y, BG, chr(201));
    for x := 4 to 53 do
      TextOut(x, 5, BG, chr(205));
    TextOut(54, y, BG, chr(187));
    (* End borders around title *)
    TextOut(5, y, BG, chr(181));
    TextOut(6 + Length('Buy ' + itmType), y, BG, chr(198));
    (* Vertical sides *)
    for y := 6 to 10 do
      TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
    (* Bottom border *)
    TextOut(3, y, BG, chr(200)); // bottom left corner
    for x := 4 to 53 do
      TextOut(x, y, BG, chr(205));
    TextOut(54, y, BG, chr(188)); // bottom right corner
    (* Write the title *)
    TextOut(6, 5, BG, 'Buy ' + itmType);
    Inc(y);
    (* List item *)
    TextOut(5, 7, villageInv[selection].glyphColour, villageInv[selection].glyph);
    TextOut(7, 7, fG, villageInv[selection].Name);
    TextOut(5, 8, FG, villageInv[selection].description + ' - cost $' + IntToStr(villageInv[selection].Value + 1));
    TextOut(17, 10, BG, ' [y] to buy,  [x] to exit ');
    UnlockScreenUpdate;
    UpdateScreen(False);
    currentCost := villageInv[selection].Value + 1;
    currentBuy := selection;
  end;
end;

procedure buyVillage;
var
  blockerType: byte;
  canBuy: boolean;
  i: smallint;
begin
  blockerType := 1;
  canBuy := False;
  i := 0;
  (* Check if the player can afford the item *)
  if (currentCost > player_stats.treasure) then
    blockerType := 1
  (* Check if the player has space in their inventory *)
  else if (player_inventory.emptySlotAvailable = False) then
    blockerType := 2
  else
      canBuy := True;
  (* Show message that the item cannot be bought and exit *)
  if (canBuy = False) then
    exitDialogVillage(blockerType);

  (* Player buys the item *)
  if (canBuy = True) then
  begin
    (* Add item to inventory *)
    player_inventory.buyItemVillInventory(currentBuy);
    (* Update the merchants money *)
    Inc(merchant_inventory.villagePurse, currentCost);
    (* Remove from merchants inventory *)
    i := currentBuy;
    {$I ../entities/npc/merchant_inventoryemptyslot}
    exitDialogVillage(3);
  end;
end;

procedure exitDialogVillage(msg: byte);
var
  x, y: smallint;
  BG, FG, msgString: shortstring;
begin
  ui.clearPopup;
  main.gameState := stBarterExitdlg;
  if (msg = 1) then
    msgString := 'You do not have enough gold'
  else if (msg = 2) then
    msgString := 'You don''t have space for this'
  else
    msgString := 'You purchase the equipment';
    x := 3;
    y := 5;
    BG := 'cyan';
    FG := 'white';
    LockScreenUpdate;
    (* Top border *)
    TextOut(x, y, BG, chr(201));
    for x := 4 to 53 do
      TextOut(x, 5, BG, chr(205));
    TextOut(54, y, BG, chr(187));
    (* End borders around title *)
    TextOut(5, y, BG, chr(181));
    TextOut(6 + Length('Cannot buy this item'), y, BG, chr(198));
    (* Vertical sides *)
    for y := 6 to 8 do
      TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
    (* Bottom border *)
    TextOut(3, 9, BG, chr(200)); // bottom left corner
    for x := 4 to 53 do
      TextOut(x, 9, BG, chr(205));
    TextOut(54, 9, BG, chr(188)); // bottom right corner
    (* Write the title *)
    TextOut(6, 5, BG, 'Cannot buy this item');
    Inc(y);
    (* Display the message *)
    TextOut(5, 7, FG, msgString);
    TextOut(17, 9, BG, ' [x] to exit ');
    UnlockScreenUpdate;
    UpdateScreen(False);
end;

end.
