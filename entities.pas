(* NPC stats and setup *)

unit entities;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  Graphics, map, globalutils, ui, items,
  (* Import the NPC's *)
  cave_rat, hyena;

type
  (* Store information about NPC's *)

  { Creature }

  Creature = record
    (* Unique ID *)
    npcID: smallint;
    (* Creature type *)
    race: shortstring;
    (* Description of creature *)
    description: string;
    (* health and position on game map *)
    currentHP, maxHP, attack, defense, posX, posY, xpReward, visionRange: smallint;
    (* Character used to represent NPC on game map *)
    glyph: char;
    (* Size of NPC *)
    NPCsize: smallint;
    (* Number of turns the entity will track the player when they're out of sight *)
    trackingTurns: smallint;
    (* Count of turns the entity will keep tracking the player when they're out of sight *)
    moveCount: smallint;
    (* Is the NPC in the players FoV *)
    inView: boolean;
    (* First time the player discovers the NPC *)
    discovered: boolean;
    (* Has the NPC been killed, to be removed at end of game loop *)
    isDead: boolean;
    (* Whether a special ability has been activated *)
    abilityTriggered: boolean;
    (* The procedure that allows each NPC to take a turn *)
    procedure entityTakeTurn(i: smallint);
  end;

var
  entityList: array of Creature;
  npcAmount, listLength: smallint;
  caveRatGlyph, hyenaGlyph: TBitmap;

(* Load entity textures *)
procedure setupEntities;
(* Generate list of creatures on the map *)
procedure spawnNPCs;
(* Draw entity on screen *)
procedure drawEntity(c, r: smallint; glyph: char);
(* Update NPCs X, Y coordinates *)
procedure moveNPC(id, newX, newY: smallint);
(* Redraw all NPC's *)
procedure redrawNPC;
(* Get creature details at coordinates *)
function getCreatureID(x, y: smallint): smallint;
(* Get creature name at coordinates *)
function getCreatureName(x, y: smallint): shortstring;
(* Call Creatures.takeTurn procedure *)
procedure NPCgameLoop;

implementation

procedure setupEntities;
begin
  caveRatGlyph := TBitmap.Create;
  caveRatGlyph.LoadFromResourceName(HINSTANCE, 'R_ORANGE');
  hyenaGlyph := TBitmap.Create;
  hyenaGlyph.LoadFromResourceName(HINSTANCE, 'H_RED');
end;

procedure spawnNPCs;
var
  i, p, NPCtype: smallint;
begin
  (* Set the number of NPC's *)
  npcAmount := (globalutils.currentDgnTotalRooms - 2) div 2;
  (*  initialise array, 1 based *)
  SetLength(entityList, 1);
  p := 2; // used to space out NPC location
  (* Create the NPCs *)
  for i := 1 to npcAmount do
  begin
    // randomly select a monster type
    NPCtype := globalutils.randomRange(0, 1);
    case NPCtype of
      0: // Hyena
        hyena.createHyena(i, globalutils.currentDgncentreList[p + 2].x,
          globalutils.currentDgncentreList[p + 2].y);
      1: // Cave rat
        cave_rat.createCaveRat(i, globalutils.currentDgncentreList[p + 2].x,
          globalutils.currentDgncentreList[p + 2].y);
    end;
    Inc(p);
  end;
end;

procedure drawEntity(c, r: smallint; glyph: char);
begin
  case glyph of
    'r': drawToBuffer(mapToScreen(c), mapToScreen(r), caveRatGlyph);
    'h': drawToBuffer(mapToScreen(c), mapToScreen(r), hyenaGlyph);
  end;
end;

procedure moveNPC(id, newX, newY: smallint);
var
  i: smallint;
begin
  (* delete NPC at old position *)
  (* First check if they are standing on an item *)
  for i := 1 to items.itemAmount do
    if (items.itemList[i].posX = entityList[id].posX) and
      (items.itemList[i].posX = entityList[id].posX) then
      items.redrawItems
    (* if not, redraw the floor tile *)
    else
    if (entityList[id].inView = True) then
      map.drawTile(entityList[id].posX, entityList[id].posY, 1);
  (* mark tile as unoccupied *)
  map.unoccupy(entityList[id].posX, entityList[id].posY);
  (* update new position *)
  if (map.isOccupied(newX, newY) = True) and (getCreatureID(newX, newY) <> id) then
  begin
    newX := entityList[id].posX;
    newY := entityList[id].posY;
  end;
  entityList[id].posX := newX;
  entityList[id].posY := newY;
  (* mark tile as occupied *)
  map.occupy(newX, newY);
  (* Check if NPC in players FoV *)
  if (map.canSee(newX, newY) = True) then
  begin
    entityList[id].inView := True;
    if (entityList[id].discovered = False) then
    begin
      ui.displayMessage('You see ' + entityList[id].description);
      entityList[id].discovered := True;
    end;
  end
  else
    entityList[id].inView := False;
end;

procedure redrawNPC;
var
  i: smallint;
begin
  for i := 1 to npcAmount do
  begin
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      drawEntity(entityList[i].posX, entityList[i].posY, entityList[i].glyph);
    end;
  end;
end;

function getCreatureID(x, y: smallint): smallint;
var
  i: smallint;
begin
  Result := 0; // initialise variable
  for i := 1 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := i;
  end;
end;

function getCreatureName(x, y: smallint): shortstring;
var
  i: smallint;
begin
  for i := 1 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := entityList[i].race;
  end;
end;

procedure NPCgameLoop;
var
  i: smallint;
begin
  for i := 1 to npcAmount do
    if (entityList[i].isDead = False) then
      entityList[i].entityTakeTurn(i);
end;

{ Creature }

procedure Creature.entityTakeTurn(i: smallint);
begin
  if (entityList[i].race = 'cave rat') then
    cave_rat.takeTurn(i, entities.entityList[i].posX, entities.entityList[i].posY)
  else if (entityList[i].race = 'blood hyena') then
    hyena.takeTurn(i, entities.entityList[i].posX, entities.entityList[i].posY);
end;

end.
