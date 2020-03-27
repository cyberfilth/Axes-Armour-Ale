(* Organises the game world in an array and calculates the players FoV *)

unit map;

{$mode objfpc}{$H+}

interface

uses
  globalutils, Graphics, LResources;

const
  (* Width of tiles is used as a multiplier in placing tiles *)
  tileSize = 10;
  (* File path to image folder *)
  imagesFolder = 'images/dungeon/ascii/';

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
    Glyph: char;
  end;

var
  (* Game map array *)
  maparea: array[1..MAXROWS, 1..MAXCOLUMNS] of tile;
  r, c: smallint;
  (* Player starting position *)
  startX, startY: smallint;
  (* Graphical tiles *)
  caveWallHi, caveWallDef, caveFloorHi, caveFloorDef, blueDungeonWallHi,
  blueDungeonWallDef, blueDungeonFloorHi, blueDungeonFloorDef: TBitmap;

(* Load tile textures *)
procedure setupTiles;
(* Loop through tiles and set their ID, visibility etc *)
procedure setupMap;
(* Check if the direction to move to is valid *)
function canMove(checkX, checkY: smallint): boolean;
(* Check if an object is in players FoV *)
function canSee(checkX, checkY: smallint): boolean;
(* Occupy tile *)
procedure occupy(x, y: smallint);
(* Unoccupy tile *)
procedure unoccupy(x, y: smallint);
(* Check if a map tile is occupied *)
function isOccupied(checkX, checkY: smallint): boolean;
(* Check if player is on a tile *)
function hasPlayer(checkX, checkY: smallint): boolean;
(* Translate map coordinates to screen coordinates *)
function mapToScreen(pos: smallint): smallint;
(* Translate screen coordinates to map coordinates *)
function screenToMap(pos: smallint): smallint;
(* Place a tile on the map *)
procedure drawTile(c, r: smallint; hiDef: byte);

implementation

uses
  cave, grid_dungeon, player;

procedure setupTiles;
begin
  caveWallHi := TBitmap.Create;
  caveWallHi.LoadFromResourceName(HINSTANCE, 'CAVEWALLHI');
  caveWallDef := TBitmap.Create;
  caveWallDef.LoadFromResourceName(HINSTANCE, 'CAVEWALLDEF');
  caveFloorHi := TBitmap.Create;
  caveFloorHi.LoadFromResourceName(HINSTANCE, 'CAVEFLOORHI');
  caveFloorDef := TBitmap.Create;
  caveFloorDef.LoadFromResourceName(HINSTANCE, 'CAVEFLOORDEF');
  blueDungeonWallHi := TBitmap.Create;
  blueDungeonWallHi.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONWALLHI');
  blueDungeonWallDef := TBitmap.Create;
  blueDungeonWallDef.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONWALLDEF');
  blueDungeonFloorHi := TBitmap.Create;
  blueDungeonFloorHi.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONFLOORHI');
  blueDungeonFloorDef := TBitmap.Create;
  blueDungeonFloorDef.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONFLOORDEF');
end;

procedure setupMap;
var
  // give each tile a unique ID number
  id_int: smallint;
begin
  cave.generate;
  //grid_dungeon.generate;
  id_int := 0;
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      Inc(id_int);
      with maparea[r][c] do
      begin
        id := id_int;
        Blocks := True;
        Visible := False;
        Discovered := False;
        Occupied := False;
        Glyph := globalutils.dungeonArray[r][c];
      end;
      if (globalutils.dungeonArray[r][c] = '.') or
        (globalutils.dungeonArray[r][c] = ':') then
        maparea[r][c].Blocks := False;
    end;
  end;
end;

function canMove(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (maparea[checkY][checkX].Blocks) = False then
    Result := True;
end;

function canSee(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (maparea[checkY][checkX].Visible = True) then
    Result := True;
end;

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
  Result := False;
  if (maparea[checkY][checkX].Occupied = True) then
    Result := True;
end;

function hasPlayer(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (player.ThePlayer.posX = checkX) and (player.ThePlayer.posY = checkY) then
    Result := True;
end;

function mapToScreen(pos: smallint): smallint;
begin
  Result := pos * tileSize;
end;

function screenToMap(pos: smallint): smallint;
begin
  Result := pos div tileSize;
end;

procedure drawTile(c, r: smallint; hiDef: byte);
begin
  case maparea[r][c].glyph of
    '.': // Blue Dungeon Floor
    begin
      if (hiDef = 1) then
        drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonFloorHi)
      else
        drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonFloorDef);
    end;
    ':': // Cave Floor
    begin
      if (hiDef = 1) then
        drawToBuffer(mapToScreen(c), mapToScreen(r), caveFloorHi)
      else
        drawToBuffer(mapToScreen(c), mapToScreen(r), caveFloorDef);
    end;
    '#': // Blue Dungeon wall
    begin
      if (hiDef = 1) then
        drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonWallHi)
      else
        drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonWallDef);
    end;
    '*': // Cave wall
    begin
      if (hiDef = 1) then
        drawToBuffer(mapToScreen(c), mapToScreen(r), caveWallHi)
      else
        drawToBuffer(mapToScreen(c), mapToScreen(r), caveWallDef);
    end;
  end;
end;


end.
