(* Organises the current level into an array together with helper functions *)

unit map;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, globalUtils, universe, ui, file_handling, player_stats;

type
  (* Tiles that make up the game world *)
  tile = record
    (* Unique tile ID *)
    id: smallint;
    (* Does the tile block movement *)
    Blocks: boolean;
    (* Is the tile visible *)
    Visible: boolean;
    (* Is the tile occupied *)
    Occupied: boolean;
    (* Has the tile been discovered already *)
    Discovered: boolean;
    (* Character used to represent the tile *)
    Glyph: shortstring;
  end;

type
  (* Tiles that make up the game world *)
  displayTile = record
    (* Character used to represent the tile *)
    Glyph: shortstring;
    (* Colour of the tile *)
    GlyphColour: shortstring;
  end;

var
  mapType: dungeonTerrain;
  (* Game map array *)
  maparea: array[1..MAXROWS, 1..MAXCOLUMNS] of tile;
  (* The map that the camera uses *)
  mapDisplay: array[1..MAXROWS, 1..MAXCOLUMNS] of displayTile;
  (* ROWS and COLUMNS used in loops *)
  r, c: smallint;
  (* Player starting position *)
  startX, startY: smallint;

(* Occupy tile *)
procedure occupy(x, y: smallint);
(* Unoccupy tile *)
procedure unoccupy(x, y: smallint);
(* Check if a map tile is occupied *)
function isOccupied(checkX, checkY: smallint): boolean;
(* Check if the coordinates are within the bounds of the gamemap *)
function withinBounds(x, y: smallint): boolean;
(* Check if the direction to move to is valid *)
function canMove(checkX, checkY: smallint): boolean;
(* Check if an object is in players FoV *)
function canSee(checkX, checkY: smallint): boolean;
(* Check if player is on a tile *)
function hasPlayer(checkX, checkY: smallint): boolean;
(* Go up stairs *)
procedure ascendStairs;
(* Go down stairs *)
procedure descendStairs;
(* Place a tile on the map *)
procedure drawTile(c, r: smallint; hiDef: byte);
(* Display explored sections of map when reloading game *)
procedure loadDisplayedMap;
(* Setup the current level *)
procedure setupMap;

implementation

uses
  entities, items, fov, main;

procedure occupy(x, y: smallint);
begin
  maparea[y][x].Occupied := True;
end;

procedure unoccupy(x, y: smallint);
begin
  maparea[y][x].Occupied := False;
end;

function isOccupied(checkX, checkY: smallint): boolean;
begin
  if (maparea[checkY][checkX].Occupied = True) then
    Result := True
  else
    Result := False;
end;

function withinBounds(x, y: smallint): boolean;
begin
  if (x >= 1) and (x <= globalutils.MAXCOLUMNS) and (y >= 1) and
    (y <= globalutils.MAXROWS) then
    Result := True
  else
    Result := False;
end;

function canMove(checkX, checkY: smallint): boolean;
begin
  if (withinBounds(checkX, checkY) = True) and
    (maparea[checkY][checkX].Blocks = False) then
    Result := True
  else
    Result := False;
end;

function canSee(checkX, checkY: smallint): boolean;
begin
  if (maparea[checkY][checkX].Visible = True) then
    Result := True
  else
    Result := False;
end;

function hasPlayer(checkX, checkY: smallint): boolean;
begin
  if (entities.entityList[0].posX = checkX) and
    (entities.entityList[0].posY = checkY) then
    Result := True
  else
    Result := False;
end;

procedure ascendStairs;
begin
  (* Check if the player is standing on up staircase *)
  if (maparea[entities.entityList[0].posY][entities.entityList[0].posX].Glyph =
    '<') then
  begin
    (* Check the player can leave the dungeon *)
    if (universe.currentDepth = 1) then
    begin
      if (player_stats.canExitDungeon = True) then
      begin
        ui.displayMessage('You leave the smugglers cave!');
        main.WinningScreen;
      end
      else if (player_stats.canExitDungeon = False) then
        ui.displayMessage('The exit is locked...');
    end
    else  (* If not the first floor *)
    begin
      (* Ascend the stairs *)
      { Write current level to disk }
      file_handling.saveDungeonLevel;
      (* Clear list of items *)
      items.initialiseItems;
      (* Clear list of NPC's *)
      entities.newFloorNPCs;
      { Read next level from disk }
      file_handling.loadDungeonLevel(universe.currentDepth - 1);
      { Show already discovered tiles }
      for r := 1 to globalUtils.MAXROWS do
      begin
        for c := 1 to globalUtils.MAXCOLUMNS do
        begin
          drawTile(c, r, 0);
        end;
      end;
      { Display current floor }
      ui.displayMessage('You ascend to level ' + IntToStr(universe.currentDepth));
      { Display Field of View }
      fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
        entities.entityList[0].visionRange, 1);
    end;
  end
  else
    (* Cannot ascend *)
    ui.displayMessage('There are no stairs going up here ');
