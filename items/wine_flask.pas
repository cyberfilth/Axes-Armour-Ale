(* Flask of wine - cures poison *)
unit wine_flask;

{$mode objfpc}{$H+}

interface

(* Create a flask of wine *)
procedure createWineFlask(uniqueid, itmx, itmy: smallint);
(* Drink wine *)
procedure useItem;


implementation

uses
  items, entities, ui, player;

procedure createWineFlask(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'flask of wine';
    itemDescription := 'cures poison';
    itemType := 'drink';
    useID := 6;
    glyph := '6';
    inView := False;
    posX := itmx;
    posY := itmy;
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem;
begin
  if (entities.entityList[0].stsPoison = True) then
  begin
    entities.entityList[0].stsPoison := False;
    entities.entityList[0].tmrPoison := 0;
    ui.poisonStatusSet := False;
    ui.displayStatusEffect(0, 'poison');
    ui.bufferMessage('The wine removes all trace of poison');
  end;
  entities.entityList[0].stsDrunk := True;
  Inc(entities.entityList[0].tmrDrunk, 5);
  ui.bufferMessage('The wine slows your reactions');
  ui.writeBufferedMessages;
end;

end.

