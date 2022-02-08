(* Camera unit follows the player around and displays the surrounding game map *)

unit camera;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, globalUtils, ui, map, entities;

const
  camHeight = 19;

var
  r, c, camWidth: smallint;

function getX(Xcoord: smallint): smallint;
function getY(Ycoord: smallint): smallint;
procedure drawMap;
procedure drawPlayer;

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
  pX := entities.entityList[0].posX;
  pY := entities.entityList[0].posY;
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

procedure drawPlayer;

var
  entX, entY: smallint;
  (* Glyph colour *)
  gCol: shortstring;
begin
  gCol := entities.entityList[0].glyphColour;
  entX := entities.entityList[0].posX;
  entY := entities.entityList[0].posY;
  TextOut(entX - getX(entX), entY - getY(entY), gCol, entities.entityList[0].glyph);
end;

end.
