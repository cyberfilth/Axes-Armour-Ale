(* Handles player inventory and associated functions *)
unit player_inventory;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  Graphics, SysUtils, player, items, ui, globalutils;

type
  (* Items in inventory *)
  Equipment = record
    id, useID: smallint;
    Name, description: shortstring;
    itemType: itemCategory;
    glyph: char;
    (* Is the item still in the inventory *)
    inInventory: boolean;
    (* Is the item being worn or wielded *)
    equipped: boolean;
  end;

var
  inventory: array[0..9] of Equipment;
  (* 0 - main menu, 1 - drop menu, 2 - quaff menu *)
  menuState: byte;

(* Initialise empty player inventory *)
procedure initialiseInventory;
(* Add to inventory *)
procedure addToInventory(itemNumber: smallint);
(* Display the inventory screen *)
procedure showInventory;
(* Show menu at bottom of screen *)
procedure bottomMenu(style: byte);
(* Highlight inventory slots *)
procedure highlightSlots(i, x: smallint);
(* Dim inventory slots *)
procedure dimSlots(i, x: smallint);
(* Accept menu input *)
procedure menu(selection: word);
(* Drop menu *)
procedure drop(dropItem: byte);
(* Quaff menu *)
procedure quaff(quaffItem: byte);

implementation

uses
  main;

procedure initialiseInventory;
begin
  inventory[0].id := 0;
  inventory[0].Name := 'Empty';
  inventory[0].equipped := False;
  inventory[1].id := 1;
  inventory[1].Name := 'Empty';
  inventory[1].equipped := False;
  inventory[2].id := 2;
  inventory[2].Name := 'Empty';
  inventory[2].equipped := False;
  inventory[3].id := 3;
  inventory[3].Name := 'Empty';
  inventory[3].equipped := False;
  inventory[4].id := 4;
  inventory[4].Name := 'Empty';
  inventory[4].equipped := False;
  inventory[5].id := 5;
  inventory[5].Name := 'Empty';
  inventory[5].equipped := False;
  inventory[6].id := 6;
  inventory[6].Name := 'Empty';
  inventory[6].equipped := False;
  inventory[7].id := 7;
  inventory[7].Name := 'Empty';
  inventory[7].equipped := False;
  inventory[8].id := 8;
  inventory[8].Name := 'Empty';
  inventory[8].equipped := False;
  inventory[9].id := 9;
  inventory[9].Name := 'Empty';
  inventory[9].equipped := False;
end;

procedure addToInventory(itemNumber: smallint);
var
  i: smallint;
begin
  for i := 0 to 9 do
  begin
    if (inventory[i].Name = 'Empty') then
    begin
      itemList[itemNumber].onMap := False;
      (* Populate inventory with item description *)
      inventory[i].id := i;
      inventory[i].Name := itemList[itemNumber].itemname;
      inventory[i].description := itemList[itemNumber].itemDescription;
      inventory[i].itemType := itemList[itemNumber].itemType;
      inventory[i].useID := itemList[itemNumber].useID;
      inventory[i].glyph := itemList[itemNumber].glyph;
      inventory[i].inInventory := True;
      ui.displayMessage('You pick up the ' + inventory[i].Name);
      exit;
    end
    else
      ui.displayMessage('Inventory is full');
  end;

end;

procedure showInventory;
var
  i, x: smallint;
begin
  main.gameState := 2; // Accept keyboard commands for inventory screen
  menuState := 0;
  currentScreen := inventoryScreen; // Display inventory screen
  (* Clear the screen *)
  inventoryScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  inventoryScreen.Canvas.FillRect(0, 0, inventoryScreen.Width, inventoryScreen.Height);
  (* Draw title bar *)
  inventoryScreen.Canvas.Brush.Color := globalutils.MESSAGEFADE6;
  inventoryScreen.Canvas.Rectangle(50, 40, 785, 80);
  (* Draw title *)
  inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
  inventoryScreen.Canvas.Brush.Style := bsClear;
  inventoryScreen.Canvas.Font.Size := 12;
  inventoryScreen.Canvas.TextOut(100, 50, 'Inventory slots');
  inventoryScreen.Canvas.Font.Size := 10;
  (* List inventory *)
  x := 90; // x is position of each new line
  for i := 0 to 9 do
  begin
    x := x + 20;
    if (inventory[i].Name = 'Empty') then
      dimSlots(i, x)
    else
      highlightSlots(i, x);
  end;
  bottomMenu(0);
end;

procedure bottomMenu(style: byte);
(* 0 main menu, 1 drop *)
begin
  (* Draw menu bar *)
  inventoryScreen.Canvas.Brush.Color := globalutils.MESSAGEFADE6;
  inventoryScreen.Canvas.Rectangle(50, 345, 785, 375);
  (* Show menu options at bottom of screen *)
  case style of
    0:  // Main menu
    begin
      inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
      inventoryScreen.Canvas.Brush.Style := bsClear;
      inventoryScreen.Canvas.TextOut(100, 350,
        'D key for drop menu  |  Q key for quaff/drink menu  |  ESC key to exit');
    end;
    1:  // Select Inventory slot
    begin
      inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
      inventoryScreen.Canvas.Brush.Style := bsClear;
      inventoryScreen.Canvas.TextOut(100, 350,
        '0..9 to select an inventory slot  |  ESC key to go back');
    end;
  end;
