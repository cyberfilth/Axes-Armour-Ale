(* Buy / Sell merchant dialog box *)

unit dlgMerchant;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, video, merchant_inventory, player_inventory, player_stats, items;

var
  (* cost of selected item *)
  currentCost: smallint;
  (* currently selected item to buy / sell *)
  currentItem: word;

(* Display village merchant inventory *)
procedure displayVillageWares;
(* Display info on an item from merchants inventory *)
procedure selectVillageItem(selection: word);
(* Buy the selected item *)
procedure buyVillage;

(* Display a message that the item cannot be bought *)
procedure exitDialogVillage(msg: byte);

(* Dialog that prompts player to buy or sell an item *)
procedure buySellVillagePrompt;

(* Calculates 2/3 of value to get the sale price *)
function saleValue(amnt: smallint): smallint;
(* Display player inventory *)
procedure displayVillPlayerInv;
(* Display info on an item from players own inventory *)
procedure selectPlayerItem(selection: word);
(* Buy the selected item *)
procedure sellVillage;

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
    currentItem := selection;
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
    player_inventory.buyItemVillInventory(currentItem);
    (* Update the merchants money *)
    Inc(merchant_inventory.villagePurse, currentCost);
    (* Remove from merchants inventory *)
    i := currentItem;
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
  else if (msg = 3) then
    msgString := 'You purchase the equipment'
  else if (msg = 4) then
    msgString := 'You have nothing I want to buy'
  else if (msg = 5) then
    msgString := 'I don''t have any funds right now'
  else if (msg = 6) then
    msgString := 'You sell the equipment';  
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
    TextOut(6 + Length('We cannot trade'), y, BG, chr(198));
    (* Vertical sides *)
    for y := 6 to 8 do
      TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
    (* Bottom border *)
    TextOut(3, 9, BG, chr(200)); // bottom left corner
    for x := 4 to 53 do
      TextOut(x, 9, BG, chr(205));
    TextOut(54, 9, BG, chr(188)); // bottom right corner
    (* Write the title *)
    TextOut(6, 5, BG, 'We cannot trade');
    Inc(y);
    (* Display the message *)
    TextOut(5, 7, FG, msgString);
    TextOut(17, 9, BG, ' [x] to exit ');
    UnlockScreenUpdate;
    UpdateScreen(False);
end;

procedure buySellVillagePrompt;
var
  x, y: smallint;
  BG, FG: shortstring;
begin
    ui.clearPopup;
    main.gameState := stBarterBuySell;
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
    TextOut(6 + Length('Buy or Sell?'), y, BG, chr(198));
    (* Vertical sides *)
    for y := 6 to 8 do
      TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
    (* Bottom border *)
    TextOut(3, 9, BG, chr(200)); // bottom left corner
    for x := 4 to 53 do
      TextOut(x, 9, BG, chr(205));
    TextOut(54, 9, BG, chr(188)); // bottom right corner
    (* Write the title *)
    TextOut(6, 5, BG, 'Buy or Sell?');
    Inc(y);
    (* Display the message *)
    TextOut(5, 7, FG, 'Are you looking to Buy or Sell?');
    TextOut(17, 9, BG, ' [b] Buy,  [s] Sell,  [x] to exit ');
    UnlockScreenUpdate;
    UpdateScreen(False);
end;

function saleValue(amnt: smallint): smallint;
var
	third: smallint;
begin
	third := amnt DIV 3;
	if (third = 0) then
		third := 1;
	Result := (third * 2);
end;

procedure displayVillPlayerInv;
var
  x, y, i, j, totalEntries: smallint;
  BG, FG: shortstring;
