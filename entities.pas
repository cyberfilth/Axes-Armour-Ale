(* NPC stats and setup *)

unit entities;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  Graphics, map, globalutils, ui,
  (* Import the NPC's *)
  cave_rat;

type
  (* Store information about NPC's *)
  Creature = record
    (* Unique ID *)
    npcID: smallint;
    (* Creature type *)
    race: shortstring;
    (* Description of creature *)
    description: string;
    (* health and position on game map *)
    currentHP, maxHP, attack, defense, posX, posY: smallint;
    (* Character used to represent NPC on game map *)
    glyph: char;
    (* Colour of NPC *)
    glyphColour: TColor;
    (* Is the NPC in the players FoV *)
    inView: boolean;
    (* First time the player discovers the NPC *)
    discovered: boolean;
    (* Has the NPC been killed, to be removed at end of game loop *)
    isDead: boolean;
  end;

var
  entityList: array of Creature;
  npcAmount, listLength: smallint;

(* Generate list of creatures on the map *)
procedure spawnNPCs;
(* Move NPC's *)
procedure moveNPC(id, newX, newY: smallint);

implementation

procedure spawnNPCs;
var
  i, p, r: smallint;
begin
  // get number of NPCs
  npcAmount := (globalutils.currentDgnTotalRooms - 2) div 2;
  // initialise array, 1 based
  SetLength(entityList, 1);
  p := 2; // used to space out NPC location
  // place the NPCs
  for i := 1 to npcAmount do
  begin
    // randomly select a monster type
    r := globalutils.randomRange(0, 1);
    if r = 1 then
      cave_rat.createCaveRat(i, globalutils.currentDgncentreList[p + 2].x,
        globalutils.currentDgncentreList[p + 2].y);
    if r = 0 then
      cave_rat.createCaveRat(i, globalutils.currentDgncentreList[p + 2].x,
        globalutils.currentDgncentreList[p + 2].y);
    Inc(p);
  end;
end;

procedure moveNPC(id, newX, newY: smallint);
begin
  (* delete NPC at old position *)
  if (entityList[id].inView = True) then
    map.drawTile(entityList[id].posX, entityList[id].posY, 1);
  (* mark tile as unoccupied *)
  map.unoccupy(entityList[id].posX, entityList[id].posY);
  (* update new position *)
  entityList[id].posX := newX;
  entityList[id].posY := newY;
  (* mark tile as occupied *)
  map.occupy(newX, newY);
  (* Check if NPC in players FoV *)
  if (map.canSee(newX, newY) = True) then
  begin
    if (entityList[id].discovered = False) then
    begin
      ui.displayMessage('You see ' + entityList[id].description);
      entityList[id].discovered := True;
    end;
    (* redraw NPC *)
    entityList[id].inView := True;
    drawNPCtoBuffer(entityList[id].posX, entityList[id].posY, entityList[id].glyphColour, entityList[id].glyph);
  end
  else
    entityList[id].inView := False;
end;

end.
