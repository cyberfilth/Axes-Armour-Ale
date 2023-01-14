(* A trap that creates more webs when triggered *)

unit web_trap;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, animation, web;

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
    buy := 0;
    sell := 0;
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
  target, pX, pY: smallint;
  opponent: shortstring;
begin
  pX := 0;
  pY := 0;
  (* Check if the web has been stepped on *)
  if (map.isOccupied(itemList[id].posX, itemList[id].posY) = True) then
  begin
    target := entities.getCreatureID(itemList[id].posX, itemList[id].posY);
    (* Check if it's the Player *)
    if (target = 0) then
    begin
      (* remove the trap *)
      itemList[id].itemType := itmEmptySlot;
      itemList[id].glyph := '.';
      itemList[id].inView := False;
      itemList[id].onMap := False;
      (* spawn more webs in the area *)
      animation.spinWebs;
      (* End of Player-specific code *)
    end
    else
    (* NPC (not a bug) gets stuck in the web *)
    if (entityList[target].faction <> bugFaction) and
      (entityList[target].inView = True) then
    begin
      (* remove the trap *)
      itemList[id].itemType := itmEmptySlot;
      itemList[id].inView := False;
      itemList[id].onMap := False;
      (* Get NPC coordinates *)
      pX := entityList[target].posX;
      pY := entityList[target].posY;
      (* Place webs to N, E, S & W of entity *)
      if (map.canMove(pX, pY - 1) = True) and (map.maparea[pY - 1, pX].Glyph <> '>') and
        (map.maparea[pY - 1, pX].Glyph <> '<') then
      begin
        Inc(npcAmount); { N }
        web.createWeb(npcAmount, pX, pY - 1);
      end;
      if (map.canMove(pX + 1, pY) = True) and (map.maparea[pY, pX + 1].Glyph <> '>') and
        (map.maparea[pY, pX + 1].Glyph <> '<') then
      begin
        Inc(npcAmount); { E }
        web.createWeb(npcAmount, pX + 1, pY);
      end;
      if (map.canMove(pX, pY + 1) = True) and (map.maparea[pY + 1, pX].Glyph <> '>') and
        (map.maparea[pY + 1, pX].Glyph <> '<') then
      begin
        Inc(npcAmount); { S }
        web.createWeb(npcAmount, pX, pY + 1);
      end;
      if (map.canMove(pX - 1, pY) = True) and (map.maparea[pY, pX - 1].Glyph <> '>') and
        (map.maparea[pY, pX - 1].Glyph <> '<') then
      begin
        Inc(npcAmount); { W }
        web.createWeb(npcAmount, pX - 1, pY);
      end;
      opponent := entities.entityList[target].race;
      if (entities.entityList[target].article = True) then
        opponent := 'the ' + opponent;
      ui.writeBufferedMessages;
      ui.displayMessage('Spider webs spring up around ' + opponent);
    end;
  end;
end;

end.