begin
  ui.clearPopup;
  (* Check if the player is carrying something the merchant wants to buy *)
  if (player_inventory.totalForSale < 1) then
    exitDialogVillage(4)
  (* Check if the merchant has money in their purse *)
  else if (merchant_inventory.villagePurse < 1) then
    exitDialogVillage(5)
	else
	begin
		(* Display the players inventory *)
		main.gameState := stBarterShowSellWares;
		(* Get the total number of items in inventory use this to calculate size of the dialog    *)
		totalEntries := player_inventory.totalForSale;  
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
		TextOut(6 + Length(' Select item from your inventory '), y, BG, chr(198));
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
		TextOut(6, 5, BG, ' Select item from your inventory ');

		(* List items *)
		for i := 0 to totalEntries do
		begin
		  if (player_inventory.inventory[i].itemType = itmDrink) or (player_inventory.inventory[i].itemType = itmWeapon) or (player_inventory.inventory[i].itemType = itmArmour) then
		  begin
		  		if (player_inventory.inventory[i].equipped = False) then
		  		begin
		    		TextOut(5, j, FG, '[' + IntToStr(i) + '] ' + player_inventory.inventory[i].Name + ' - sale value $' + IntToStr(saleValue(player_inventory.inventory[i].value)));
		    		Inc(j);
		    	end;	
		  end;
		end;
		TextOut(17, y, BG, ' [0 - 9] to select,  [x] to exit '); // logging.logAction();
		UnlockScreenUpdate;
		UpdateScreen(False);
  end;
end;

procedure selectPlayerItem(selection: word);
var
  x, y: smallint;
  BG, FG, itmType: shortstring;
begin
    ui.clearPopup;
    main.gameState := stBarterConfirmSell;
    if (player_inventory.inventory[selection].itemType = itmDrink) then
       itmType := 'drink'
    else if (player_inventory.inventory[selection].itemType = itmWeapon) or (player_inventory.inventory[selection].itemType = itmProjectileWeapon) then
       itmType := 'weapon'
    else if (player_inventory.inventory[selection].itemType = itmArmour) then
       itmType := 'armour'
    else if (player_inventory.inventory[selection].itemType = itmProjectile) then
       itmType := 'projectile'
    else if (player_inventory.inventory[selection].itemType = itmAmmo) then
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
    TextOut(6 + Length('Confirm sale of ' + itmType), y, BG, chr(198));
    (* Vertical sides *)
    for y := 6 to 10 do
      TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
    (* Bottom border *)
    TextOut(3, y, BG, chr(200)); // bottom left corner
    for x := 4 to 53 do
      TextOut(x, y, BG, chr(205));
    TextOut(54, y, BG, chr(188)); // bottom right corner
    (* Write the title *)
    TextOut(6, 5, BG, 'Confirm sale of ' + itmType);
    Inc(y);
    (* List item *)
    TextOut(5, 7, player_inventory.inventory[selection].glyphColour, player_inventory.inventory[selection].glyph);
    TextOut(7, 7, fG, player_inventory.inventory[selection].Name);
    TextOut(5, 8, FG, player_inventory.inventory[selection].description + ' - sell for $' + IntToStr(saleValue(player_inventory.inventory[selection].value)));
    TextOut(17, 10, BG, ' [y] to sell,  [x] to exit ');
    UnlockScreenUpdate;
    UpdateScreen(False);
    currentCost := saleValue(player_inventory.inventory[selection].value);
    currentItem := selection;
end;

procedure sellVillage;
var
  i: smallint;
begin
  (* Add to merchants inventory *)
  { Find first empty slot }
  for i := 0 to High(villageInv) do
  begin
  	if (villageInv[i].Name = 'Empty') then
  			break;  	
  end;		
  with villageInv[i] do
  begin
    id := i;
    Name := player_inventory.inventory[currentItem].Name;
    description := player_inventory.inventory[currentItem].description;
    article := player_inventory.inventory[currentItem].article;
    itemType := player_inventory.inventory[currentItem].itemType;
    itemMaterial := player_inventory.inventory[currentItem].itemMaterial;
    glyph := player_inventory.inventory[currentItem].glyph;
    glyphColour := player_inventory.inventory[currentItem].glyphColour;
    numUses := player_inventory.inventory[currentItem].numUses;
    value := player_inventory.inventory[currentItem].value;
    throwable := player_inventory.inventory[currentItem].throwable;
    throwDamage := player_inventory.inventory[currentItem].throwDamage;
    dice := player_inventory.inventory[currentItem].dice;
    adds := player_inventory.inventory[currentItem].adds;
    useID := player_inventory.inventory[currentItem].useID;
  end;
  (* Remove item from inventory *)
  player_inventory.removeSoldItem(currentItem); 
  (* Update the merchants money *)
  Dec(merchant_inventory.villagePurse, currentCost);
  exitDialogVillage(6);
end;

end.
