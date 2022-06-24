(* A glowing pixie in a jar - Light source *)

unit pixie_jar;

{$mode fpc}{$H+}

interface

(* Create a pixie jar *)
procedure createPixieJar;
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui, globalUtils, map, player_stats, entities;

procedure createPixieJar;
var
  duration, r, c: smallint;
begin
  (* Choose random location on the map *)
  repeat
    r := globalutils.randomRange(3, (MAXROWS - 3));
    c := globalutils.randomRange(3, (MAXCOLUMNS - 3));
    (* choose a location that is not a wall or occupied *)
  until (maparea[r][c].Blocks = False) and (maparea[r][c].Occupied = False);

  duration := randomRange(150, 160);
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := High(itemList);
    itemName := 'Pixie in a jar';
    itemDescription := 'glowing source of light';
    itemArticle := 'a';
    itemType := itmLightSource;
    itemMaterial := matGlass;
    useID := 13;
    glyph := chr(232);
    glyphColour := 'yellow';
    inView := False;
    posX := c;
    posY := r;
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
  ui.displayMessage('You pick up the Pixie in the jar.');
  if (entityList[0].visionRange < player_stats.maxVisionRange) then
     entityList[0].visionRange := player_stats.maxVisionRange;
  lightEquipped := True;
  map.loadDisplayedMap;
end;

end.

