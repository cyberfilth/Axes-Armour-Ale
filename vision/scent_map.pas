(* Scent trails left by the player, generated over a radius of 6 squares *)

unit scent_map;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  map, globalutils;

(* Scent generated when player is first spawned on map *)
procedure initialiseScent(centreX, centreY: smallint);
(* Smell increases as the player remains on the map *)
procedure updateScent(centreX, centreY: smallint);

implementation

procedure initialiseScent(centreX, centreY: smallint);
var
  d, x, y, i, scentNumber: smallint;
begin
  (* Scent range is 6 tile in radius *)
  scentNumber := 6;
  (* Player square *)
  maparea[centreY][centreX].Scent := scentNumber + 1;
  for i := 1 to scentNumber do
  begin
    d := 3 - (2 * i);
    x := 0;
    y := i;
    while (x <= y) do
    begin
      (* Set starting scent values *)
      if (maparea[centreY + Y][centreX + X].Blocks = False) then
        maparea[centreY + Y][centreX + X].Scent := scentNumber;
      if (maparea[centreY - Y][centreX + X].Blocks = False) then
        maparea[centreY - Y][centreX + X].Scent := scentNumber;
      if (maparea[centreY + Y][centreX - X].Blocks = False) then
        maparea[centreY + Y][centreX - X].Scent := scentNumber;
      if (maparea[centreY - Y][centreX - X].Blocks = False) then
        maparea[centreY - Y][centreX - X].Scent := scentNumber;
      if (maparea[centreY + X][centreX + Y].Blocks = False) then
        maparea[centreY + X][centreX + Y].Scent := scentNumber;
      if (maparea[centreY - X][centreX + Y].Blocks = False) then
        maparea[centreY - X][centreX + Y].Scent := scentNumber;
      if (maparea[centreY + X][centreX - Y].Blocks = False) then
        maparea[centreY + X][centreX - Y].Scent := scentNumber;
      if (maparea[centreY - X][centreX - Y].Blocks = False) then
        maparea[centreY - X][centreX - Y].Scent := scentNumber;
      (* Cover the gaps left by the algorithm above *)
      if (maparea[centreY + 1][centreX + 1].Blocks = False) then
        maparea[centreY + 1][centreX + 1].Scent := 6;
      if (maparea[centreY - 1][centreX + 1].Blocks = False) then
        maparea[centreY - 1][centreX + 1].Scent := 6;
      if (maparea[centreY + 1][centreX - 1].Blocks = False) then
        maparea[centreY + 1][centreX - 1].Scent := 6;
      if (maparea[centreY - 1][centreX - 1].Blocks = False) then
        maparea[centreY - 1][centreX - 1].Scent := 6;
      if (maparea[centreY - 2][centreX + 4].Blocks = False) then
        maparea[centreY - 2][centreX + 4].Scent := 3;
      if (maparea[centreY - 2][centreX - 4].Blocks = False) then
        maparea[centreY - 2][centreX - 4].Scent := 3;
      if (maparea[centreY + 2][centreX + 4].Blocks = False) then
        maparea[centreY + 2][centreX + 4].Scent := 3;
      if (maparea[centreY + 2][centreX - 4].Blocks = False) then
        maparea[centreY + 2][centreX - 4].Scent := 3;
      if (maparea[centreY + 4][centreX + 2].Blocks = False) then
        maparea[centreY + 4][centreX + 2].Scent := 2;
      if (maparea[centreY + 4][centreX - 2].Blocks = False) then
        maparea[centreY + 4][centreX - 2].Scent := 2;
      if (maparea[centreY - 4][centreX + 2].Blocks = False) then
        maparea[centreY - 4][centreX + 2].Scent := 2;
      if (maparea[centreY - 4][centreX - 2].Blocks = False) then
        maparea[centreY - 4][centreX - 2].Scent := 2;

      if (d < 0) then
        d := d + (4 * x) + 6
      else
      begin
        d := d + 4 * (x - y) + 10;
        y := y - 1;
      end;
      Inc(x);
    end;
    Dec(scentNumber);
  end;
end;

procedure updateScent(centreX, centreY: smallint);
begin

end;

end.

