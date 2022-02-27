(* Screen used for Look and targeting *)

unit scrTargeting;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Classes, Math, map, entities, video, ui, camera, fov, items, los, scrGame;

type
  (* Weapons *)
  Equipment = record
    id, baseDMG: smallint;
    mnuOption: char;
    Name, glyph, glyphColour: shortstring;
  end;

type
  (* Enemies *)
  TthrowTargets = record
    id, x, y: smallint;
    distance: single;
    Name: string;
  end;

const
  empty = 'xxx';

var
  (* Target coordinates *)
  targetX, targetY: smallint;
  (* The last safe coordinates *)
  safeX, safeY: smallint;
  (* Throwable items *)
  throwableWeapons: array[0..10] of Equipment;
  weaponAmount, selectedTarget, tgtAmount: smallint;
  (* Selected projectile *)
  chosenProjectile: smallint;
  (* List of projectile targets *)
  tgtList: array of TthrowTargets;

(* Look around the map *)
procedure look(dir: word);
(* Confirm there are NPC's and projectiles *)
function canThrow(): boolean;
(* Check if the projectile selection is valid *)
function validProjectile(selection: char): boolean;
(* Choose target for projectile *)
procedure projectileTarget;
(* Cycle between the targets *)
procedure cycleTargets(selection: smallint);
(* Start the Target / Throw process *)
procedure target;
(* Throw projectile at confirmed target *)
procedure chuckProjectile;
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
  TextOut(centreX('[x] to exit the Look screen'), 24, 'lightGrey', '[x] to exit the Look screen');
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
        healthMsg := 'Health: ' + IntToStr(entities.getCreatureHP(targetX, targetY)) + '/' + IntToStr(entities.getCreatureMaxHP(targetX, targetY));
        playerName := entityList[0].race + ' the ' + entityList[0].description;
        TextOut(centreX(playerName), 21, 'white', playerName);
        TextOut(centreX(healthMsg), 22, 'white', healthMsg);
      end
      else
      (* If another entity *)
      begin
        healthMsg := 'Health: ' + IntToStr(entities.getCreatureHP(targetX, targetY)) + '/' + IntToStr(entities.getCreatureMaxHP(targetX, targetY));
        TextOut(centreX(entities.getCreatureDescription(targetX, targetY)),
          21, 'white', entities.getCreatureDescription(targetX, targetY));
        TextOut(centreX(healthMsg), 22, 'white', healthMsg);
      end;
    end
    (* else to see if an item is under the cursor *)
    else if (items.containsItem(targetX, targetY) = True) then
    begin
      TextOut(centreX(getItemName(targetX, targetY)), 21, 'white', getItemName(targetX, targetY));
      TextOut(centreX(getItemDescription(targetX, targetY)), 22, 'white', getItemDescription(targetX, targetY));
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

  (* Initialise array *)
  for b := 0 to 10 do
  begin
    throwableWeapons[b].id := b;
    throwableWeapons[b].Name := empty;
    throwableWeapons[b].mnuOption := 'x';
    throwableWeapons[b].baseDMG := 0;
    throwableWeapons[b].glyph := 'x';
    throwableWeapons[b].glyphColour := 'x';
  end;
  (* Check inventory for an item to throw *)
  for b := 0 to 10 do
  begin
    if (inventory[b].throwable = True) and (inventory[b].equipped = False) then
    begin
      (* Add to list of throwable weapons *)
      throwableWeapons[b].id := inventory[b].id;
      throwableWeapons[b].Name := inventory[b].Name;
      throwableWeapons[b].mnuOption := mnuChar;
      throwableWeapons[b].baseDMG := inventory[b].throwDamage;
      throwableWeapons[b].glyph := inventory[b].glyph;
      throwableWeapons[b].glyphColour := inventory[b].glyphColour;
      Inc(mnuChar);
      Inc(weaponAmount);
      projectileAvailable := True;
    end;
  end;
  (* Check the ground under the player for an item to throw *)
  if (items.containsItem(entityList[0].posX, entityList[0].posY) = True) then
  begin
    if (items.isItemThrowable(entityList[0].posX, entityList[0].posY) = True) then
      (* Add to list of throwable weapons *)
    begin
      throwableWeapons[b].id := items.getItemID(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].Name := items.getItemName(entityList[0].posX, entityList[0].posY) + ' (on the ground)';
      throwableWeapons[b].mnuOption := mnuChar;
      throwableWeapons[b].baseDMG := items.getThrowDamage(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].glyph := items.getItemGlyph(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].glyphColour := items.getItemColour(entityList[0].posX, entityList[0].posY);
      Inc(weaponAmount);
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
      NPCinRange := True;
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

function validProjectile(selection: char): boolean;
var
  i: byte;
begin
  Result := False;
  for i := 0 to 10 do
  begin
    if (throwableWeapons[i].mnuOption = selection) then
    begin
      chosenProjectile := throwableWeapons[i].id;
      Result := True;
      gameState := stTarget;
    end;
  end;
end;

procedure projectileTarget;
var
  i, dx, dy, closestID: smallint;
  i3: single;
begin
  LockScreenUpdate;
  (* Clear the message log *)
  paintOverMsg;
  (*  Initialise variables and array *)
  i := 0;
  i3 := 30.0;
  tgtAmount := 1;
  closestID := 0;
  SetLength(tgtList, 0);

  (* Check if any enemies are near *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      (* Add NPC to list of targets *)
      SetLength(tgtList, tgtAmount);
      tgtList[tgtAmount - 1].id := i;
      tgtList[tgtAmount - 1].x := entityList[i].posX;
      tgtList[tgtAmount - 1].y := entityList[i].posY;
      tgtList[tgtAmount - 1].Name := entityList[i].race;
      (* Calculate distance from the player *)
      dx := entityList[0].posX - entityList[i].posX;
      dy := entityList[0].posY - entityList[i].posY;
      (* Add the distance to the array *)
      tgtList[tgtAmount - 1].distance := sqrt(dx ** 2 + dy ** 2);
      Inc(tgtAmount);
    end;
  end;

  (* Get the closest target *)
  for i := Low(tgtList) to High(tgtList) do
  begin
    if (tgtList[i].distance < i3) and (tgtList[i].Name <> empty) then
    begin
      i3 := tgtList[i].distance;
      closestID := i;
    end;
  end;
  selectedTarget := closestID;
  cycleTargets(closestID);
end;

procedure cycleTargets(selection: smallint);
var
  i: smallint;
  targetName: string;
begin
  gameState := stSelectTarget;
  targetName := '';
  ui.clearPopup;
  paintOverMsg;
  (* Redraw all NPC's *)
  for i := 1 to entities.npcAmount do
    entities.redrawMapDisplay(i);
  (* Redraw all items *)
  items.redrawItems;

  if (selection < 900) then
    (* Highlight the closest NPC *)
    targetName := tgtList[selection].Name

  (* Cycle through the NPC's to beginning of list *)
  else if (selection = 999) then
  begin
    if (selectedTarget > Low(tgtList)) then
    begin
      Dec(selectedTarget);
      targetName := tgtList[selectedTarget].Name;
    end
    else
    begin
      selectedTarget := High(tgtList);
      targetName := tgtList[selectedTarget].Name;
    end;
  end
  (* Cycle through the NPC's to end of list *)
  else if (selection = 998) then
  begin
    if (selectedTarget < High(tgtList)) then
    begin
      Inc(selectedTarget);
      targetName := tgtList[selectedTarget].Name;
    end
    else
    begin
      selectedTarget := Low(tgtList);
      targetName := tgtList[selectedTarget].Name;
    end;
  end;

  (* Highlight the targeted NPC *)
  map.mapDisplay[tgtList[selectedTarget].y, tgtList[selectedTarget].x].GlyphColour := 'pinkBlink';
  (* Help text *)
  TextOut(centreX(targetName), 22, 'white', targetName);
  TextOut(centreX('Left and Right to cycle between targets'), 23, 'lightGrey', 'Left and Right to cycle between targets');
  TextOut(centreX('[t] Throw ' + throwableWeapons[chosenProjectile].Name + '  |  [x] Cancel'), 24, 'lightGrey', '[t] Throw ' + throwableWeapons[chosenProjectile].Name + '  |  [x] Cancel');

  (* Repaint map *)
  camera.drawMap;
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure target;
var
  i, yPOS: byte;
  lastOption: char;
  targetOptsMessage: string;
begin
  LockScreenUpdate;
  (* Clear the message log *)
  paintOverMsg;
  (* Initialise variables *)
  yPOS := 0;
  weaponAmount := 0;
  lastOption := 'a';
  targetOptsMessage := 'Select something to throw';

  (* Check if player can throw something at someone *)
  if (canThrow() = True) then
  begin
    (* Display list of items for player to select *)
    yPOS := (19 - weaponAmount);
    for i := 0 to 10 do
    begin
      if (throwableWeapons[i].Name <> empty) then
      begin
        TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name);
        Inc(yPOS);
      end;
    end;

    (* Get the range of choices *)
    for i := 0 to 10 do
    begin
      if (throwableWeapons[i].Name <> empty) then
        lastOption := throwableWeapons[i].mnuOption;
    end;
    if (lastOption <> 'a') then
      targetOptsMessage := 'a - ' + lastOption + ' to select something to throw';

    TextOut(centreX(targetOptsMessage), 23, 'white', targetOptsMessage);
    TextOut(centreX('[x] to exit the Throw screen'), 24, 'lightGrey', '[x] to exit the Throw screen');
    UnlockScreenUpdate;
    UpdateScreen(False);
    (* Wait for selection *)
    gameState := stSelectAmmo;
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

procedure chuckProjectile;
begin

  (* Calculate damage caused *)

  (* Calculate the path of the projectile *)
  los.playerProjectilePath(entityList[0].posX, entityList[0].posY, tgtList[selectedTarget].x, tgtList[selectedTarget].y, throwableWeapons[chosenProjectile].glyph, throwableWeapons[chosenProjectile].glyphColour);

  LockScreenUpdate;
  (* Restore the game map *)
  main.returnToGameScreen;
  (* Restore screen *)
  paintOverMsg;
  ui.restoreMessages;
  UnlockScreenUpdate;
  UpdateScreen(False);
  main.gameState := stGame;
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
  for y := 21 to 25 do
  begin
    for x := 1 to scrGame.minX do
    begin
      TextOut(x, y, 'black', ' ');
    end;
  end;
end;

end.
