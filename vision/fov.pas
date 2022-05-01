(* Players Field of View functions *)

unit fov;

{$mode fpc}{$H+}

interface

uses
  map, globalUtils, overworld, island;

                   { Underground }
(* Draw Bresenham lines in a circle *)
procedure drawLine(x1, y1, x2, y2: smallint; hiDef: byte);
(* Calculate circle around player *)
procedure fieldOfView(centreX, centreY, radius: smallint; hiDef: byte);

                   { Overworld }
(* Draw Bresenham lines overground *)
procedure drawOverLine(x1, y1, x2, y2: smallint);
(* FoV on the overworld map *)
procedure islandFOV(centreX, centreY: smallint);

implementation

procedure drawLine(x1, y1, x2, y2: smallint; hiDef: byte);
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: smallint;
begin
  (* Calculate delta X and delta Y for initialisation *)
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);
  (* Initialize all vars based on which is the independent variable *)
  if deltax >= deltay then
  begin
    (* x is independent variable *)
    numpixels := deltax + 1;
    d := (2 * deltay) - deltax;
    dinc1 := deltay shl 1;
    dinc2 := (deltay - deltax) shl 1;
    xinc1 := 1;
    xinc2 := 1;
    yinc1 := 0;
    yinc2 := 1;
  end
  else
  begin
    (* y is independent variable *)
    numpixels := deltay + 1;
    d := (2 * deltax) - deltay;
    dinc1 := deltax shl 1;
    dinc2 := (deltax - deltay) shl 1;
    xinc1 := 0;
    xinc2 := 1;
    yinc1 := 1;
    yinc2 := 1;
  end;
  (* Make sure x and y move in the right directions *)
  if x1 > x2 then
  begin
    xinc1 := -xinc1;
    xinc2 := -xinc2;
  end;
  if y1 > y2 then
  begin
    yinc1 := -yinc1;
    yinc2 := -yinc2;
  end;
  (* Start tracing line at *)
  x := x1;
  y := y1;
  (* Draw the pixels *)
  for i := 1 to numpixels do
  begin
    (* Check that we are not searching out of bounds of map *)
    if (x >= 1) and (x <= globalutils.MAXCOLUMNS) and (y >= 1) and
      (y <= globalutils.MAXROWS) then
    begin
      if (hiDef = 1) then
      begin
        map.maparea[y][x].Visible := True;
        map.maparea[y][x].Discovered := True;
        map.drawTile(x, y, 1);
        if (map.maparea[y][x].Blocks = True) then
          exit;
      end
      else
      begin
        map.maparea[y][x].Visible := False;
        map.maparea[y][x].Discovered := True;
        map.drawTile(x, y, 0);
        if (map.maparea[y][x].Blocks = True) then
          exit;
      end;
    end;
    if d < 0 then
    begin
      d := d + dinc1;
      x := x + xinc1;
      y := y + yinc1;
    end
    else
    begin
      d := d + dinc2;
      x := x + xinc2;
      y := y + yinc2;
    end;
  end;
end;

procedure fieldOfView(centreX, centreY, radius: smallint; hiDef: byte);
var
  d, x, y: smallint;
begin
  d := 3 - (2 * radius);
  x := 0;
  y := radius;
  while (x <= y) do
  begin
    drawLine(centreX, centreY, centreX + X, centreY + Y, hiDef);
    drawLine(centreX, centreY, centreX + X, centreY - Y, hiDef);
    drawLine(centreX, centreY, centreX - X, centreY + Y, hiDef);
    drawLine(centreX, centreY, centreX - X, centreY - Y, hiDef);
    drawLine(centreX, centreY, centreX + Y, centreY + X, hiDef);
    drawLine(centreX, centreY, centreX + Y, centreY - X, hiDef);
    drawLine(centreX, centreY, centreX - Y, centreY + X, hiDef);
    drawLine(centreX, centreY, centreX - Y, centreY - X, hiDef);
    (* cover the gaps in the circle *)
    if (radius = 5) then
    begin
      drawLine(centreX, centreY, centreX + 3, centreY - 3, hiDef);
      drawLine(centreX, centreY, centreX + 3, centreY + 3, hiDef);
      drawLine(centreX, centreY, centreX - 3, centreY + 3, hiDef);
      drawLine(centreX, centreY, centreX - 3, centreY - 3, hiDef);
    end;
    if (radius = 6) then
    begin
      drawLine(centreX, centreY, centreX + 4, centreY - 3, hiDef);
      drawLine(centreX, centreY, centreX + 3, centreY - 4, hiDef);
      drawLine(centreX, centreY, centreX - 4, centreY - 3, hiDef);
      drawLine(centreX, centreY, centreX - 3, centreY - 4, hiDef);
      drawLine(centreX, centreY, centreX + 4, centreY + 3, hiDef);
      drawLine(centreX, centreY, centreX + 3, centreY + 4, hiDef);
      drawLine(centreX, centreY, centreX - 4, centreY + 3, hiDef);
      drawLine(centreX, centreY, centreX - 3, centreY + 4, hiDef);
    end;
    if (d < 0) then
      d := d + (4 * x) + 6
    else
    begin
      d := d + 4 * (x - y) + 10;
      y := y - 1;
    end;
    Inc(x);
  end;
