(* A crude dagger *)
unit dagger;

{$mode objfpc}{$H+}

interface

(* Create a dagger *)
procedure createDagger(uniqueid, itmx, itmy: smallint);
(* Equip weapon *)
procedure useItem;

implementation

uses
  items, entities, ui;

procedure createDagger(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'crude dagger';
    itemDescription := 'adds 1D6 to attack';
    itemType := 'weapon';
    useID := 2;
    glyph := '2';
    inView := False;
    posX := itmx;
    posY := itmy;
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem;
begin
  { TODO : Add Throw Range and Throw Damage }
  entityList[0].weaponEquipped := True;
 Inc(entityList[0].weaponDice);
 // Inc(entityList[0].weaponAdds, 600);
  ui.bufferMessage('The dagger adds 1D6 to your attack');
  ui.writeBufferedMessages;
  // 0 ADDS
end;

end.

