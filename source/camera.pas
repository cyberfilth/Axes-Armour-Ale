(* Camera unit follows the player around and displays the surrounding game map *)

unit camera;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, globalUtils, ui, map, entities, island, overworld;

const
  camHeight = 19;

var
  r, c, camWidth: smallint;

{ Underground camera }
function getX(Xcoord: smallint): smallint;
function getY(Ycoord: smallint): smallint;
procedure drawMap;
procedure drawPlayer;

{ Overground camera }
function getXOW(Xcoord: smallint): smallint;
function getYOW(Ycoord: smallint): smallint;
procedure drawOWMap;
procedure drawOWPlayer;

implementation

function getX(Xcoord: smallint): smallint;
var
  p, hs, s, m: smallint;
begin
  p := Xcoord;
  hs := camWidth div 2;
  s := camWidth;
  m := globalUtils.MAXCOLUMNS;

  if (p < hs) then
    Result := 0
  else if (p >= m - hs) then
    Result := m - s
  else
    Result := p - hs;
end;

function getY(Ycoord: smallint): smallint;
const
  s = camHeight;
  hs = camHeight div 2;
  m = globalUtils.MAXROWS;
var
  p: smallint;
begin
  p := Ycoord;
  if (p < hs) then
    Result := 0
  else if (p >= m - hs) then
    Result := m - s
  else
    Result := p - hs;
end;

procedure drawMap;
var
  (* Player coordinates *)
  pX, pY: smallint;
  (* Tile colour *)
  gCol: shortstring;
begin
  if (globalUtils.womblingFree = 'underground') then
  begin
    pX := entityList[0].posX;
    pY := entityList[0].posY;
    for r := 1 to camHeight do
    begin
      for c := 1 to camWidth do
      begin
        gCol := map.mapDisplay[r + getY(pY)][c + getX(pX)].GlyphColour;
        TextOut(c, r, gCol, map.mapDisplay[r + getY(pY)][c + getX(pX)].Glyph);
      end;
    end;
    drawPlayer;
  end;
end;

procedure drawPlayer;
var
  entX, entY: smallint;
  (* Glyph colour *)
  gCol: shortstring;
begin
  gCol := entityList[0].glyphColour;
  entX := entityList[0].posX;
  entY := entityList[0].posY;
  TextOut(entX - getX(entX), entY - getY(entY), gCol, entityList[0].glyph);
end;

{ Overground camera }

function getXOW(Xcoord: smallint): smallint;
var
  p, hs, s, m: smallint;
begin
  p := Xcoord;
  hs := camWidth div 2;
  s := camWidth;
  m := overworld.MAXC;

  if (p < hs) then
    Result := 0
  else if (p >= m - hs) then
    Result := m - s
  else
    Result := p - hs;
end;

function getYOW(Ycoord: smallint): smallint;
const
  s = camHeight;
  hs = camHeight div 2;
  m = overworld.MAXR;
var
  p: smallint;
begin
  p := Ycoord;
  if (p < hs) then
    Result := 0
  else if (p >= m - hs) then
    Result := m - s
  else
    Result := p - hs;
end;

procedure drawOWMap;
var
  (* Player coordinates *)
  pX, pY: smallint;
  (* Tile colour *)
  gCol: shortstring;
begin
  if (globalUtils.womblingFree = 'overground') then
  begin
    pX := entityList[0].posX;
    pY := entityList[0].posY;
    for c := 1 to camWidth do
    begin
      for r := 1 to camHeight do
      begin
        gCol := island.overworldDisplay[r + getYOW(pY)][c + getXOW(pX)].GlyphColour;
        TextOut(c, r, gCol, island.overworldDisplay[r + getYOW(pY)][c + getXOW(pX)].Glyph);
      end;
    end;
    drawOWPlayer;
  end;
end;

procedure drawOWPlayer;
begin
  TextOut(entityList[0].posX - getXOW(entityList[0].posX), entityList[0].posY - getYOW(entityList[0].posY), 'yellow', '@');
end;

end.
