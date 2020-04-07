(* Handles player inventory and associated functions *)
unit player_inventory;

{$mode objfpc}{$H+}

interface

uses
  player, items, ui;

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

implementation

procedure initialiseInventory;
begin
  inventory[0].id := 0; inventory[0].Name := 'Empty';
  inventory[1].id := 1; inventory[1].Name := 'Empty';
  inventory[2].id := 2; inventory[2].Name := 'Empty';
  inventory[3].id := 3; inventory[3].Name := 'Empty';
  inventory[4].id := 4; inventory[4].Name := 'Empty';
  inventory[5].id := 5; inventory[5].Name := 'Empty';
  inventory[6].id := 6; inventory[6].Name := 'Empty';
  inventory[7].id := 7; inventory[7].Name := 'Empty';
  inventory[8].id := 8; inventory[8].Name := 'Empty';
  inventory[9].id := 9; inventory[9].Name := 'Empty';
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


end.

