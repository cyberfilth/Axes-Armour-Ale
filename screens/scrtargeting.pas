(* Screen used for Look and targeting *)

unit scrTargeting;

{$mode fpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Classes, map, entities, video, ui, camera, fov, items, scrGame;

type
  (* Weapons *)
  Equipment = record
    id: smallint;
    Name, glyph, glyphColour: shortstring;
  end;

type
  TSmallintArray = array of smallint;

var
  (* Target coordinates *)
  targetX, targetY: smallint;
  (* The last safe coordinates *)
  safeX, safeY: smallint;
  (* Path of projectiles *)
  targetArray: array[1..30] of TPoint;

(* Look around the map *)
procedure look(dir: word);
(* Target something on the map, reusable for missiles & spells *)
procedure target(dir: word; Xcolour: shortstring);
(* Draws a Bresenham line between the player and the target *)
procedure firingLine(Xcol: shortstring; x1, y1, x2, y2: smallint);
(* Repaint the player when exiting look/target screen *)
procedure restorePlayerGlyph;
(* Paint over the message log *)
procedure paintOverMsg;

implementation

uses
  player_inventory, main;

procedure look(dir: word);
var
  i: byte;
  healthMsg, playerName: shortstring;
begin
  LockScreenUpdate;
  (* Clear the message log *)
  paintOverMsg;
  (* Display hint text *)
  TextOut(centreX('[x] to exit the Look screen'), 24, 'lightGrey',
    '[x] to exit the Look screen');
  (* Turn player glyph to an X *)
  entityList[0].glyph := 'X';
  entityList[0].glyphColour := 'white';

  if (dir <> 0) then
  begin
    case dir of
      { N }
      1: Dec(targetY);
      { W }
      2: Dec(targetX);
      { S }
      3: Inc(targetY);
      { E }
      4: Inc(targetX);
      {NE}
      5:
      begin
        Inc(targetX);
        Dec(targetY);
      end;
      { SE }
      6:
      begin
        Inc(targetX);
        Inc(targetY);
      end;
      { SW }
      7:
      begin
        Dec(targetX);
        Inc(targetY);
      end;
      { NW }
      8:
      begin
        Dec(targetX);
        Dec(targetY);
      end;
    end;
    if (map.withinBounds(targetX, targetY) = False) or
      (map.maparea[targetY, targetX].Visible = False) then
    begin
      targetX := safeX;
      targetY := safeY;
    end;

    (* Redraw all NPC's *)
    for i := 1 to entities.npcAmount do
      entities.redrawMapDisplay(i);
    (* Redraw all items *)
    items.redrawItems;
    (* Draw X on target *)
    map.mapDisplay[targetY, targetX].GlyphColour := 'white';
    map.mapDisplay[targetY, targetX].Glyph := 'X';

    (* Check to see if an entity is under the cursor *)
    if (map.isOccupied(targetX, targetY) = True) then
    begin
      (* Check to see if the entity is the player *)
      if (entities.getCreatureID(targetX, targetY) = 0) then
      begin
        healthMsg := 'Health: ' + IntToStr(entities.getCreatureHP(targetX, targetY)) +
          '/' + IntToStr(entities.getCreatureMaxHP(targetX, targetY));
        playerName := entityList[0].race + ' the ' + entityList[0].description;
        TextOut(centreX(playerName), 21, 'white', playerName);
        TextOut(centreX(healthMsg), 22, 'white', healthMsg);
      end
      else
        (* If another entity *)
      begin
        healthMsg := 'Health: ' + IntToStr(entities.getCreatureHP(targetX, targetY)) +
          '/' + IntToStr(entities.getCreatureMaxHP(targetX, targetY));
        TextOut(centreX(entities.getCreatureDescription(targetX, targetY)),
          21, 'white', entities.getCreatureDescription(targetX, targetY));
        TextOut(centreX(healthMsg), 22, 'white', healthMsg);
      end;
    end
    (* else to see if an item is under the cursor *)
    else if (items.containsItem(targetX, targetY) = True) then
    begin
      TextOut(centreX(getItemName(targetX, targetY)), 21, 'white',
        getItemName(targetX, targetY));
      TextOut(centreX(getItemDescription(targetX, targetY)), 22,
        'white', getItemDescription(targetX, targetY));
    end
    (* else describe the terrain *)
    else if (map.maparea[targetY, targetX].Glyph = '.') then
      TextOut(centreX('floor'), 21, 'lightGrey', 'floor')
    else if (map.maparea[targetY, targetX].Glyph = '*') then
      TextOut(centreX('floor'), 21, 'lightGrey', 'cave wall')
    else if (map.maparea[targetY, targetX].Glyph = '<') then
      TextOut(centreX('floor'), 21, 'lightGrey', 'stairs leading up')
    else if (map.maparea[targetY, targetX].Glyph = '>') then
      TextOut(centreX('floor'), 21, 'lightGrey', 'stairs leading down');
  end;

  (* Repaint map *)
  camera.drawMap;
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  UnlockScreenUpdate;
  UpdateScreen(False);
  (* Store the coordinates, so the cursor doesn't get lost off screen *)
  safeX := targetX;
  safeY := targetY;
end;

procedure target(dir: word; Xcolour: shortstring);
var
  i, b: byte;
  (* Is there anything in the inventory to throw *)
  invThrow: boolean;
  (* Is there anything on the ground to throw *)
  groundThrow: boolean;
  anyTargetHit: boolean;
  (* Throwable items *)
  inventoryWeapons: array[0..9] of Equipment;
  (* Potential targets *)
  targetList: TSmallintArray;
  targetAmount: smallint;
begin
  LockScreenUpdate;
  (* Clear the message log *)
  paintOverMsg;
  (* Initialise variables *)
  invThrow := False;
  groundThrow := False;
  anyTargetHit := False;
  i := 0;
  b := 0;
  (*  Set array to 0 *)
  SetLength(targetList, 0);
  (* Initialise array *)
  for b := 0 to 9 do
  begin
    inventoryWeapons[b].id := b;
    inventoryWeapons[b].Name := 'Empty';
    inventoryWeapons[b].glyph := 'x';
    inventoryWeapons[b].glyphColour := 'x';
  end;
  (* Check inventory for an item to throw *)
  for b := 0 to 9 do
  begin
    if (inventory[b].itemType = itmWeapon) and (inventory[b].equipped = False) then
    begin
      inventoryWeapons[b].id := inventory[b].id;
      inventoryWeapons[b].Name := inventory[b].Name;
      inventoryWeapons[b].glyph := inventory[b].glyph;
      inventoryWeapons[b].glyphColour := inventory[b].glyphColour;
      invThrow := True;
    end;
  end;
  (* Check the ground under the player for an item to throw *)
  if (items.containsItem(entityList[0].posX, entityList[0].posY) = True) then
  begin
    if (items.isItemWeapon(entityList[0].posX, entityList[0].posY) = True) then
      groundThrow := True;
  end;

  (* Check to see if player has anything to throw *)
  if (invThrow = False) and (groundThrow = False) then
  begin
    ui.displayMessage('You have nothing to throw');
    restorePlayerGlyph;
    UnlockScreenUpdate;
    UpdateScreen(False);
    main.gameState := stGame;
    exit;
  end;

  (* Get a list of all entities in view *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      anyTargetHit := True;
      (* Add NPC to list of targets *)
      SetLength(targetList, targetAmount);
      targetList[targetAmount - 1] := i;
      Inc(targetAmount);
    end;
  end;
  (* If there are no entities in view, exit *)
  if (anyTargetHit = False) then
  begin
    ui.displayMessage('There are no enemies in sight');
    restorePlayerGlyph;
    UnlockScreenUpdate;
    UpdateScreen(False);
    main.gameState := stGame;
    exit;
  end;
  (* Display list of items for player to select *)

  (* Cycle through entities with Left and Right *)


  (* Display hint text *)
  TextOut(centreX('[x] to exit the Look screen'), 24, 'lightGrey',
    '[x] to exit the Target screen');

  (* Turn player glyph to an + *)
  entityList[0].glyph := '+';
  entityList[0].glyphColour := Xcolour;

  if (dir <> 0) then
  begin
    case dir of
      { N }
      1: Dec(targetY);
      { W }
      2: Dec(targetX);
      { S }
      3: Inc(targetY);
      { E }
      4: Inc(targetX);
      {NE}
      5:
      begin
        Inc(targetX);
        Dec(targetY);
      end;
      { SE }
      6:
      begin
        Inc(targetX);
        Inc(targetY);
      end;
      { SW }
      7:
      begin
        Dec(targetX);
        Inc(targetY);
      end;
      { NW }
      8:
      begin
        Dec(targetX);
        Dec(targetY);
      end;
    end;
    if (map.withinBounds(targetX, targetY) = False) or
      (map.maparea[targetY, targetX].Visible = False) then
    begin
      targetX := safeX;
      targetY := safeY;
    end;
  end;
  (* Redraw all NPC's *)
  for i := 1 to entities.npcAmount do
    entities.redrawMapDisplay(i);
  (* Draw a cross on target *)
  map.mapDisplay[targetY, targetX].GlyphColour := Xcolour;
  map.mapDisplay[targetY, targetX].Glyph := '+';
  (* Draw a bresenham line of circles between the 2 points *)
  firingLine(Xcolour, entityList[0].posX, entityList[0].posY, targetX, targetY);

  (* Repaint map *)
  camera.drawMap;
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  UnlockScreenUpdate;
  UpdateScreen(False);
  (* Store the coordinates, so the cursor doesn't get lost off screen *)
  safeX := targetX;
  safeY := targetY;
end;

procedure firingLine(Xcol: shortstring; x1, y1, x2, y2: smallint);
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: smallint;
begin
  (* Initialise array *)
  for i := 1 to 10 do
  begin
    targetArray[i].X := 0;
    targetArray[i].Y := 0;
  end;
  (* Calculate delta X and delta Y for initialisation *)
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);
  (* Initialise all vars based on which is the independent variable *)
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
  for i := 1 to numpixels do
  begin
    (* Check that we are not searching out of bounds of map *)
    if (map.withinBounds(x, y) = True) then
    begin
      (* Add coordinates to the array *)
      targetArray[i].X := x;
      targetArray[i].Y := y;
      (* Draw the path on the screen *)
      map.mapDisplay[y, x].GlyphColour := Xcol;
      map.mapDisplay[y, x].Glyph := '+';
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

procedure restorePlayerGlyph;
begin
  LockScreenUpdate;
  entityList[0].glyph := '@';
  if (entityList[0].stsPoison = True) then
    entityList[0].glyphColour := 'green'
  else
    entityList[0].glyphColour := 'yellow';
  (* Repaint the message log *)
  paintOverMsg;
  ui.restoreMessages;
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure paintOverMsg;
var
  x, y: smallint;
begin
  for y := 21 to 25 do
  begin
    for x := 1 to scrGame.minX do
    begin
      TextOut(x, y, 'black', ' ');
    end;
  end;
end;

end.
