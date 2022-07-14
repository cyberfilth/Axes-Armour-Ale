(* A tankard of ale - health top up *)
unit ale_tankard;

{$mode objfpc}{$H+}

interface

(* Create a tankard of ale *)
procedure createAleTankard(itmx, itmy: smallint);
(* Drink Ale *)
procedure useItem;

implementation

uses
  items, entities, ui, player;

procedure createAleTankard(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'tankard of ale';
    itemDescription := 'restores 5 health points';
    itemArticle := 'a';
    itemType := itmDrink;
    itemMaterial := matFlammable;
    useID := 1;
    glyph := '!';
    glyphColour := 'lightCyan';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    onMap := True;
    throwable := False;
    throwDamage := 0;
    dice := 0;
    adds := 0;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem;
begin
  player.increaseHealth(5);
  entities.entityList[0].stsDrunk := True;
  Inc(entities.entityList[0].tmrDrunk, 5);
  ui.displayMessage('You quaff the ale. The alcohol slows your reactions.');
end;

end.