end;

procedure descendStairs;
begin
  (* Check if the player is standing on up staircase *)
  if (maparea[entities.entityList[0].posY][entities.entityList[0].posX].Glyph = '>') then
  begin
    (* Descend the stairs *)
    { Write current level to disk }
    file_handling.saveDungeonLevel;
    (* Clear list of items *)
    items.initialiseItems;
    (* Clear list of NPC's *)
    entities.newFloorNPCs;
    { Read next level from disk }
    file_handling.loadDungeonLevel(universe.currentDepth + 1);
    { Show already discovered tiles }
    for r := 1 to globalUtils.MAXROWS do
    begin
      for c := 1 to globalUtils.MAXCOLUMNS do
      begin
        drawTile(c, r, 0);
      end;
    end;
    { Display current floor }
    ui.displayMessage('You descend to level ' + IntToStr(universe.currentDepth));
    { Display Field of View }
    fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
      entities.entityList[0].visionRange, 1);
  end
  else
    (* Cannot descend *)
    ui.displayMessage('There are no stairs going down here ');
end;

procedure drawTile(c, r: smallint; hiDef: byte);
begin
  (* Draw black space if tile is not visible *)
  if (maparea[r][c].Visible = False) and (maparea[r][c].Discovered = False) then
  begin
    mapDisplay[r][c].Glyph := ' ';
    mapDisplay[r][c].GlyphColour := 'black';
  end
  else
  (* Draw cave tiles *)
  if (mapType = tCave) then
  begin
    case maparea[r][c].glyph of
      '.': { Cave Floor }
      begin
        if (hiDef = 1) then
        begin
          mapDisplay[r][c].GlyphColour := 'lightGrey';
          mapDisplay[r][c].Glyph := '.';
        end
        else
        begin
          mapDisplay[r][c].GlyphColour := 'darkGrey';
          mapDisplay[r][c].Glyph := '.';
        end;
      end;
      '<': { Upstairs }
      begin
        if (hiDef = 1) then
        begin
          mapDisplay[r][c].GlyphColour := 'white';
          mapDisplay[r][c].Glyph := '<';
        end
        else
        begin
          mapDisplay[r][c].GlyphColour := 'grey';
          mapDisplay[r][c].Glyph := '<';
        end;
      end;
      '>': { Downstairs }
      begin
        if (hiDef = 1) then
        begin
          mapDisplay[r][c].GlyphColour := 'white';
          mapDisplay[r][c].Glyph := '>';
        end
        else
        begin
          mapDisplay[r][c].GlyphColour := 'grey';
          mapDisplay[r][c].Glyph := '>';
        end;
      end;
      '*': { Cave Wall }
      begin
        if (hiDef = 1) then
        begin
          mapDisplay[r][c].GlyphColour := 'brown';
          mapDisplay[r][c].Glyph := Chr(177);
        end
        else
        begin
          mapDisplay[r][c].GlyphColour := 'brown';
          mapDisplay[r][c].Glyph := Chr(176);
        end;
      end;
    end;
  end;
end;

procedure loadDisplayedMap;
begin
  for r := 1 to globalUtils.MAXROWS do
  begin
    for c := 1 to globalUtils.MAXCOLUMNS do
    begin
      drawTile(c, r, 0);
    end;
  end;
end;

procedure setupMap;
var
  (* give each tile a unique ID number *)
  id_int: smallint;
begin
  r := 1;
  c := 1;
  id_int := 0;
  (* set up the dungeon tiles *)
  for r := 1 to globalUtils.MAXROWS do
  begin
    for c := 1 to globalUtils.MAXCOLUMNS do
    begin
      Inc(id_int);
      with maparea[r][c] do
      begin
        id := id_int;
        Blocks := True;
        Visible := False;
        Discovered := False;
        Occupied := False;
        Glyph := universe.currentDungeon[r][c];
      end;
      if (universe.currentDungeon[r][c] = '.') or { floor tile }
        (universe.currentDungeon[r][c] = '<') or { Upstairs tile }
        (universe.currentDungeon[r][c] = '>') then { Downstairs tile }
        maparea[r][c].Blocks := False;
      drawTile(c, r, 1);
    end;
  end;
end;

end.
