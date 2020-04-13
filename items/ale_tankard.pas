(* A tankard of ale - health top up *)
unit ale_tankard;

{$mode objfpc}{$H+}

interface

(* Create a rock *)
procedure createAleTankard(uniqueid, itmx, itmy: smallint);
(* Drink Ale *)
procedure useItem;

implementation

uses
  items, player, ui;

procedure createAleTankard(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'tankard of ale';
    itemDescription := 'restores 5 health points';
    itemType := drink;
    useID := 1;
    glyph := '!';
    inView := False;
    posX := itmx;
    posY := itmy;
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem;
begin
  player.increaseHealth(5);
  if (ThePlayer.stsDrunk = False) then
  begin
    ThePlayer.stsDrunk := True;
    ThePlayer.tmrDrunk := ThePlayer.tmrDrunk + 5;
    ui.bufferMessage('the alcohol slows your reactions');
    ui.writeBufferedMessages;
  end;
end;

end.

