(* Organises the game world in an array and calculates the players FoV *)

unit map;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  globalutils, Graphics, LResources;

const
  (* Width/Height of tiles is used as a multiplier in placing tiles *)
  tileSize = 10;

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
  (* Type of map: 0 = cave tunnels, 1 = blue grid-based dungeon, 2 = cavern, 3 = Bitmask dungeon *)
  mapType: smallint;
  (* Game map array *)
  maparea: array[1..MAXROWS, 1..MAXCOLUMNS] of tile;
  r, c: smallint;
  (* Player starting position *)
  startX, startY: smallint;
  (* Graphical tiles *)
  { TODO : Move the code responsible for loading tiles into each specific unit. Cave tiles are loaded from the cave generator etc... }
  caveWallHi, caveWallDef, caveFloorHi, caveFloorDef, blueDungeonWallHi,
  blueDungeonWallDef, blueDungeonFloorHi, blueDungeonFloorDef,
  caveWall2Def, caveWall2Hi, caveWall3Def, caveWall3Hi, upStairs,
  downStairs, bmDungeon3Hi, bmDungeon3Def, bmDungeon5Hi, bmDungeon5Def,
  bmDungeon6Hi, bmDungeon6Def, bmDungeon7Hi, bmDungeon7Def, bmDungeon9Hi,
  bmDungeon9Def, bmDungeon10Hi, bmDungeon10Def, bmDungeon11Hi,
  bmDungeon11Def, bmDungeon12Hi, bmDungeon12Def, bmDungeon13Hi,
  bmDungeon13Def, bmDungeon14Hi, bmDungeon14Def, bmDungeonBLHi,
  bmDungeonBLDef, bmDungeonBRHi, bmDungeonBRDef, bmDungeonTLHi,
  bmDungeonTLDef, bmDungeonTRHi, bmDungeonTRDef, greyFloorHi, greyFloorDef,
  blankTile, cave1Def, cave1Hi, cave4Def, cave4Hi, cave5Def, cave5Hi,
  cave7Def, cave7Hi, cave16Def, cave16Hi, cave17Def, cave17Hi, cave20Def,
  cave20Hi, cave21Def, cave21Hi, cave23Def, cave23Hi, cave28Def,
  cave28Hi, cave29Def, cave29Hi, cave31Def, cave31Hi, cave64Def,
  cave64Hi, cave65Def, cave65Hi, cave68Def, cave68Hi, cave69Def,
  cave69Hi, cave71Def, cave71Hi, cave80Def, cave80Hi, cave81Def,
  cave81Hi, cave84Def, cave84Hi, cave85Def, cave85Hi, cave87Def,
  cave87Hi, cave92Def, cave92Hi, cave93Def, cave93Hi, cave95Def,
  cave95Hi, cave112Def, cave112Hi, cave113Def, cave113Hi, cave116Def,
  cave116Hi, cave117Def, cave117Hi, cave119Def, cave119Hi, cave124Def,
  cave124Hi, cave125Def, cave125Hi, cave127Def, cave127Hi, cave193Def,
  cave193Hi, cave197Def, cave197Hi, cave199Def, cave199Hi, cave209Def,
  cave209Hi, cave213Def, cave213Hi, cave215Def, cave215Hi, cave221Def,
  cave221Hi, cave223Def, cave223Hi, cave241Def, cave241Hi, cave245Def,
  cave245Hi, cave247Def, cave247Hi, cave253Def, cave253Hi, cave255Def,
  cave255Hi: TBitmap;


(* Load tile textures *)
procedure setupTiles;
(* Loop through tiles and set their ID, visibility etc *)
procedure setupMap;
(* Load map from saved game *)
procedure loadMap;
(* Check if the coordinates are within the bounds of the gamemap *)
function withinBounds(x, y: smallint): boolean;
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
  cave, grid_dungeon, cavern, bitmask_dungeon, entities;

