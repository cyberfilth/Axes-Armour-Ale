(* A rock, causes base damage of 4 points *)

unit rock;

{$mode fpc}{$H+}

interface

(* Create a rock *)
procedure createRock(uniqueid, itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui;

procedure createRock(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'rock';
    itemDescription := 'causes damage if thrown';
    itemArticle := 'a';
    itemType := itmWeapon;
    itemMaterial := matStone;
    useID := 9;
    glyph := chr(7);
    glyphColour := 'lightGrey';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    onMap := True;
    discovered := False;
  end;
end;

procedure useItem;
begin
  ui.displayMessage('You can''t find a use for a rock.');
end;

end.