end;

procedure drawOverLine(x1, y1, x2, y2: smallint);
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: smallint;
begin
  (* Calculate delta X and delta Y for initialisation *)
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);
  (* Initialize all vars based on which is the independent variable *)
  if deltax >= deltay then
  begin
    (* x is independent variable *)
    numpixels := deltax + 1;
    d := (2 * deltay) - deltax;
    dinc1 := deltay shl 1;
    dinc2 := (deltay - deltax) shl 1;
    xinc1 := 1;
    xinc2 := 1;
    yinc1 := 0;
    yinc2 := 1;
  end
  else
  begin
    (* y is independent variable *)
    numpixels := deltay + 1;
    d := (2 * deltax) - deltay;
    dinc1 := deltax shl 1;
    dinc2 := (deltax - deltay) shl 1;
    xinc1 := 0;
    xinc2 := 1;
    yinc1 := 1;
    yinc2 := 1;
  end;
  (* Make sure x and y move in the right directions *)
  if x1 > x2 then
  begin
    xinc1 := -xinc1;
    xinc2 := -xinc2;
  end;
  if y1 > y2 then
  begin
    yinc1 := -yinc1;
    yinc2 := -yinc2;
  end;
  (* Start tracing line at *)
  x := x1;
  y := y1;
  (* Draw the pixels *)
  for i := 1 to numpixels do
  begin
    (* Check that we are not searching out of bounds of map *)
    if (x >= 1) and (x <= overworld.MAXC) and (y >= 1) and (y <= overworld.MAXR) then
    begin
      island.overworldMap[y][x].Discovered := True;
      island.drawOWTile(x, y);
      if (island.overworldMap[y][x].Blocks = True) then
          exit;
    end;
    if d < 0 then
    begin
      d := d + dinc1;
      x := x + xinc1;
      y := y + yinc1;
    end
    else
    begin
      d := d + dinc2;
      x := x + xinc2;
      y := y + yinc2;
    end;
  end;
end;

procedure islandFOV(centreX, centreY: smallint);
var
  d, x, y: smallint;
begin
  x := 0;
  y := 5;
  d := 3 - (2 * y);
  while (x <= y) do
  begin
    drawOverLine(centreX, centreY, centreX + X, centreY + Y);
    drawOverLine(centreX, centreY, centreX + X, centreY - Y);
    drawOverLine(centreX, centreY, centreX - X, centreY + Y);
    drawOverLine(centreX, centreY, centreX - X, centreY - Y);
    drawOverLine(centreX, centreY, centreX + Y, centreY + X);
    drawOverLine(centreX, centreY, centreX + Y, centreY - X);
    drawOverLine(centreX, centreY, centreX - Y, centreY + X);
    drawOverLine(centreX, centreY, centreX - Y, centreY - X);
    (* cover the gaps in the circle *)
    drawOverLine(centreX, centreY, centreX + 3, centreY - 3);
    drawOverLine(centreX, centreY, centreX + 3, centreY + 3);
    drawOverLine(centreX, centreY, centreX - 3, centreY + 3);
    drawOverLine(centreX, centreY, centreX - 3, centreY - 3);
    if (d < 0) then
      d := d + (4 * x) + 6
    else
    begin
      d := d + 4 * (x - y) + 10;
      y := y - 1;
    end;
    Inc(x);
  end;
end;

end.

