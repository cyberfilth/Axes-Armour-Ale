(* A rock, causes base damage of 4 points *)

unit rock;

{$mode fpc}{$H+}

interface

(* Create a rock *)
procedure createRock(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui;

procedure createRock(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'rock';
    itemDescription := 'causes damage if thrown';
    itemArticle := 'a';
    itemType := itmProjectile;
    itemMaterial := matStone;
    useID := 9;
    glyph := chr(7);
    glyphColour := 'lightGrey';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    onMap := True;
    throwable := True;
    throwDamage := 3;
    dice := 0;
    adds := 0;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure useItem;
begin
  ui.displayMessage('You can''t find a use for a rock.');
end;

end.

