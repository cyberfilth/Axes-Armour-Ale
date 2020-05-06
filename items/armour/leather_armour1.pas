(* Low quality leather armour *)
unit leather_armour1;

{$mode objfpc}{$H+}

interface

(* Create armour *)
procedure createArmour(uniqueid, itmx, itmy: smallint);
(* Wear armour *)
procedure useItem(equipped: boolean);

implementation

uses
  items, entities, ui;

procedure createArmour(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'Leather armour';
    itemDescription := 'adds 2 to defense';
    itemType := 'armour';
    useID := 3;
    glyph := '3';
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
    ui.bufferMessage('The armour adds 2 points to your defense');
    ui.updateArmour('Leather armour');
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