procedure setupTiles;
begin
  // Cave tiles
  cave1Hi := TBitmap.Create;
  cave1Hi.LoadFromResourceName(HINSTANCE, 'CAVE-1-Hi');
  cave1Def := TBitmap.Create;
  cave1Def.LoadFromResourceName(HINSTANCE, 'CAVE-1-DEF');
  cave4Hi := TBitmap.Create;
  cave4Hi.LoadFromResourceName(HINSTANCE, 'CAVE-4-Hi');
  cave4Def := TBitmap.Create;
  cave4Def.LoadFromResourceName(HINSTANCE, 'CAVE-4-DEF');
  cave5Hi := TBitmap.Create;
  cave5Hi.LoadFromResourceName(HINSTANCE, 'CAVE-5-Hi');
  cave5Def := TBitmap.Create;
  cave5Def.LoadFromResourceName(HINSTANCE, 'CAVE-5-DEF');
  cave7Hi := TBitmap.Create;
  cave7Hi.LoadFromResourceName(HINSTANCE, 'CAVE-7-Hi');
  cave7Def := TBitmap.Create;
  cave7Def.LoadFromResourceName(HINSTANCE, 'CAVE-7-DEF');
  cave16Hi := TBitmap.Create;
  cave16Hi.LoadFromResourceName(HINSTANCE, 'CAVE-16-Hi');
  cave16Def := TBitmap.Create;
  cave16Def.LoadFromResourceName(HINSTANCE, 'CAVE-16-DEF');
  cave17Hi := TBitmap.Create;
  cave17Hi.LoadFromResourceName(HINSTANCE, 'CAVE-17-Hi');
  cave17Def := TBitmap.Create;
  cave17Def.LoadFromResourceName(HINSTANCE, 'CAVE-17-DEF');
  cave20Hi := TBitmap.Create;
  cave20Hi.LoadFromResourceName(HINSTANCE, 'CAVE-20-Hi');
  cave20Def := TBitmap.Create;
  cave20Def.LoadFromResourceName(HINSTANCE, 'CAVE-20-DEF');
  cave21Hi := TBitmap.Create;
  cave21Hi.LoadFromResourceName(HINSTANCE, 'CAVE-21-Hi');
  cave21Def := TBitmap.Create;
  cave21Def.LoadFromResourceName(HINSTANCE, 'CAVE-21-DEF');
  cave23Hi := TBitmap.Create;
  cave23Hi.LoadFromResourceName(HINSTANCE, 'CAVE-23-Hi');
  cave23Def := TBitmap.Create;
  cave23Def.LoadFromResourceName(HINSTANCE, 'CAVE-23-DEF');
  cave28Hi := TBitmap.Create;
  cave28Hi.LoadFromResourceName(HINSTANCE, 'CAVE-28-Hi');
  cave28Def := TBitmap.Create;
  cave28Def.LoadFromResourceName(HINSTANCE, 'CAVE-28-DEF');
  cave29Hi := TBitmap.Create;
  cave29Hi.LoadFromResourceName(HINSTANCE, 'CAVE-29-Hi');
  cave29Def := TBitmap.Create;
  cave29Def.LoadFromResourceName(HINSTANCE, 'CAVE-29-DEF');
  cave31Hi := TBitmap.Create;
  cave31Hi.LoadFromResourceName(HINSTANCE, 'CAVE-31-Hi');
  cave31Def := TBitmap.Create;
  cave31Def.LoadFromResourceName(HINSTANCE, 'CAVE-31-DEF');
  cave64Hi := TBitmap.Create;
  cave64Hi.LoadFromResourceName(HINSTANCE, 'CAVE-64-Hi');
  cave64Def := TBitmap.Create;
  cave64Def.LoadFromResourceName(HINSTANCE, 'CAVE-64-DEF');
  cave65Hi := TBitmap.Create;
  cave65Hi.LoadFromResourceName(HINSTANCE, 'CAVE-65-Hi');
  cave65Def := TBitmap.Create;
  cave65Def.LoadFromResourceName(HINSTANCE, 'CAVE-65-DEF');
  cave68Hi := TBitmap.Create;
  cave68Hi.LoadFromResourceName(HINSTANCE, 'CAVE-68-Hi');
  cave68Def := TBitmap.Create;
  cave68Def.LoadFromResourceName(HINSTANCE, 'CAVE-68-DEF');
  cave69Hi := TBitmap.Create;
  cave69Hi.LoadFromResourceName(HINSTANCE, 'CAVE-69-Hi');
  cave69Def := TBitmap.Create;
  cave69Def.LoadFromResourceName(HINSTANCE, 'CAVE-69-DEF');
  cave71Hi := TBitmap.Create;
  cave71Hi.LoadFromResourceName(HINSTANCE, 'CAVE-71-Hi');
  cave71Def := TBitmap.Create;
  cave71Def.LoadFromResourceName(HINSTANCE, 'CAVE-71-DEF');
  cave80Hi := TBitmap.Create;
  cave80Hi.LoadFromResourceName(HINSTANCE, 'CAVE-80-Hi');
  cave80Def := TBitmap.Create;
  cave80Def.LoadFromResourceName(HINSTANCE, 'CAVE-80-DEF');
  cave81Hi := TBitmap.Create;
  cave81Hi.LoadFromResourceName(HINSTANCE, 'CAVE-81-Hi');
  cave81Def := TBitmap.Create;
  cave81Def.LoadFromResourceName(HINSTANCE, 'CAVE-81-DEF');
  cave84Hi := TBitmap.Create;
  cave84Hi.LoadFromResourceName(HINSTANCE, 'CAVE-84-Hi');
  cave84Def := TBitmap.Create;
  cave84Def.LoadFromResourceName(HINSTANCE, 'CAVE-84-DEF');
  cave85Hi := TBitmap.Create;
  cave85Hi.LoadFromResourceName(HINSTANCE, 'CAVE-85-Hi');
  cave85Def := TBitmap.Create;
  cave85Def.LoadFromResourceName(HINSTANCE, 'CAVE-85-DEF');
  cave87Hi := TBitmap.Create;
  cave87Hi.LoadFromResourceName(HINSTANCE, 'CAVE-87-Hi');
  cave87Def := TBitmap.Create;
  cave87Def.LoadFromResourceName(HINSTANCE, 'CAVE-87-DEF');
  cave92Hi := TBitmap.Create;
  cave92Hi.LoadFromResourceName(HINSTANCE, 'CAVE-92-Hi');
  cave92Def := TBitmap.Create;
  cave92Def.LoadFromResourceName(HINSTANCE, 'CAVE-92-DEF');
  cave93Hi := TBitmap.Create;
  cave93Hi.LoadFromResourceName(HINSTANCE, 'CAVE-93-Hi');
  cave93Def := TBitmap.Create;
  cave93Def.LoadFromResourceName(HINSTANCE, 'CAVE-93-DEF');
  cave95Hi := TBitmap.Create;
  cave95Hi.LoadFromResourceName(HINSTANCE, 'CAVE-95-Hi');
  cave95Def := TBitmap.Create;
  cave95Def.LoadFromResourceName(HINSTANCE, 'CAVE-95-DEF');
  cave112Hi := TBitmap.Create;
  cave112Hi.LoadFromResourceName(HINSTANCE, 'CAVE-112-Hi');
  cave112Def := TBitmap.Create;
  cave112Def.LoadFromResourceName(HINSTANCE, 'CAVE-112-DEF');
  cave113Hi := TBitmap.Create;
  cave113Hi.LoadFromResourceName(HINSTANCE, 'CAVE-113-Hi');
  cave113Def := TBitmap.Create;
  cave113Def.LoadFromResourceName(HINSTANCE, 'CAVE-113-DEF');
  cave116Hi := TBitmap.Create;
  cave116Hi.LoadFromResourceName(HINSTANCE, 'CAVE-116-Hi');
  cave116Def := TBitmap.Create;
  cave116Def.LoadFromResourceName(HINSTANCE, 'CAVE-116-DEF');
  cave117Hi := TBitmap.Create;
  cave117Hi.LoadFromResourceName(HINSTANCE, 'CAVE-117-Hi');
  cave117Def := TBitmap.Create;
  cave117Def.LoadFromResourceName(HINSTANCE, 'CAVE-117-DEF');
  cave119Hi := TBitmap.Create;
  cave119Hi.LoadFromResourceName(HINSTANCE, 'CAVE-119-Hi');
  cave119Def := TBitmap.Create;
  cave119Def.LoadFromResourceName(HINSTANCE, 'CAVE-119-DEF');
  cave124Hi := TBitmap.Create;
  cave124Hi.LoadFromResourceName(HINSTANCE, 'CAVE-124-Hi');
  cave124Def := TBitmap.Create;
  cave124Def.LoadFromResourceName(HINSTANCE, 'CAVE-124-DEF');
  cave125Hi := TBitmap.Create;
  cave125Hi.LoadFromResourceName(HINSTANCE, 'CAVE-125-Hi');
  cave125Def := TBitmap.Create;
  cave125Def.LoadFromResourceName(HINSTANCE, 'CAVE-125-DEF');
  cave127Hi := TBitmap.Create;
  cave127Hi.LoadFromResourceName(HINSTANCE, 'CAVE-127-Hi');
  cave127Def := TBitmap.Create;
  cave127Def.LoadFromResourceName(HINSTANCE, 'CAVE-127-DEF');
  cave193Hi := TBitmap.Create;
  cave193Hi.LoadFromResourceName(HINSTANCE, 'CAVE-193-Hi');
  cave193Def := TBitmap.Create;
  cave193Def.LoadFromResourceName(HINSTANCE, 'CAVE-193-DEF');
  cave197Hi := TBitmap.Create;
  cave197Hi.LoadFromResourceName(HINSTANCE, 'CAVE-197-Hi');
  cave197Def := TBitmap.Create;
  cave197Def.LoadFromResourceName(HINSTANCE, 'CAVE-197-DEF');
  cave199Hi := TBitmap.Create;
  cave199Hi.LoadFromResourceName(HINSTANCE, 'CAVE-199-Hi');
  cave199Def := TBitmap.Create;
  cave199Def.LoadFromResourceName(HINSTANCE, 'CAVE-199-DEF');
  cave209Hi := TBitmap.Create;
  cave209Hi.LoadFromResourceName(HINSTANCE, 'CAVE-209-Hi');
  cave209Def := TBitmap.Create;
  cave209Def.LoadFromResourceName(HINSTANCE, 'CAVE-209-DEF');
  cave213Hi := TBitmap.Create;
  cave213Hi.LoadFromResourceName(HINSTANCE, 'CAVE-213-Hi');
  cave213Def := TBitmap.Create;
  cave213Def.LoadFromResourceName(HINSTANCE, 'CAVE-213-DEF');
  cave215Hi := TBitmap.Create;
  cave215Hi.LoadFromResourceName(HINSTANCE, 'CAVE-215-Hi');
  cave215Def := TBitmap.Create;
  cave215Def.LoadFromResourceName(HINSTANCE, 'CAVE-215-DEF');
  cave221Hi := TBitmap.Create;
  cave221Hi.LoadFromResourceName(HINSTANCE, 'CAVE-221-Hi');
  cave221Def := TBitmap.Create;
  cave221Def.LoadFromResourceName(HINSTANCE, 'CAVE-221-DEF');
  cave223Hi := TBitmap.Create;
  cave223Hi.LoadFromResourceName(HINSTANCE, 'CAVE-223-Hi');
  cave223Def := TBitmap.Create;
  cave223Def.LoadFromResourceName(HINSTANCE, 'CAVE-223-DEF');
  cave241Hi := TBitmap.Create;
  cave241Hi.LoadFromResourceName(HINSTANCE, 'CAVE-241-Hi');
  cave241Def := TBitmap.Create;
  cave241Def.LoadFromResourceName(HINSTANCE, 'CAVE-241-DEF');
  cave245Hi := TBitmap.Create;
  cave245Hi.LoadFromResourceName(HINSTANCE, 'CAVE-245-Hi');
  cave245Def := TBitmap.Create;
  cave245Def.LoadFromResourceName(HINSTANCE, 'CAVE-245-DEF');
  cave247Hi := TBitmap.Create;
  cave247Hi.LoadFromResourceName(HINSTANCE, 'CAVE-247-Hi');
  cave247Def := TBitmap.Create;
  cave247Def.LoadFromResourceName(HINSTANCE, 'CAVE-247-DEF');
  cave253Hi := TBitmap.Create;
  cave253Hi.LoadFromResourceName(HINSTANCE, 'CAVE-253-Hi');
  cave253Def := TBitmap.Create;
  cave253Def.LoadFromResourceName(HINSTANCE, 'CAVE-253-DEF');
  cave255Hi := TBitmap.Create;
  cave255Hi.LoadFromResourceName(HINSTANCE, 'CAVE-255-Hi');
  cave255Def := TBitmap.Create;
  cave255Def.LoadFromResourceName(HINSTANCE, 'CAVE-255-DEF');
  caveFloorHi := TBitmap.Create;
  caveFloorHi.LoadFromResourceName(HINSTANCE, 'CAVEFLOORHI');
  caveFloorDef := TBitmap.Create;
  caveFloorDef.LoadFromResourceName(HINSTANCE, 'CAVEFLOORDEF');
  // Blue dungeon tiles
  blueDungeonWallHi := TBitmap.Create;
  blueDungeonWallHi.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONWALLHI');
  blueDungeonWallDef := TBitmap.Create;
  blueDungeonWallDef.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONWALLDEF');
  blueDungeonFloorHi := TBitmap.Create;
  blueDungeonFloorHi.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONFLOORHI');
  blueDungeonFloorDef := TBitmap.Create;
  blueDungeonFloorDef.LoadFromResourceName(HINSTANCE, 'BLUEDUNGEONFLOORDEF');
  // Cavern tiles
  caveWall2Def := TBitmap.Create;
  caveWall2Def.LoadFromResourceName(HINSTANCE, 'CAVEWALL2DEF');
  caveWall2Hi := TBitmap.Create;
  caveWall2Hi.LoadFromResourceName(HINSTANCE, 'CAVEWALL2HI');
  caveWall3Def := TBitmap.Create;
  caveWall3Def.LoadFromResourceName(HINSTANCE, 'CAVEWALL3DEF');
  caveWall3Hi := TBitmap.Create;
  caveWall3Hi.LoadFromResourceName(HINSTANCE, 'CAVEWALL3HI');
  // Stairs
  upStairs := TBitmap.Create;
  upStairs.LoadFromResourceName(HINSTANCE, 'USTAIRS');
  downStairs := TBitmap.Create;
  downStairs.LoadFromResourceName(HINSTANCE, 'DSTAIRS');
  // Bitmask dungeon tiles
  bmDungeon3Def := TBitmap.Create;
  bmDungeon3Def.LoadFromResourceName(HINSTANCE, '3DEF');
  bmDungeon3Hi := TBitmap.Create;
  bmDungeon3Hi.LoadFromResourceName(HINSTANCE, '3HI');
  bmDungeon5Def := TBitmap.Create;
  bmDungeon5Def.LoadFromResourceName(HINSTANCE, '5DEF');
  bmDungeon5Hi := TBitmap.Create;
  bmDungeon5Hi.LoadFromResourceName(HINSTANCE, '5HI');
  bmDungeon6Def := TBitmap.Create;
  bmDungeon6Def.LoadFromResourceName(HINSTANCE, '6DEF');
  bmDungeon6Hi := TBitmap.Create;
  bmDungeon6Hi.LoadFromResourceName(HINSTANCE, '6HI');
  bmDungeon7Def := TBitmap.Create;
  bmDungeon7Def.LoadFromResourceName(HINSTANCE, '7DEF');
  bmDungeon7Hi := TBitmap.Create;
  bmDungeon7Hi.LoadFromResourceName(HINSTANCE, '7HI');
  bmDungeon9Def := TBitmap.Create;
  bmDungeon9Def.LoadFromResourceName(HINSTANCE, '9DEF');
  bmDungeon9Hi := TBitmap.Create;
  bmDungeon9Hi.LoadFromResourceName(HINSTANCE, '9HI');
  bmDungeon10Def := TBitmap.Create;
  bmDungeon10Def.LoadFromResourceName(HINSTANCE, '10DEF');
  bmDungeon10Hi := TBitmap.Create;
  bmDungeon10Hi.LoadFromResourceName(HINSTANCE, '10HI');
  bmDungeon11Def := TBitmap.Create;
  bmDungeon11Def.LoadFromResourceName(HINSTANCE, '11DEF');
  bmDungeon11Hi := TBitmap.Create;
  bmDungeon11Hi.LoadFromResourceName(HINSTANCE, '11HI');
  bmDungeon12Def := TBitmap.Create;
  bmDungeon12Def.LoadFromResourceName(HINSTANCE, '12DEF');
  bmDungeon12Hi := TBitmap.Create;
  bmDungeon12Hi.LoadFromResourceName(HINSTANCE, '12HI');
  bmDungeon13Def := TBitmap.Create;
  bmDungeon13Def.LoadFromResourceName(HINSTANCE, '13DEF');
  bmDungeon13Hi := TBitmap.Create;
  bmDungeon13Hi.LoadFromResourceName(HINSTANCE, '13HI');
  bmDungeon14Def := TBitmap.Create;
  bmDungeon14Def.LoadFromResourceName(HINSTANCE, '14DEF');
  bmDungeon14Hi := TBitmap.Create;
  bmDungeon14Hi.LoadFromResourceName(HINSTANCE, '14HI');
  bmDungeonBLDef := TBitmap.Create;
  bmDungeonBLDef.LoadFromResourceName(HINSTANCE, '42DEF');
  bmDungeonBLHi := TBitmap.Create;
  bmDungeonBLHi.LoadFromResourceName(HINSTANCE, '42HI');
  bmDungeonBRDef := TBitmap.Create;
  bmDungeonBRDef.LoadFromResourceName(HINSTANCE, '43DEF');
  bmDungeonBRHi := TBitmap.Create;
  bmDungeonBRHi.LoadFromResourceName(HINSTANCE, '43HI');
  bmDungeonTLDef := TBitmap.Create;
  bmDungeonTLDef.LoadFromResourceName(HINSTANCE, '44DEF');
  bmDungeonTLHi := TBitmap.Create;
  bmDungeonTLHi.LoadFromResourceName(HINSTANCE, '44HI');
  bmDungeonTRDef := TBitmap.Create;
  bmDungeonTRDef.LoadFromResourceName(HINSTANCE, '45DEF');
  bmDungeonTRHi := TBitmap.Create;
  bmDungeonTRHi.LoadFromResourceName(HINSTANCE, '45HI');
  greyFloorDef := TBitmap.Create;
  greyFloorDef.LoadFromResourceName(HINSTANCE, 'GREYFLOORDEF');
  greyFloorHi := TBitmap.Create;
  greyFloorHi.LoadFromResourceName(HINSTANCE, 'GREYFLOORHI');
  blankTile := TBitmap.Create;
  blankTile.LoadFromResourceName(HINSTANCE, '15');
