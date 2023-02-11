(* Buy / Sell merchant dialog box *)

unit dlgMerchant;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, video, merchant_inventory;

(* Display village merchant inventory *)
procedure displayVillageWares;

implementation

uses
  ui, main;

procedure displayVillageWares;
var
  x, y: smallint;
  BG, FG: shortstring;
begin
  main.gameState := stBarterShowWares;

  // count number of entries in the inventory and calculate size
  // of window accordingly

  x := 3;
  y := 5;
  BG := 'blue';
  FG := 'yellow';
  LockScreenUpdate;
  (* Top border *)
  TextOut(x, y, BG, chr(201));
  for x := 4 to 53 do
    TextOut(x, 5, BG, chr(205));
  TextOut(54, y, BG, chr(187));
  (* End borders around title *)
  TextOut(5, y, BG, chr(181));
  TextOut(25, y, BG, chr(198));
  (* Vertical sides *)
  for y := 6 to 8 do
    TextOut(3, y, BG, chr(186) + '                                                  ' + chr(186));
  (* Bottom border *)
  TextOut(3, 9, BG, chr(200)); // bottom left corner
  for x := 4 to 53 do
    TextOut(x, 9, BG, chr(205));
  TextOut(54, 9, BG, chr(188)); // bottom right corner
  (* Write the title *)
  TextOut(6, 5, 'white', 'The merchant speaks');
  (* Write the message *)
  TextOut(5, 7, FG, 'Do you want to see my wares?');
  TextOut(22, 9,FG, ' [y]es, [n]o ');
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.

