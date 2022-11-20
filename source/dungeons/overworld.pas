(* The overworld that Axes, Armour & Ale is set in. Generated using perlin noise and
   cellular automata over several iterations and then framed in an 'island' cutout *)

unit overworld;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, noise, globalUtils, architect;

const
  MAXC = 80;
  MAXR = 60;

var
  terrainArray, tempArray, perlinArray: array[1..MAXR, 1..MAXC] of char;
  r, c, iterations, tileCounter: smallint;
  z, feature: double;
  (* Shape of the island that will be imposed onto the array *)
  {$I island}

(* Create an island *)
procedure generate;

implementation

uses
  island;

procedure generate;
begin
  { fill map with walls }
  for r := 1 to MAXR do
  begin
    for c := 1 to MAXC do
    begin
      terrainArray[r][c] := '*';
    end;
  end;

  for r := 1 to MAXR do
  begin
    for c := 1 to MAXC do
    begin
      { 45% chance of drawing a wall tile }
      if (Random(100) <= 45) then
        terrainArray[r][c] := '*'
      else
        terrainArray[r][c] := '.';
    end;
  end;

  { Run through the process 5 times }
  for iterations := 1 to 5 do
  begin
    for r := 1 to MAXR do
    begin
      for c := 1 to MAXC do
      begin
        (* Generate landmass *)
        tileCounter := 0;
        if (terrainArray[r - 1][c] = '*') then // NORTH
          Inc(tileCounter);
        if (terrainArray[r - 1][c + 1] = '*') then // NORTH EAST
          Inc(tileCounter);
        if (terrainArray[r][c + 1] = '*') then // EAST
          Inc(tileCounter);
        if (terrainArray[r + 1][c + 1] = '*') then // SOUTH EAST
          Inc(tileCounter);
        if (terrainArray[r + 1][c] = '*') then // SOUTH
          Inc(tileCounter);
        if (terrainArray[r + 1][c - 1] = '*') then // SOUTH WEST
          Inc(tileCounter);
        if (terrainArray[r][c - 1] = '*') then // WEST
          Inc(tileCounter);
        if (terrainArray[r - 1][c - 1] = '*') then // NORTH WEST
          Inc(tileCounter);
        (* Set tiles in temporary array *)
        if (terrainArray[r][c] = '*') then
        begin
          if (tileCounter >= 4) then
            tempArray[r][c] := '*'
          else
            tempArray[r][c] := '.';
        end;
        if (terrainArray[r][c] = '.') then
        begin
          if (tileCounter >= 5) then
            tempArray[r][c] := '*'
          else
            tempArray[r][c] := '.';
        end;
      end;
    end;
    end;

    (* Generate perlin noise *)
    for r := 1 to MAXR do
    begin
      for c := 1 to MAXC do
      begin
        z := (random(8) + random);
        feature := noise.generateNoise(z, r, c);
        if (feature >= -1.0) and (feature < -0.3) then
          perlinArray[r][c] := '1'   // Set A
        else if (feature >= -0.3) and (feature < -0.0) then
          perlinArray[r][c] := '2'   // set A
        else if (feature >= 0.0) and (feature <= 0.4) then
          perlinArray[r][c] := '3'    // set B, the largest set
        else if (feature >= 0.41) and (feature <= 0.45) then
          perlinArray[r][c] := '4'    // highlight 1
        else if (feature >= 0.46) and (feature <= 0.8) then
          perlinArray[r][c] := '5'    // highlight 2
        else if (feature >= 0.81) and (feature <= 0.9) then
          perlinArray[r][c] := '6'    // highlight 3
        else
          perlinArray[r][c] := '7';   // highlight 4
      end;
    end;

    (* Run the temporary array through the perlin array *)
    for r := 1 to MAXR do
    begin
      for c := 1 to MAXC do
      begin
        if (perlinArray[r][c] = '1') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'A'
          else
            tempArray[r][c] := 'H';
        end
        else if (perlinArray[r][c] = '2') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'B'
          else
            tempArray[r][c] := 'I';
        end
        else if (perlinArray[r][c] = '3') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'C'
          else
            tempArray[r][c] := 'J';
        end
        else if (perlinArray[r][c] = '4') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'D'
          else
            tempArray[r][c] := 'K';
        end
        else if (perlinArray[r][c] = '5') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'E'
          else
            tempArray[r][c] := 'L';
        end
        else if (perlinArray[r][c] = '6') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'F'
          else
            tempArray[r][c] := 'M';
        end
        else if (perlinArray[r][c] = '7') then
        begin
          if (tempArray[r][c] = '*') then
            tempArray[r][c] := 'G'
          else
            tempArray[r][c] := 'N';
        end;
      end;
    end;

    (* Copy temporary map back to terrain array *)
    for r := 1 to MAXR do
    begin
      for c := 1 to MAXC do
      begin
        terrainArray[r][c] := tempArray[r][c];
      end;
    end;

 (* Draw outline of island *)
 for r := 1 to MAXR do
  begin
    for c := 1 to MAXC do
    begin
      if (islandOutline[r][c] = '*') then
         terrainArray[r][c] := '~'
      else if (islandOutline[r][c] = '+') then
         terrainArray[r][c] := '-'
      else if (islandOutline[r][c] = 'C') then
         terrainArray[r][c] := chr(5);
    end;
  end;
 (* Place the first location *)
 terrainArray[globalUtils.OWy][globalUtils.OWx] := '>';
 (* Create rest of locations *)
 architect.seedLocations;
 (* Store the island *)
 island.storeEllanToll;
end;
end.
