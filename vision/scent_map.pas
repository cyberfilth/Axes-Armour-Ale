(* Scent trails left by the player, generated over a radius of 6 squares *)
{ TODO : Keep within bounds of the map }
unit scent_map;

{$mode objfpc}{$H+}

interface

uses
  map, globalutils;

(* Scent generated when player is first spawned on map *)
procedure initialiseScent(centreX, centreY: smallint);
(* Smell increases within the players FoV *)
procedure updateScent(centreX, centreY: smallint);
(* Fade out the scent that is not in players FoV *)
procedure fadeScent;

implementation

(* Draws a series of expanding squares, not optimised but it only runs once per level *)
procedure initialiseScent(centreX, centreY: smallint);
var
  Height, Width, tlx, tly, rows, cols, scentNumber: smallint;
begin
  (* Scent range extends 6 tiles in each direction *)
  scentNumber := 1;
  tlx := 6;
  tly := 6;
  rows := 12;
  cols := 12;
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        maparea[centreY - tly][centreX - tlx].Scent := scentNumber;
      Dec(tlx);
    end;
    tlx := 6;
    Dec(tly);
  end;
  Dec(rows, 2);
  Dec(cols, 2);
  tlx := 5;
  tly := 5;
  Inc(scentNumber);
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        maparea[centreY - tly][centreX - tlx].Scent := scentNumber;
      Dec(tlx);
    end;
    tlx := 5;
    Dec(tly);
  end;
  Dec(rows, 2);
  Dec(cols, 2);
  tlx := 4;
  tly := 4;
  Inc(scentNumber);
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        maparea[centreY - tly][centreX - tlx].Scent := scentNumber;
      Dec(tlx);
    end;
    tlx := 4;
    Dec(tly);
  end;
  Dec(rows, 2);
  Dec(cols, 2);
  tlx := 3;
  tly := 3;
  Inc(scentNumber);
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        maparea[centreY - tly][centreX - tlx].Scent := scentNumber;
      Dec(tlx);
    end;
    tlx := 3;
    Dec(tly);
  end;
  Dec(rows, 2);
  Dec(cols, 2);
  tlx := 2;
  tly := 2;
  Inc(scentNumber);
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        maparea[centreY - tly][centreX - tlx].Scent := scentNumber;
      Dec(tlx);
    end;
    tlx := 2;
    Dec(tly);
  end;
  Dec(rows, 2);
  Dec(cols, 2);
  tlx := 1;
  tly := 1;
  Inc(scentNumber);
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        maparea[centreY - tly][centreX - tlx].Scent := scentNumber;
      Dec(tlx);
    end;
    tlx := 1;
    Dec(tly);
  end;
  (* Player square *)
  maparea[centreY][centreX].Scent := scentNumber + 1;
end;

procedure updateScent(centreX, centreY: smallint);
var
  Height, Width, tlx, tly, rows, cols: smallint;
begin
  tlx := 6;
  tly := 6;
  rows := 12;
  cols := 12;
  for Height := 0 to rows do
  begin
    for Width := 0 to cols do
    begin
      if (withinBounds(centreX - tlx, centreY - tly)) and
        (maparea[centreY - tly][centreX - tlx].Blocks = False) then
        Inc(maparea[centreY - tly][centreX - tlx].Scent);
      Dec(tlx);
    end;
    tlx := 6;
    Dec(tly);
  end;
end;

(* The scent fades out every two turns *)
procedure fadeScent;
var
  r, c: smallint;
begin
  for r := 1 to globalutils.MAXROWS do
  begin
    for c := 1 to globalutils.MAXCOLUMNS do
    begin
      if (maparea[r][c].Visible = False) and (maparea[r][c].Scent > 0) then
        Dec(maparea[r][c].Scent);
    end;
  end;
end;

end.
