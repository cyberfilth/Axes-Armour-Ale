(* Screen used for Look command and Throwing projectiles *)

unit scrTargeting;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Classes, Math, map, entities, video, ui, camera, fov, items, los,
  scrGame, player_stats, crude_dagger, basic_club, staff_minor_scorch;

type
  (* Weapons *)
  Equipment = record
    id, baseDMG: smallint;
    mnuOption: char;
    Name, glyph, glyphColour: shortstring;
    onGround, equppd: boolean;
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
  maxWeapons = 11;

var
  (* Target coordinates *)
  targetX, targetY: smallint;
  (* The last safe coordinates *)
  safeX, safeY: smallint;
  (* Throwable items *)
  throwableWeapons: array[0..maxWeapons] of Equipment;
  weaponAmount, selectedTarget, tgtAmount: smallint;
  (* Selected projectile *)
  chosenProjectile: smallint;
  (* List of projectile targets *)
  tgtList: array of TthrowTargets;
  (* Coordinates where the projectile lands *)
  landingX, landingY: smallint;

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
(* Remove a thrown item from the ground *)
procedure removeFromGround;
(* Remove a thrown item from inventory *)
procedure removeThrownFromInventory;
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
  for b := 0 to maxWeapons do
  begin
    throwableWeapons[b].id := b;
    throwableWeapons[b].Name := empty;
    throwableWeapons[b].mnuOption := 'x';
    throwableWeapons[b].baseDMG := 0;
    throwableWeapons[b].glyph := 'x';
    throwableWeapons[b].glyphColour := 'x';
    throwableWeapons[b].onGround := False;
    throwableWeapons[b].equppd := False;
  end;
  (* Check inventory for an item to throw *)
  for b := 0 to maxWeapons - 1 do
  begin
    if (inventory[b].throwable = True) then
    begin
      (* Add to list of throwable weapons *)
      throwableWeapons[b].id := inventory[b].id;
      throwableWeapons[b].Name := inventory[b].Name;
      throwableWeapons[b].mnuOption := mnuChar;
      throwableWeapons[b].baseDMG := inventory[b].throwDamage;
      throwableWeapons[b].glyph := inventory[b].glyph;
      throwableWeapons[b].glyphColour := inventory[b].glyphColour;
      throwableWeapons[b].onGround := False;
      if (inventory[b].equipped = True) then
         throwableWeapons[b].equppd := True
      else
        throwableWeapons[b].equppd := False;
      Inc(mnuChar);
      Inc(weaponAmount);
      projectileAvailable := True;
    end;
  end;

  (* Check the ground under the player for an item to throw *)
  if (items.containsItem(entityList[0].posX, entityList[0].posY) = True) and (items.isItemThrowable(entityList[0].posX, entityList[0].posY) = True) then
  begin
      (* Add to list of throwable weapons *)
      throwableWeapons[b].id := items.getItemID(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].Name := items.getItemName(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].mnuOption := mnuChar;
      throwableWeapons[b].baseDMG := items.getThrowDamage(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].glyph := items.getItemGlyph(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].glyphColour := items.getItemColour(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].onGround := True;
      throwableWeapons[b].equppd := False;
      Inc(weaponAmount);
      projectileAvailable := True;
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
  for i := 0 to maxWeapons do
  begin
    if (throwableWeapons[i].mnuOption = selection) then
    begin
      chosenProjectile := i;
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
    for i := 0 to maxWeapons do
    begin
      if (throwableWeapons[i].Name <> empty) then
      begin
        if (throwableWeapons[i].equppd = True) then
           TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name + ' [equipped]')
        else if (throwableWeapons[i].onGround = True) then
          TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name + ' [on the ground]')
        else
          TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name);
        Inc(yPOS);
      end;
    end;

    (* Get the range of choices *)
    for i := 0 to maxWeapons do
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
var
  tgtDistance, dex, damage, dmgAmount, diff, i: smallint;
  opponent: shortstring;