end;

procedure highlightSlots(i, x: smallint);
begin
  inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
  inventoryScreen.Canvas.TextOut(50, x, '[' + IntToStr(i) + '] ' +
    inventory[i].Name + ' - ' + inventory[i].description);
end;

procedure dimSlots(i, x: smallint);
begin
  inventoryScreen.Canvas.Font.Color := MESSAGEFADE1;
  inventoryScreen.Canvas.TextOut(50, x, '[' + IntToStr(i) + '] <empty slot>');
end;

procedure menu(selection: word);
begin
  case selection of
    0: // ESC key i pressed
    begin
      if (menuState = 0) then
      begin
        main.gameState := 1;
        main.currentScreen := tempScreen;
        exit;
      end
      else if (menuState = 1) then // In the Drop screen
        showInventory
      else if (menuState = 2) then // In the Quaff screen
        showInventory;
    end;
    1: drop(10); // Drop menu
    2:  // 0 slot
    begin
      if (menuState = 1) then
        drop(0)
      else if (menuState = 2) then
        quaff(0);
    end;
    3: // 1 slot
    begin
      if (menuState = 1) then
        drop(1)
      else if (menuState = 2) then
        quaff(1);
    end;
    4: // 2 slot
    begin
      if (menuState = 1) then
        drop(2)
      else if (menuState = 2) then
        quaff(2);
    end;
    5: quaff(10);  // Quaff menu
  end;
end;

procedure drop(dropItem: byte);
var
  i, x: smallint;
begin
  menuState := 1;
  (* Clear the screen *)
  inventoryScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  inventoryScreen.Canvas.FillRect(0, 0, inventoryScreen.Width, inventoryScreen.Height);
  (* Draw title bar *)
  inventoryScreen.Canvas.Brush.Color := globalutils.MESSAGEFADE6;
  inventoryScreen.Canvas.Rectangle(50, 40, 785, 80);
  (* Draw title *)
  inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
  inventoryScreen.Canvas.Brush.Style := bsClear;
  inventoryScreen.Canvas.Font.Size := 12;
  inventoryScreen.Canvas.TextOut(100, 50, 'Select item to drop');
  inventoryScreen.Canvas.Font.Size := 10;
  (* List inventory *)
  x := 90; // x is position of each new line
  for i := 0 to 9 do
  begin
    x := x + 20;
    if (inventory[i].Name = 'Empty') or (inventory[i].equipped = True) then
      dimSlots(i, x)
    else
      highlightSlots(i, x);
  end;
  (* Bottom menu *)
  bottomMenu(1);
  if (dropItem <> 10) then
  begin
    if (inventory[dropItem].Name <> 'Empty') and
      (inventory[dropItem].equipped <> True) then
    begin   { TODO : First search for a space in the itemList that has the onMap flag set to false and use that slot }
      (* Create a new entry in item list and copy item description *)
      Inc(items.itemAmount);
      items.listLength := length(items.itemList);
      SetLength(items.itemList, items.listLength + 1);
      with items.itemList[items.listLength] do
      begin
        itemID := items.listLength;
        itemName := inventory[dropItem].Name;
        itemDescription := inventory[dropItem].description;
        itemType := inventory[dropItem].itemType;
        glyph := inventory[dropItem].glyph;
        inView := True;
        posX := ThePlayer.posX;
        posY := ThePlayer.posY;
        onMap := True;
        discovered := True;
      end;
      ui.displayMessage('You drop the ' + inventory[dropItem].Name);
      Inc(playerTurn);
      (* Remove from inventory *)
      inventory[dropItem].Name := 'Empty';
      showInventory;
    end;
  end;
end;

procedure quaff(quaffItem: byte);
var
  i, x: smallint;
begin
  menuState := 2;
  (* Clear the screen *)
  inventoryScreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  inventoryScreen.Canvas.FillRect(0, 0, inventoryScreen.Width, inventoryScreen.Height);
  (* Draw title bar *)
  inventoryScreen.Canvas.Brush.Color := globalutils.MESSAGEFADE6;
  inventoryScreen.Canvas.Rectangle(50, 40, 785, 80);
  (* Draw title *)
  inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
  inventoryScreen.Canvas.Brush.Style := bsClear;
  inventoryScreen.Canvas.Font.Size := 12;
  inventoryScreen.Canvas.TextOut(100, 50, 'Select item to drink');
  inventoryScreen.Canvas.Font.Size := 10;
  (* List inventory *)
  x := 90; // x is position of each new line
  for i := 0 to 9 do
  begin
    x := x + 20;
    if (inventory[i].Name = 'Empty') or (inventory[i].itemType <> drink) then
      dimSlots(i, x)
    else
      highlightSlots(i, x);
  end;
  (* Bottom menu *)
  bottomMenu(1);
  if (quaffItem <> 10) then
  begin
    if (inventory[quaffItem].Name <> 'Empty') and
      (inventory[quaffItem].itemType = drink) then
    begin
      ui.bufferMessage('You quaff the ' + inventory[quaffItem].Name);
      items.lookupUse(inventory[quaffItem].useID);
      Inc(playerTurn);
      (* Remove from inventory *)
      inventory[quaffItem].Name := 'Empty';
      showInventory;
    end;
  end;
end;

end.
