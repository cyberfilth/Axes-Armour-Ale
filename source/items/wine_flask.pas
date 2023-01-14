(* Flask of wine - cures poison *)

unit wine_flask;

{$mode objfpc}{$H+}

interface

(* Create a Potion of Cure Poison *)
procedure createWineFlask(itmx, itmy: smallint);
(* Drink Potion *)
procedure useItem;

implementation

uses
  items, entities, ui;

procedure createWineFlask(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'flask of wine';
    itemDescription := 'cures poison';
    itemArticle := 'a';
    itemType := itmDrink;
    itemMaterial := matSteel;
    useID := 6;
    glyph := '!';
    glyphColour := 'green';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    buy := 4;
    sell := 2;
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
  if (entityList[0].stsPoison = True) then
  begin
    entities.entityList[0].tmrPoison := 0;
    entities.entityList[0].stsPoison := False;
    Inc(entities.entityList[0].tmrDrunk, 5);
    (* Update UI *)
    ui.displayStatusEffect(0, 'poison');
    ui.poisonStatusSet := False;
    entityList[0].glyphColour := 'yellow';
    ui.displayMessage('The alcohol slows your reactions.');
    ui.displayMessage('You drink the wine. The poison leaves your system.');
  end
  else
  begin
    Inc(entities.entityList[0].tmrDrunk, 5);
    ui.displayMessage('The alcohol slows your reactions.');
    ui.displayMessage('You drink the wine. You don''t notice any effects');
  end;
end;

end.
