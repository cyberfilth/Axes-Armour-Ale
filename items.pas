(* Items and objects in the game world *)
unit items;

{$mode objfpc}{$H+}

interface

uses
  Graphics, globalutils, rock;

type
  (* Store information about items *)
  Item = record
    (* Unique ID *)
    itemID: smallint;
    (* Item name *)
    itemName: shortstring;
    (* Position on game map *)
    posX, posY: smallint;
    (* Character used to represent item on game map *)
    glyph: char;
    (* Colour of character on screen *)
    glyphColour: TColor;
    (* Is the item in the players FoV *)
    inView: boolean;
    (* Is the item on the map *)
    onMap: boolean;
    (* Displays a message the first time item is seen *)
    discovered: boolean;
  end;

var
  itemList: array of Item;
  itemAmount, listLength: smallint;

(* Generate list of items on the map *)
procedure spawnItem;
(* Redraw all items *)
procedure redrawItems;

implementation

procedure spawnItem;
var
  i, p, r: smallint;
begin
  itemAmount := 1;
  // initialise array, 1 based
  SetLength(itemList, 1);
  p := 2; // used to space out item location
  // place the item
  for i := 1 to itemAmount do
  begin
    createRock(i, globalutils.currentDgncentreList[p + 2].x, globalutils.currentDgncentreList[p + 2].y);
  end;
end;

procedure redrawItems;
var
  i: smallint;
begin
  for i := 1 to itemAmount do
  begin
    if (itemList[i].inView = True) then
    begin
      drawNPCtoBuffer(itemList[i].posX, itemList[i].posY,
        itemList[i].glyphColour, itemList[i].glyph);
    end;
  end;
end;

end.

