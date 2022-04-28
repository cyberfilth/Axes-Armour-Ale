(* Stores the overworld map and provides helper functions *)

unit island;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, overworld;

type
  overworldTerrain = (tSea, tForest, tPlains);

type
  (* Tiles that make up the overworld *)
  overworldTile = record
    (* Unique tile ID *)
    id: smallint;
    (* Does the tile block movement *)
    Blocks: boolean;
    (* Does the tile contain a dungeon *)
    Occupied: boolean;
    (* Has the tile been discovered already *)
    Discovered: boolean;
    (* Type of terrain *)
    TerrainType: overworldTerrain;
    (* Character used to represent the tile *)
    Glyph: shortstring;
    (* Colour of the glyph *)
    GlyphColour: shortstring;
  end;

var
  (* The overworld map *)
  overworldMap: array[1..overworld.MAXR, 1..overworld.MAXC] of overworldTile;

(* Store the newly generated island in memory *)
procedure storeEllanToll;

implementation

procedure storeEllanToll;
var
  r, c, id_int: smallint;
begin
  r := 1;
  c := 1;
  id_int := 0;
  for r := 1 to overworld.MAXR do
  begin
    for c := 1 to overworld.MAXC do
    begin
      Inc(id_int);
      with overworldMap[r][c] do
      begin
        id := id_int;
        if (overworld.terrainArray[r][c] = '~') or
          (overworld.terrainArray[r][c] = '-') then
          Blocks := True
        else
          Blocks := False;
        Occupied := False;
        Discovered := False;
        if (overworld.terrainArray[r][c] = 'A') or (overworld.terrainArray[r][c] = 'D') or
           (overworld.terrainArray[r][c] = 'E') or (overworld.terrainArray[r][c] = 'F') or
           (overworld.terrainArray[r][c] = 'G') then
        begin
          TerrainType := tForest;
          GlyphColour := 'green';
        end
        else if (overworld.terrainArray[r][c] = 'B') or
          (overworld.terrainArray[r][c] = 'C') then
        begin
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
        end
        else if (overworld.terrainArray[r][c] = '~') then
        begin
          TerrainType := tSea;
          GlyphColour := 'blue';
        end
        else if (overworld.terrainArray[r][c] = '-') then
        begin
          TerrainType := tSea;
          GlyphColour := 'lightBlue';
        end
        else if (overworld.terrainArray[r][c] = 'J') or (overworld.terrainArray[r][c] = 'L') then
        begin
          TerrainType := tPlains;
          GlyphColour := 'brown';
        end;
        Glyph := overworld.terrainArray[r][c];
      end;
    end;
  end;
end;

end.
