(* Organises the game world in an array and calculates the players FoV *)

unit map;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  globalutils, Graphics, LResources;

const
  (* Width of tiles is used as a multiplier in placing tiles *)
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
  caveWallHi, caveWallDef, caveFloorHi, caveFloorDef, blueDungeonWallHi,
  blueDungeonWallDef, blueDungeonFloorHi, blueDungeonFloorDef,
  caveWall2Def, caveWall2Hi, caveWall3Def, caveWall3Hi, upStairs,
  downStairs, bmDungeon0Hi, bmDungeon0Def, bmDungeon1Hi, bmDungeon1Def,
  bmDungeon2Hi, bmDungeon2Def, bmDungeon3Hi, bmDungeon3Def, bmDungeon4Hi,
  bmDungeon4Def, bmDungeon5Hi, bmDungeon5Def, bmDungeon6Hi, bmDungeon6Def,
  bmDungeon7Hi, bmDungeon7Def, bmDungeon8Hi, bmDungeon8Def, bmDungeon9Hi,
  bmDungeon9Def, bmDungeon10Hi, bmDungeon10Def, bmDungeon11Hi,
  bmDungeon11Def, bmDungeon12Hi, bmDungeon12Def, bmDungeon13Hi,
  bmDungeon13Def, bmDungeon14Hi, bmDungeon14Def, blankTile: TBitmap;

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
  caveWallHi := TBitmap.Create;
  caveWallHi.LoadFromResourceName(HINSTANCE, 'CAVEWALLHI');
  caveWallDef := TBitmap.Create;
  caveWallDef.LoadFromResourceName(HINSTANCE, 'CAVEWALLDEF');
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
  bmDungeon0Def := TBitmap.Create;
  bmDungeon0Def.LoadFromResourceName(HINSTANCE, '0DEF');
  bmDungeon0Hi := TBitmap.Create;
  bmDungeon0Hi.LoadFromResourceName(HINSTANCE, '0HI');
  bmDungeon1Def := TBitmap.Create;
  bmDungeon1Def.LoadFromResourceName(HINSTANCE, '1DEF');
  bmDungeon1Hi := TBitmap.Create;
  bmDungeon1Hi.LoadFromResourceName(HINSTANCE, '1HI');
  bmDungeon2Def := TBitmap.Create;
  bmDungeon2Def.LoadFromResourceName(HINSTANCE, '2DEF');
  bmDungeon2Hi := TBitmap.Create;
  bmDungeon2Hi.LoadFromResourceName(HINSTANCE, '2HI');
  bmDungeon3Def := TBitmap.Create;
  bmDungeon3Def.LoadFromResourceName(HINSTANCE, '3DEF');
  bmDungeon3Hi := TBitmap.Create;
  bmDungeon3Hi.LoadFromResourceName(HINSTANCE, '3HI');
  bmDungeon4Def := TBitmap.Create;
  bmDungeon4Def.LoadFromResourceName(HINSTANCE, '4DEF');
  bmDungeon4Hi := TBitmap.Create;
  bmDungeon4Hi.LoadFromResourceName(HINSTANCE, '4HI');
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
  bmDungeon8Def := TBitmap.Create;
  bmDungeon8Def.LoadFromResourceName(HINSTANCE, '8DEF');
  bmDungeon8Hi := TBitmap.Create;
  bmDungeon8Hi.LoadFromResourceName(HINSTANCE, '8HI');
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
        (globalutils.dungeonArray[r][c] = ':') then
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
      'A': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon0Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon0Def);
      end;
      'B': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon1Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon1Def);
      end;
      'C': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon2Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon2Def);
      end;
      'D': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon3Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon3Def);
      end;
      'E': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon4Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon4Def);
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
      'I': // Bitmask dungeon
      begin
        if (hiDef = 1) then
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon8Hi)
        else
          drawToBuffer(mapToScreen(c), mapToScreen(r), bmDungeon8Def);
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
    end;
  end;
end;

end.
