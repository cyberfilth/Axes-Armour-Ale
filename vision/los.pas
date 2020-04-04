(* Line of sight function *)

unit los;

{$mode objfpc}{$H+}

interface

uses
  map;

var
  totalSpaces: smallint;

(* Checks in the distance to the target is within vision range *)
function inView(x1, y1, x2, y2, visRange: smallint): boolean;

implementation

function inView(x1, y1, x2, y2, visRange: smallint): boolean;
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: smallint;
begin
  Result := False;
  totalSpaces := 0;
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
  (* Start drawing at *)
  x := x1;
  y := y1;
  (* Draw the pixels *)
  for i := 1 to numpixels do
  begin
    Inc(totalSpaces);
    if (map.maparea[y][x].Blocks = True) then
    begin
      Dec(totalSpaces);
      break;
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
  if (totalSpaces <= visRange) then
    Result := True;
end;

end.

