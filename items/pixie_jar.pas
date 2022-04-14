(* A glowing pixie in a jar - Light source *)

unit pixie_jar;

{$mode fpc}{$H+}

interface

(* Create a pixie jar *)
procedure createPixieJar(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui, globalUtils;

procedure createPixieJar(itmx, itmy: smallint);
var
  duration: smallint;
begin
  duration := randomRange(150, 160);
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Pixie in a jar';
    itemDescription := 'glowing source of light';
    itemArticle := 'a';
    itemType := itmLightSource;
    itemMaterial := matGlass;
    useID := 13;
    glyph := chr(232);
    glyphColour := 'yellow';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := duration;
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
  ui.displayMessage('You can''t find a use for the jar.');
end;

end.

