(* First quest MacGuffin, the smugglers map *)

unit smugglersMap;

{$mode fpc}{$H+}

interface

uses SysUtils, player_stats, dlgInfo, video;

(* Create the map *)
procedure createSmugglersMap(uniqueid, itmx, itmy: smallint);
(* Collect quest item *)
procedure obtainMap;

implementation

uses
  items, ui;

procedure createSmugglersMap(uniqueid, itmx, itmy: smallint);
begin
  items.listLength := length(items.itemList);
  SetLength(items.itemList, items.listLength + 1);
  with items.itemList[items.listLength] do
  begin
    itemID := uniqueid;
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
    onMap := True;
    discovered := False;
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

