(* Treasure *)

unit gold_pieces;

{$mode fpc}{$H+}

interface

uses
  sysutils;

(* Create Gpld *)
procedure createGP(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;

implementation

uses
  items, ui, globalUtils, player_stats;

procedure createGP(itmx, itmy: smallint);
var
  amount: smallint;
begin
  amount := randomRange(0, 5) + player_stats.playerLevel;
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := High(itemList);
    itemName := 'Gold';
    if (amount = 1) then
      itemDescription := IntToStr(amount) + ' gold piece'
    else
      itemDescription := IntToStr(amount) + ' gold pieces';
    itemArticle := 'some';
    itemType := itmTreasure;
    itemMaterial := matGold;
    useID := 22;
    glyph := '$';
    glyphColour := 'yellow';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := amount;
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
  ui.displayMessage('You pick up the gold.');
end;

end.
