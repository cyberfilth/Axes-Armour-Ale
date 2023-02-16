(* A dimly glowing pixie in a jar - Light source *)

unit pixie_jar_dim;

{$mode fpc}{$H+}

interface

(* Create a pixie jar *)
procedure createPixieJarDim(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui, globalUtils, map, player_stats, entities;

procedure createPixieJarDim(itmx, itmy: smallint);
var
  duration: smallint;
begin

  duration := randomRange(50, 75);
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := High(itemList);
    itemName := 'Pixie in a jar';
    itemDescription := 'dimly glowing source of light';
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
    value := 5;
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
  ui.displayMessage('You pick up the Pixie in the jar');
  if (entityList[0].visionRange < player_stats.maxVisionRange) then
     entityList[0].visionRange := player_stats.maxVisionRange;
  lightEquipped := True;
  map.loadDisplayedMap;
end;

end.
