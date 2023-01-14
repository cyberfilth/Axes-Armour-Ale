(* Parchment scroll that can increase a player stat *)

unit parchment;

{$mode fpc}{$H+}

interface

uses
  SysUtils, player_stats, dlgInfo, video, plot_gen, globalUtils, ui, entities;

(* Create the parchment *)
procedure createParchment(itmx, itmy: smallint);
(* Collect parchment *)
procedure collectParchment;

implementation

uses
  items;

procedure createParchment(itmx, itmy: smallint);
begin
  SetLength(itemList, length(itemList) + 1);
  with itemList[High(itemList)] do
  begin
    itemID := indexID;
    itemName := 'Parchment scroll';
    itemDescription := 'A scroll with an enchanted aura';
    itemArticle := 'a';
    itemType := itmQuest;
    itemMaterial := matPaper;
    useID := 19;
    glyph := ')';
    glyphColour := 'white';
    inView := False;
    posX := itmx;
    posY := itmy;
    NumberOfUses := 5;
    buy := 10;
    sell := 5;
    onMap := True;
    throwable := False;
    throwDamage := 0;
    dice := 0;
    adds := 0;
    discovered := False;
    Inc(indexID);
  end;
end;

procedure collectParchment;
var
  attribute: smallint;
begin
  (* choose the type of parchment found *)
  attribute := randomRange(0, 2);
  case attribute of
    0: dlgInfo.parchmentType := 'DEX';
    1: dlgInfo.parchmentType := 'ATT';
    2: dlgInfo.parchmentType := 'DEF';
  end;
  dlgInfo.dialogType := dlgParchment;
  case parchmentType of
    'DEX':
      begin
        Inc(player_stats.dexterity);
        ui.updateDexterity;
        ui.displayMessage('Your Dexterity increases.');
      end;
    'ATT':
      begin
        Inc(entityList[0].attack);
        ui.updateAttack;
        ui.displayMessage('Your Attack strength increases.');
      end;
    'DEF':
      begin
        Inc(entityList[0].defence);
        ui.updateDefence;
        ui.displayMessage('Your Defence ability increases.');
      end;
  end;
end;

end.

