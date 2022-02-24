(* Screen used for Look and targeting *)

unit scrTargeting;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Classes, map, entities, video, ui, camera, fov, items, scrGame;

type
  (* Weapons *)
  Equipment = record
    id, baseDMG: smallint;
    mnuOption: char;
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
  (* Throwable items *)
  inventoryWeapons: array[0..9] of Equipment;
  (* Potential targets *)
  targetList: TSmallintArray;
  targetAmount, weaponAmount: smallint;

(* Look around the map *)
procedure look(dir: word);
(* Confirm there are NPC's and projectiles *)
function canThrow(): boolean;
(* Check if the projectile selection is valid *)

(* Target something on the map, reusable for missiles & spells *)
procedure target(dir: word; Xcolour: shortstring);
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

function canThrow(): boolean;
var
   projectileAvailable, NPCinRange: boolean;
   i, b: byte;
   mnuChar: char;
begin
  (* Initialise variables *)
  projectileAvailable := False;
  NPCinRange := False;
  i := 0;
  b := 0;
  mnuChar := 'a';
  Result := False;

  {       Check for projectiles     }

  (*  Set array to 0 *)
  SetLength(targetList, 0);
  (* Initialise array *)
  for b := 0 to 9 do
  begin
    inventoryWeapons[b].id := b;
    inventoryWeapons[b].Name := 'Empty';
    inventoryWeapons[b].mnuOption := 'x';
    inventoryWeapons[b].baseDMG := 0;
    inventoryWeapons[b].glyph := 'x';
    inventoryWeapons[b].glyphColour := 'x';
  end;
  (* Check inventory for an item to throw *)
  for b := 0 to 9 do
  begin
    if (inventory[b].throwable = True) and (inventory[b].equipped = False) then
    begin
      inventoryWeapons[b].id := inventory[b].id;
      inventoryWeapons[b].Name := inventory[b].Name;
      inventoryWeapons[b].mnuOption := mnuChar;
      inventoryWeapons[b].baseDMG := inventory[b].throwDamage;
      inventoryWeapons[b].glyph := inventory[b].glyph;
      inventoryWeapons[b].glyphColour := inventory[b].glyphColour;
      Inc(mnuChar);
      projectileAvailable := True;
    end;
  end;
  (* Check the ground under the player for an item to throw *)
  if (items.containsItem(entityList[0].posX, entityList[0].posY) = True) then
  begin
    if (items.isItemThrowable(entityList[0].posX, entityList[0].posY) = True) then
    begin
      inventoryWeapons[b].id := items.getItemID(entityList[0].posX, entityList[0].posY);
      inventoryWeapons[b].Name := items.getItemName(entityList[0].posX, entityList[0].posY) + ' (on the ground)';
      inventoryWeapons[b].mnuOption := mnuChar;
      inventoryWeapons[b].baseDMG := items.getThrowDamage(entityList[0].posX, entityList[0].posY);
      inventoryWeapons[b].glyph := items.getItemGlyph(entityList[0].posX, entityList[0].posY);
      inventoryWeapons[b].glyphColour := items.getItemColour(entityList[0].posX, entityList[0].posY);
      projectileAvailable := True;
    end;
  end;
  (* If there are no projectiles available *)
  if (projectileAvailable = False) then
  begin
    ui.displayMessage('There is nothing you can throw');
    restorePlayerGlyph;
    (* Redraw all NPC's *)
    for i := 1 to entities.npcAmount do
      entities.redrawMapDisplay(i);
    (* Redraw all items *)
    items.redrawItems;
    UnlockScreenUpdate;
    UpdateScreen(False);
    main.gameState := stGame;
    exit;
  end;

    {       Check for NPC's in range     }

    (* Get a list of all entities in view *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      NPCinRange := True;
      (* Add NPC to list of targets *)
      SetLength(targetList, targetAmount);
      targetList[targetAmount - 1] := i;
      Inc(targetAmount);
    end;
  end;

  (* If there are no enemies in sight *)
  if (NPCinRange = False) then
  begin
    ui.displayMessage('There are no enemies in sight');
    restorePlayerGlyph;
    (* Redraw all NPC's *)
    for i := 1 to entities.npcAmount do
      entities.redrawMapDisplay(i);
    (* Redraw all items *)
    items.redrawItems;
    UnlockScreenUpdate;
    UpdateScreen(False);
    main.gameState := stGame;
    exit;
  end;

  (* Return True if there are projectiles and enemies *)
  if (projectileAvailable = True) and (NPCinRange = True) then
     Result := True;
end;

procedure target(dir: word; Xcolour: shortstring);
var
  i, b, yPOS: byte;
  (* Weapon selection options *)
  mnuChar, inputChar: char;
begin
  LockScreenUpdate;
  (* Clear the message log *)
  paintOverMsg;
  (* Initialise variables *)
  inputChar := 'a';
  targetAmount := 1;
  yPOS := 0;

  (* Check if can throw something at something *)
  if (canThrow() = True) then
  begin
  (* Display list of items for player to select *)
  yPOS := (19 - weaponAmount);
  for i := 0 to 9 do
  begin
    if (inventoryWeapons[i].Name <> 'Empty') then
    begin
      TextOut(10, yPOS, 'white', '[' + inventoryWeapons[i].mnuOption + '] ' + inventoryWeapons[i].Name);
      Inc(yPOS);
    end;
  end;

//
//  // update a global with total range of valid choices???
//  // then call this?
//
//  (* Wait for selection *)
//  gameState := stSelectAmmo;
//
//
//
//  (* Redraw the map *)
//
//
//  (* Cycle through entities with Left and Right *)
//
//  // entity changes to pinkBlink when selected
//
//
//
//
//  (* Display hint text *)
     TextOut(centreX('Select something to throw'), 23, 'white', 'Select something to throw');
     TextOut(centreX('[x] to exit the Throw screen'), 24, 'lightGrey', '[x] to exit the Throw screen');
//
//  (* Turn player glyph to an + *)
//  entityList[0].glyph := '+';
//  entityList[0].glyphColour := Xcolour;
//
//
//  if (dir <> 0) then
//  begin
//    case dir of
//      { N }
//      1: Dec(targetY);
//      { W }
//      2: Dec(targetX);
//      { S }
//      3: Inc(targetY);
//      { E }
//      4: Inc(targetX);
//      {NE}
//      5:
//      begin
//        Inc(targetX);
//        Dec(targetY);
//      end;
//      { SE }
//      6:
//      begin
//        Inc(targetX);
//        Inc(targetY);
//      end;
//      { SW }
//      7:
//      begin
//        Dec(targetX);
//        Inc(targetY);
//      end;
//      { NW }
//      8:
//      begin
//        Dec(targetX);
//        Dec(targetY);
//      end;
//    end;
//    if (map.withinBounds(targetX, targetY) = False) or
//      (map.maparea[targetY, targetX].Visible = False) then
//    begin
//      targetX := safeX;
//      targetY := safeY;
//    end;
//  end;
//  (* Redraw all NPC's *)
//  for i := 1 to entities.npcAmount do
//    entities.redrawMapDisplay(i);
//  (* Draw a cross on target *)
//  map.mapDisplay[targetY, targetX].GlyphColour := Xcolour;
//  map.mapDisplay[targetY, targetX].Glyph := '+';
//  (* Draw a bresenham line of circles between the 2 points *)
//  //firingLine(Xcolour, entityList[0].posX, entityList[0].posY, targetX, targetY);
//
  (* Repaint map *)
  //camera.drawMap;
  //fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  UnlockScreenUpdate;
  UpdateScreen(False);
  (* Store the coordinates, so the cursor doesn't get lost off screen *)
  safeX := targetX;
  safeY := targetY;



  end
  else
  begin
       (* Repaint map *)
       camera.drawMap;
       fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
       UnlockScreenUpdate;
       UpdateScreen(False);
       gameState := stGame;
       exit;
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
  (* Restore the game map *)
  camera.drawMap;
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
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
  for y := 20 to 25 do
  begin
    for x := 1 to scrGame.minX do
    begin
      TextOut(x, y, 'black', ' ');
    end;
  end;
end;

end.
