(* A trap that creates more webs when triggered *)

unit web_trap;

{$mode objfpc}{$H+}

interface

uses
  Sysutils, animation;

(* Create a web *)
procedure createWebTrap(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;
(* Triggered when the web has been stepped on *)
procedure triggered(id: smallint);

implementation

uses
  items, ui, map, entities, globalUtils;

procedure createWebTrap(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'web';
    itemDescription := 'sticky spiderweb';
    itemArticle := 'a';
    itemType := itmTrap;
    itemMaterial := matFlammable;
    useID := 15;
    glyph := '/';
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
  ui.displayMessage('You can''t find a use for a web.');
end;

procedure triggered(id: smallint);
var
  target: smallint;
begin
  (* Check if the web has been stepped on *)
  if (map.isOccupied(itemList[id].posX, itemList[id].posY) = True) then
  begin
    target := entities.getCreatureID(itemList[id].posX, itemList[id].posY);
    (* Check if it's the Player *)
    if (target = 0) then
    begin
      (* remove the trap *)
      itemList[id].itemType := itmEmptySlot;
      itemList[id].inView := False;
      itemList[id].onMap := False;
      (* spawn more webs in the area *)
      animation.spinWebs;
    (* End of Player-specific code *)
    end
    else;
    (* NPC (not a bug) gets stuck in the web *)

  end;
end;

end.

