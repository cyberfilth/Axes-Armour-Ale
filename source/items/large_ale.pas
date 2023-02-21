(* A large tankard of ale - health top up *)
unit large_ale;

{$mode objfpc}{$H+}

interface

(* Create a large tankard of ale *)
procedure createLargeAle(itmx, itmy: smallint);
(* Drink Ale *)
procedure useItem;

implementation

uses
  items, entities, ui, player;

procedure createLargeAle(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'large ale';
    itemDescription := 'restores 12 health points';
    itemArticle := 'a';
    itemType := itmDrink;
    itemMaterial := matFlammable;
    useID := 29;
    glyph := '!';
    glyphColour := 'lightCyan';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 3;
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
  player.increaseHealth(12);
  entities.entityList[0].stsDrunk := True;
  Inc(entities.entityList[0].tmrDrunk, 12);
  ui.displayMessage('You quaff the ale. The alcohol slows your reactions.');
end;

end.