(* A Rock - simple item *)
unit rock;

{$mode objfpc}{$H+}

interface

(* Create a rock *)
procedure createRock(uniqueid, itmx, itmy: smallint);

implementation

uses
  Graphics, items;

procedure createRock(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
    itemName := 'rock';
    glyph := '*';
    glyphColour := clYellow;
    inView := False;
    posX := itmx;
    posY := itmy;
    onMap := True;
    discovered := False;
  end;
end;

end.

