(* Helper functions when debugging, printing out maps, topping up HP, etc *)

unit debuggingFunctions;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, entities, player_stats, map, items, globalUtils, logging;

(* Increases HP and light timer, to aid exploration *)
procedure topUpStats;
(* Show all entities on the screen *)
procedure showEntitiesItems;
(* Prints the map to a text file *)
procedure dumpMap;

implementation

uses
  main;

procedure topUpStats;
begin
  Inc(entityList[0].maxHP, 100);
  entityList[0].currentHP := entityList[0].maxHP;
  Inc(player_stats.lightCounter, 500);
  showEntitiesItems
end;

procedure showEntitiesItems;
var
  i: smallint;
  stateValue: shortstring;
begin
  logAction('');
  logAction('-- showEntitiesItems --');
  (* Highlight entities *)
  for i := 0 to High(entityList) do
  begin
    logAction(IntToStr(i) + ': ' + entityList[i].race + ' is at ' + IntToStr(entityList[i].posX) + ', ' + IntToStr(entityList[i].posY));
    map.mapDisplay[entityList[i].posY, entityList[i].posX].GlyphColour := 'white';
    map.mapDisplay[entityList[i].posY, entityList[i].posX].Glyph := entityList[i].glyph;
  end;
  (* Highlight items *)
  for i := 0 to High(itemList) do
  begin
    logAction(IntToStr(i) + ': ' + itemList[i].itemName + ' is at ' + IntToStr(itemList[i].posX) + ', ' + IntToStr(itemList[i].posY));
    map.mapDisplay[itemList[i].posY, itemList[i].posX].GlyphColour := 'yellow';
    map.mapDisplay[itemList[i].posY, itemList[i].posX].Glyph := 'X';
  end;
  logAction('');
  dumpMap;
  (* Write out the game state *)
  WriteStr(stateValue, main.gameState);
  logAction('gameState: ' + stateValue);
end;

procedure dumpMap;
var
  filename: shortstring;
  myfile: Text;
begin
  filename := globalUtils.saveDirectory + PathDelim + 'map.txt';
  AssignFile(myfile, filename);
  rewrite(myfile);
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      Write(myfile, map.maparea[r][c].Glyph);
    end;
    Write(myfile, sLineBreak);
  end;
  closeFile(myfile);
end;

end.
