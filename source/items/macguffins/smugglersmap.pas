(* First quest MacGuffin, the smugglers map *)

unit smugglersMap;

{$mode fpc}{$H+}

interface

uses SysUtils, player_stats, dlgInfo, video;

(* Create the map *)
procedure createSmugglersMap(itmx, itmy: smallint);
(* Collect quest item *)
procedure obtainMap;

implementation

uses
  items, ui;

procedure createSmugglersMap(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Smugglers Map';
    itemDescription := 'The map you''ve been searching for';
    itemArticle := 'the';
    itemType := itmQuest;
    itemMaterial := matPaper;
    useID := 7;
    glyph := '?';
    glyphColour := 'white';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    buy := 0;
    sell := 0;
    onMap := True;
    throwable := False;
    throwDamage := 0;
    dice := 0;
    adds := 0;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure obtainMap;
begin
  dlgInfo.dialogType := dlgFoundSMap;
  ui.displayMessage('now you can leave the cave');
  ui.displayMessage('You have found the map');
  player_stats.canExitDungeon := True;
end;

end.

