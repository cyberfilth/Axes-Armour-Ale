(* A spore that poisons the player when triggered *)

unit poison_spore;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, video;

(* Create a spore *)
procedure createSpore(itmx, itmy: smallint);
(* Item cannot be equipped *)
procedure useItem;
(* Triggered when the spore has been stepped on *)
procedure triggered(id: smallint);

implementation

uses
  items, ui, map, entities, globalUtils;

procedure createSpore(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'spore';
    itemDescription := 'poisonous spore';
    itemArticle := 'a';
    itemType := itmTrap;
    itemMaterial := matFlammable;
    useID := 16;
    glyph := '*';
    glyphColour := 'green';
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
    discovered := True;
    Inc(indexID);
  end;
end;

procedure useItem;
begin
  ui.displayMessage('You can''t pick up a spore.');
end;

procedure triggered(id: smallint);
var
  target: smallint;
begin
  (* Check if the spore has been stepped on *)
  if (map.isOccupied(itemList[id].posX, itemList[id].posY) = True) then
  begin
    target := entities.getCreatureID(itemList[id].posX, itemList[id].posY);
    (* Check if it's the Player *)
    if (target = 0) then
    begin
      (* Inflict poison damage *)
      entityList[0].stsPoison := True;
      entityList[0].tmrPoison := 2;
      if (killer = 'empty') then
        killer := 'poisoned fungus spore';
      LockScreenUpdate;
      ui.displayMessage('You step on a poisoned spore');
      (* Update UI *)
      ui.displayStatusEffect(1, 'poison');
      ui.poisonStatusSet := True;
      entityList[0].glyphColour := 'green';
      UnlockScreenUpdate;
      UpdateScreen(False);
    end
    (* If an NPC steps on the spore *)
    else
    begin
      entityList[id].stsPoison := True;
      entityList[id].tmrPoison := 2;
    end;
  end;
end;

end.
