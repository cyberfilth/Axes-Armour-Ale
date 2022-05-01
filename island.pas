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
        Occupied := False;
        Discovered := False;
        { Forest }
        if (overworld.terrainArray[r][c] = 'A') then
        begin
          Glyph := chr(6);
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
        end
        else if (overworld.terrainArray[r][c] = 'B') then
        begin
          Glyph := chr(6);
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
          Blocks := False;
        end
        else if (overworld.terrainArray[r][c] = 'C') then
        begin
          Glyph := chr(5);
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
        end
        else if (overworld.terrainArray[r][c] = 'D') then
        begin
          Glyph := '\';
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
        end
        else if (overworld.terrainArray[r][c] = 'E') then
        begin
          Glyph := '/';
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
        end
        else if (overworld.terrainArray[r][c] = 'F') then
        begin
          Glyph := '\';
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
          Blocks := False;
        end
        else if (overworld.terrainArray[r][c] = 'G') then
        begin
          Glyph := '/';
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
          Blocks := False;
        end
        { Sea }
        else if (overworld.terrainArray[r][c] = '~') then
        begin
          Glyph := chr(247);
          TerrainType := tSea;
          GlyphColour := 'blue';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = '-') then
        begin
          Glyph := '~';
          TerrainType := tSea;
          GlyphColour := 'lightBlue';
          Blocks := True;
        end
        { Plains }
        else if (overworld.terrainArray[r][c] = 'H') then
        begin
          Glyph := '.';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = 'I') then
        begin
          Glyph := ',';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = 'J') then
        begin
          Glyph := '.';
          TerrainType := tPlains;
          GlyphColour := 'yellow';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = 'K') then
        begin
          Glyph := chr(94);
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = 'L') then
        begin
          Glyph := ':';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = 'M') then
        begin
          Glyph := ';';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := True;
        end
        else if (overworld.terrainArray[r][c] = 'N') then
        begin
          Glyph := ':';
          TerrainType := tPlains;
          GlyphColour := 'yellow';
          Blocks := True;
        end;
      end;
    end;
  end;
end;

end.
