(* Low quality cloth armour *)
unit cloth_armour1;

{$mode objfpc}{$H+}

interface

(* Create armour *)
procedure createClothArmour(uniqueid, itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui;

procedure createClothArmour(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'Cloth armour';
    itemDescription := 'adds 1 to defense';
    itemType := 'armour';
    useID := 5;
    glyph := '5';
    inView := False;
    posX := itmx;
    posY := itmy;
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem(equipped: boolean);
begin
   if (equipped = False) then
    (* To wear the armour *)
  begin
    entityList[0].armourEquipped := True;
    Inc(entityList[0].defense, 2);
    ui.bufferMessage('The armour adds 1 point to your defense');
    ui.updateArmour('Cloth armour');
    ui.updateDefence;
    ui.writeBufferedMessages;
  end
  else
    (* To remove the armour *)
  begin
    entityList[0].armourEquipped := False;
    Dec(entityList[0].defense, 2);
    ui.updateDefence;
    ui.updateArmour('none');
    ui.writeBufferedMessages;
  end;
end;

end.

