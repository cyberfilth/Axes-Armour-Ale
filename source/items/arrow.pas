(* Arrow *)

unit arrow;

{$mode fpc}{$H+}

interface

(* Create an arrow *)
procedure createArrow(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui;

procedure createArrow(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'arrow';
    itemDescription := 'wooden flight arrow';
    itemArticle := 'an';
    itemType := itmAmmo;
    itemMaterial := matWood;
    useID := 12;
    glyph := '|';
    glyphColour := 'brown';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 1;
    buy := 1;
    sell := 2;
    onMap := True;
    throwable := False;
    throwDamage := 5;
    dice := 0;
    adds := 0;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem;
begin
  ui.displayMessage('You can''t find a use for an arrow.');
end;

end.
