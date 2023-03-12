(* Flask of wine - restores Magick *)

unit elven_wine;

{$mode objfpc}{$H+}

interface

(* Create a flask of wine *)
procedure createWineFlask(itmx, itmy: smallint);
(* Drink Potion *)
procedure useItem;

implementation

uses
  items, entities, ui, player_stats;

procedure createWineFlask(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Elven wine';
    itemDescription := 'restores Magick';
    itemArticle := 'an';
    itemType := itmDrink;
    itemMaterial := matFlammable;
    useID := 31;
    glyph := '!';
    glyphColour := 'green';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    value := 4;
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
  if (player_stats.currentMagick < player_stats.maxMagick) then
  begin
    player_stats.currentMagick := player_stats.maxMagick;
    Inc(entities.entityList[0].tmrDrunk, player_stats.maxMagick);
    (* Update UI *)
    ui.displayMessage('The alcohol slows your reactions.');
    ui.displayMessage('You drink the wine. Your magick regenerates.');
  end
  else
  begin
    Inc(entities.entityList[0].tmrDrunk, player_stats.maxMagick);
    ui.displayMessage('The alcohol slows your reactions.');
    ui.displayMessage('You drink the wine. You don''t notice any effects');
  end;
end;

end.