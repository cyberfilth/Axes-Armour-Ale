(* Potion that cures poison *)

unit potion_curePoison;

{$mode objfpc}{$H+}

interface

(* Create a Potion of Cure Poison *)
procedure createCurePotion(uniqueid, itmx, itmy: smallint);
(* Drink Potion *)
procedure useItem;

implementation

uses
  items, entities, ui;

procedure createCurePotion(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'potion of Cure';
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
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem;
begin
  entities.entityList[0].stsPoison := False;
  Inc(entities.entityList[0].tmrPoison, 0);
  ui.displayMessage('You quaff the potion. The poison leaves your system.');
end;

end.
