(* Buy / Sell merchant dialog box *)

unit dlgMerchant;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, video, merchant_inventory, player_stats;

(* Display village merchant inventory *)
procedure displayVillageWares;

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
      TextOut(5, j, FG, '[' + IntToStr(i) + '] ' + villageInv[i].Name + ' - cost $' + IntToStr(villageInv[i].sell));
      Inc(j);
    end;
  end;

  TextOut(17, y, BG, ' [0 - 9] to select,  [x] to exit ');
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