end;

procedure setupMap;
var
  // give each tile a unique ID number
  id_int: smallint;
begin
  case mapType of
    0: cave.generate;
    1: grid_dungeon.generate;
    2: cavern.generate;
    3: bitmask_dungeon.generate;
  end;
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
        (globalutils.dungeonArray[r][c] = ':') or
        (globalutils.dungeonArray[r][c] = '|') then
        maparea[r][c].Blocks := False;
    end;
  end;
end;

(* Redraw all visible tiles *)
procedure loadMap;
begin
  for r := 1 to MAXROWS do
  begin
    for c := 1 to MAXCOLUMNS do
    begin
      if (maparea[r][c].Discovered = True) and (maparea[r][c].Visible = False) then
        drawTile(c, r, 0);
      if (maparea[r][c].Visible = True) then
        drawTile(c, r, 1);
    end;
  end;
end;

function withinBounds(x, y: smallint): boolean;
begin
  Result := False;
  if (x >= 1) and (x <= globalutils.MAXCOLUMNS) and (y >= 1) and
    (y <= globalutils.MAXROWS) then
    Result := True;
end;

function canMove(checkX, checkY: smallint): boolean;
begin
  Result := False;
  if (checkX >= 1) and (checkX <= MAXCOLUMNS) and (checkY >= 1) and
    (checkY <= MAXROWS) then
  begin
    if (maparea[checkY][checkX].Blocks = False) then
      Result := True;
  end;
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
  if (entities.entityList[0].posX = checkX) and
    (entities.entityList[0].posY = checkY) then
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
  if (mapType = 0) then
  begin
    case maparea[r][c].glyph of
      ':': // Cave Floor
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveFloorHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveFloorDef);
      end;
      'A': // blank tile
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave255Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave255Def);
      end;
      'B': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave1Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave1Def);
      end;
      'C': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave4Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave4Def);
      end;
      'D': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave5Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave5Def);
      end;
      'E': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave7Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave7Def);
      end;
      'F': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave16Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave16Def);
      end;
      'G': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave17Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave17Def);
      end;
      'H': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave20Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave20Def);
      end;
      'I': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave21Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave21Def);
      end;
      'J': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave23Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave23Def);
      end;
      'K': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave28Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave28Def);
      end;
      'L': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave29Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave29Def);
      end;
      'M': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave31Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave31Def);
      end;
      'N': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave64Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave64Def);
      end;
      'O': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave65Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave65Def);
      end;
      'P': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave68Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave68Def);
      end;
      'Q': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave69Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave69Def);
      end;
      'R': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave71Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave71Def);
      end;
      'S': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave80Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave80Def);
      end;
      'T': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave81Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave81Def);
      end;
      'U': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave84Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave84Def);
      end;
      'V': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave85Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave85Def);
      end;
      'W': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave87Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave87Def);
      end;
      'X': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave92Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave92Def);
      end;
      'Y': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave93Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave93Def);
      end;
      'Z': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave95Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave95Def);
      end;
      'a': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave112Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave112Def);
      end;
      'b': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave113Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave113Def);
      end;
      'c': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave116Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave116Def);
      end;
      'd': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave117Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave117Def);
      end;
      'e': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave119Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave119Def);
      end;
      'f': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave124Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave124Def);
      end;
      'g': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave125Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave125Def);
      end;
      'h': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave127Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave127Def);
      end;
      'i': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave193Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave193Def);
      end;
      'j': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave197Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave197Def);
      end;
      'k': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave199Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave199Def);
      end;
      'l': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave209Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave209Def);
      end;
      'm': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave213Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave213Def);
      end;
      'n': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave215Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave215Def);
      end;
      'o': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave221Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave221Def);
      end;
      'p': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave223Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave223Def);
      end;
      'q': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave241Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave241Def);
      end;
      'r': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave245Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave245Def);
      end;
      's': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave247Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave247Def);
      end;
      't': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave253Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave253Def);
      end;
      'u': // Cave wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave255Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave255Def);
      end
      else
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave255Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), cave255Def);
    end;
  end
  else if (mapType = 1) then
  begin
    case maparea[r][c].glyph of
      '.': // Blue Dungeon Floor
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonFloorHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonFloorDef);
      end;
      '#': // Blue Dungeon wall
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonWallHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonWallDef);
      end;
    end;
  end
  else if (mapType = 2) then
  begin
    case maparea[r][c].glyph of
      '.': // Cave Floor
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveFloorHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveFloorDef);
      end;
      '#': // Cavern wall 1
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveWall2Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveWall2Def);
      end;
      '*': // Cavern wall 2
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveWall3Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), caveWall3Def);
      end;
    end;
  end
  else if (mapType = 3) then
  begin
    case maparea[r][c].glyph of
      'D': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon3Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon3Def);
      end;
      'F': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon5Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon5Def);
      end;
      'G': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon6Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon6Def);
      end;
      'H': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon7Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon7Def);
      end;
      'J': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon9Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon9Def);
      end;
      'K': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon10Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon10Def);
      end;
      'L': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon11Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon11Def);
      end;
      'M': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon12Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon12Def);
      end;
      'N': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon13Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon13Def);
      end;
      'O': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon14Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon14Def);
      end;
      'P': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), blankTile)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), blankTile);
      end;
      '.': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonFloorHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), blueDungeonFloorDef);
      end;
      'a': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonBLHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonBLDef);
      end;
      'b': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonBRHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonBRDef);
      end;
      'c': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonTLHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonTLDef);
      end;
      'd': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonTRHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeonTRDef);
      end;
      '|': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), greyFloorHi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), greyFloorDef);
      end;

    end;
  end;
end;

end.