begin
  (* Initialise variables *)
  landingX := 0;
  landingY := 0;
  (* Get the opponents name *)
  opponent := entityList[tgtList[selectedTarget].id].race;
  if (entityList[tgtList[selectedTarget].id].article = True) then
    opponent := 'the ' + opponent;

  (* Attacking an NPC automatically makes it hostile *)
  entityList[tgtList[selectedTarget].id].state := stateHostile;
  (* Number of turns NPC will follow you if out of sight *)
  entityList[tgtList[selectedTarget].id].moveCount := 10;

  (* Calculate damage caused *)

  { Convert distance to target from real number to integer }
   tgtDistance := round(tgtList[selectedTarget].distance);
  { Get the players Dexterity }
  dex := player_stats.dexterity;
  { if dex > tgtDistance = the remainder is added to projectile damage
    if dex < tgtDistance = the difference is removed from the damage.
    Closer targets take more damage                                    }
  damage := throwableWeapons[chosenProjectile].baseDMG;
  (* Add the difference to damage *)
  if (dex > tgtDistance) then
  begin
    diff := dex - tgtDistance;
    Inc(damage, diff);
  end
  else
  (* Subtract the difference from damage *)
  begin
    diff := dex - tgtDistance;
    if (diff > 0) and (diff < damage) then
       Dec(damage, diff)
    else
      begin
        diff := 0;
        damage := 0;
      end;
  end;

  (* Calculate the path of the projectile *)
  los.playerProjectilePath(entityList[0].posX, entityList[0].posY, tgtList[selectedTarget].x, tgtList[selectedTarget].y, throwableWeapons[chosenProjectile].glyph, throwableWeapons[chosenProjectile].glyphColour);

  (* Apply damage *)
  if (damage = 0) then
     ui.bufferMessage('The ' + throwableWeapons[chosenProjectile].Name + ' misses')
  else
    begin
      dmgAmount := damage - entityList[tgtList[selectedTarget].id].defence;
      (* If it was a hit *)
      if ((dmgAmount - entityList[0].tmrDrunk) > 0) then
      begin
        Dec(entityList[tgtList[selectedTarget].id].currentHP, dmgAmount);
        (* If it was a killing blow *)
        if (entityList[tgtList[selectedTarget].id].currentHP < 1) then
        begin
          ui.writeBufferedMessages;
          ui.bufferMessage('You kill ' + opponent);
          entities.killEntity(tgtList[selectedTarget].id);
          entityList[0].xpReward := entities.entityList[0].xpReward + entityList[tgtList[selectedTarget].id].xpReward;
          ui.updateXP;
          LockScreenUpdate;
          (* Restore the game map *)
          main.returnToGameScreen;
          (* Restore screen *)
          paintOverMsg;
          ui.restoreMessages;
          UnlockScreenUpdate;
          UpdateScreen(False);
          main.gameState := stGame;
        end
        else
            ui.bufferMessage('The ' + throwableWeapons[chosenProjectile].Name + ' hits ' + opponent);
      end
      else
         ui.bufferMessage('The ' + throwableWeapons[chosenProjectile].Name + ' doesn''t injure ' + opponent);
    end;

  (* Remove item from ground or inventory *)
  if (throwableWeapons[chosenProjectile].onGround = True) then
    removeFromGround
  else
    removeThrownFromInventory;

  ui.writeBufferedMessages;

  LockScreenUpdate;
  (* Restore the game map *)
  main.returnToGameScreen;
  (* Restore screen *)
  paintOverMsg;
  ui.restoreMessages;

  (* Redraw all NPC's *)
    for i := 1 to entities.npcAmount do
      entities.redrawMapDisplay(i);
  UnlockScreenUpdate;
  UpdateScreen(False);
  main.gameState := stGame;
  main.gameLoop;
 end;

procedure removeFromGround;
var
  i, itmID: smallint;
begin
  i := 0;
  for i := 0 to High(itemList) do
    if (entityList[0].posX = itemList[i].posX) and (entityList[0].posY = itemList[i].posY) and (itemList[i].onMap = True) then
       itmID := i;

   (* Weapon damage for edged weapons *)
  case itemList[i].useID of
       2: crude_dagger.thrownDamaged(i, False);
  end;

  (* Rocks break on impact *)
  if (itemList[itmID].itemName <> 'rock') then
  begin
       itemList[itmID].posX:=landingX;
       itemList[itmID].posY:=landingY;
  end
  else
  begin
(* Set an empty flag for the rock on the map, this gets deleted when saving the map *)
  with itemList[itmID] do
      begin
        itemName := 'empty';
        itemDescription := '';
        itemArticle := '';
        itemType := itmEmptySlot;
        itemMaterial := matEmpty;
        useID := 1;
        glyph := 'x';
        glyphColour := 'lightCyan';
        inView := False;
        posX := 1;
        posY := 1;
        NumberOfUses := 0;
        onMap := False;
        throwable := False;
        throwDamage := 0;
        discovered := False;
      end;
  ui.bufferMessage('The rock breaks on impact');
  end;
end;

procedure removeThrownFromInventory;
var
  itemNumber, dmgID: smallint;
  newItem: Item;
begin
  itemNumber := throwableWeapons[chosenProjectile].id;
  dmgID := player_inventory.inventory[itemNumber].id;

  (* Weapon damage for edged weapons *)
  case player_inventory.inventory[itemNumber].useID of
       2: crude_dagger.thrownDamaged(dmgID, True);
  end;

  (* Rocks break on impact *)
  if (throwableWeapons[chosenProjectile].Name <> 'rock') then
  { Create an item }
  begin
    newItem.itemID := indexID;
    newItem.itemName := player_inventory.inventory[itemNumber].Name;
    newItem.itemDescription := player_inventory.inventory[itemNumber].description;
    newItem.itemArticle := player_inventory.inventory[itemNumber].article;
    newItem.itemType := player_inventory.inventory[itemNumber].itemType;
    newItem.itemMaterial := player_inventory.inventory[itemNumber].itemMaterial;
    newItem.useID := player_inventory.inventory[itemNumber].useID;
    newItem.glyph := player_inventory.inventory[itemNumber].glyph;
    newItem.glyphColour := player_inventory.inventory[itemNumber].glyphColour;
    newItem.inView := True;
    newItem.posX := landingX;
    newItem.posY := landingY;
    newItem.NumberOfUses := player_inventory.inventory[itemNumber].numUses;
    newItem.onMap := True;
    newItem.throwable := player_inventory.inventory[itemNumber].throwable;
    newItem.throwDamage := player_inventory.inventory[itemNumber].throwDamage;
    newItem.discovered := True;
    Inc(indexID);

  { Place item on the game map }
  SetLength(itemList, Length(itemList) + 1);
  Insert(newitem, itemList, Length(itemList));
  end
  else
      ui.bufferMessage('The rock breaks on impact');

  (* Unequip weapon if equipped *)
  if (throwableWeapons[chosenProjectile].equppd = True) then
  begin
       case player_inventory.inventory[itemNumber].useID of
         2: crude_dagger.throw;
         4: basic_club.throw;
         8: staff_minor_scorch.throw;
       end;
  end;

  (* Remove from inventory *)
  player_inventory.inventory[itemNumber].Name := 'Empty';
  player_inventory.inventory[itemNumber].equipped := False;
  player_inventory.inventory[itemNumber].description := 'x';
  player_inventory.inventory[itemNumber].article := 'x';
  player_inventory.inventory[itemNumber].itemType := itmEmptySlot;
  player_inventory.inventory[itemNumber].itemMaterial := matEmpty;
  player_inventory.inventory[itemNumber].glyph := 'x';
  player_inventory.inventory[itemNumber].glyphColour := 'x';
  player_inventory.inventory[itemNumber].inInventory := False;
  player_inventory.inventory[itemNumber].numUses := 0;
  player_inventory.inventory[itemNumber].throwable := False;
  player_inventory.inventory[itemNumber].throwDamage := 0;
  player_inventory.inventory[itemNumber].useID := 0;
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
