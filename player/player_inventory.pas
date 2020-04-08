(* Handles player inventory and associated functions *)
unit player_inventory;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils, items, ui, globalutils;

type
  (* Items in inventory *)
  Equipment = record
    id: smallint;
    Name: string;
  end;

var
  inventory: array[0..9] of Equipment;

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
procedure drop;

implementation

uses
  main;

procedure initialiseInventory;
begin
  inventory[0].id := 0;
  inventory[0].Name := 'Empty';
  inventory[1].id := 1;
  inventory[1].Name := 'Empty';
  inventory[2].id := 2;
  inventory[2].Name := 'Empty';
  inventory[3].id := 3;
  inventory[3].Name := 'Empty';
  inventory[4].id := 4;
  inventory[4].Name := 'Empty';
  inventory[5].id := 5;
  inventory[5].Name := 'Empty';
  inventory[6].id := 6;
  inventory[6].Name := 'Empty';
  inventory[7].id := 7;
  inventory[7].Name := 'Empty';
  inventory[8].id := 8;
  inventory[8].Name := 'Empty';
  inventory[9].id := 9;
  inventory[9].Name := 'Empty';
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
      inventory[i].id := itemNumber;
      inventory[i].Name := itemList[itemNumber].itemName;
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
    0:
    begin
      inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
      inventoryScreen.Canvas.Brush.Style := bsClear;
      inventoryScreen.Canvas.TextOut(100, 350, 'D key to drop  |  ESC key to exit');
    end;
    1:
    begin
      inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
      inventoryScreen.Canvas.Brush.Style := bsClear;
      inventoryScreen.Canvas.TextOut(100, 350, '0..9 select inventory slot');
    end;
  end;
end;

procedure highlightSlots(i, x: smallint);
begin
  inventoryScreen.Canvas.Font.Color := UITEXTCOLOUR;
  inventoryScreen.Canvas.TextOut(50, x, '[' + IntToStr(i) + '] ' +
    inventory[i].Name + ' - ' + itemList[(inventory[i].id)].itemDescription);
end;

procedure dimSlots(i, x: smallint);
begin
  inventoryScreen.Canvas.Font.Color := MESSAGEFADE1;
  inventoryScreen.Canvas.TextOut(50, x, '[' + IntToStr(i) + '] <empty slot>');
end;

procedure menu(selection: word);
begin
  case selection of
    1: drop;
  end;
end;

procedure drop;
begin
   bottomMenu(1);
end;

end.
