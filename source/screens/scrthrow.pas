(* Screen used for Throwing projectiles *)

unit scrThrow;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Math, video, map, camera, fov, los, ui, player_inventory, player_stats,
  items, entities, scrTargeting, crude_dagger, basic_club, staff_minor_scorch, pointy_stick;

type
  (* Enemies *)
  TthrowTargets = record
    id, x, y: smallint;
    distance: single;
    Name: string;
  end;

const
  maxWeapons = 11;

var
  (* Target coordinates *)
  throwX, throwY: smallint;
  selectedProjectile: smallint;
  (* List of projectile targets *)
  tgtList: array of TthrowTargets;
  (* Throwable items *)
  throwableWeapons: array[0..maxWeapons] of Equipment;
  NumOfWeapons, selTarget, NumOfTargets: smallint;

(* Confirm there are NPC's and projectiles *)
function canThrow: boolean;
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

implementation

uses
  main;

function canThrow: boolean;
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
  NumOfWeapons := 0;
  mnuChar := 'a';
  Result := False;

  {       Check for projectiles     }

  (* Initialise array *)
  for b := 0 to maxWeapons do
  begin
    throwableWeapons[b].playerInventoryID := 99;
    throwableWeapons[b].id := b;
    throwableWeapons[b].Name := scrTargeting.empty;
    throwableWeapons[b].mnuOption := 'x';
    throwableWeapons[b].baseDMG := 0;
    throwableWeapons[b].glyph := 'x';
    throwableWeapons[b].glyphColour := 'x';
    throwableWeapons[b].onGround := False;
    throwableWeapons[b].equppd := False;
  end;

  (* Check inventory for an item to throw *)
  for b := Low(throwableWeapons) to High(throwableWeapons) do
  begin
    if (inventory[b].throwable = True) then
    begin
      (* Add to list of throwable weapons *)
      throwableWeapons[b].playerInventoryID := b;
      throwableWeapons[b].id := player_inventory.inventory[b].id;
      throwableWeapons[b].Name := player_inventory.inventory[b].Name;
      throwableWeapons[b].mnuOption := mnuChar;
      throwableWeapons[b].baseDMG := player_inventory.inventory[b].throwDamage;
      throwableWeapons[b].glyph := player_inventory.inventory[b].glyph;
      throwableWeapons[b].glyphColour := player_inventory.inventory[b].glyphColour;
      throwableWeapons[b].onGround := False;
      if (player_inventory.inventory[b].equipped = True) then
         throwableWeapons[b].equppd := True
      else
        throwableWeapons[b].equppd := False;
      Inc(mnuChar);
      Inc(NumOfWeapons);
      projectileAvailable := True;
    end;
  end;

  (* Check the ground under the player for an item to throw *)
  if (items.containsItem(entityList[0].posX, entityList[0].posY) = True) and (items.isItemThrowable(entityList[0].posX, entityList[0].posY) = True) then
  begin
      (* Add to list of throwable weapons *)
      throwableWeapons[b].playerInventoryID := 99;
      throwableWeapons[b].id := items.getItemID(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].Name := items.getItemName(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].mnuOption := mnuChar;
      throwableWeapons[b].baseDMG := items.getThrowDamage(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].glyph := items.getItemGlyph(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].glyphColour := items.getItemColour(entityList[0].posX, entityList[0].posY);
      throwableWeapons[b].onGround := True;
      throwableWeapons[b].equppd := False;
      Inc(NumOfWeapons);
      projectileAvailable := True;
  end;

  (* If there are no projectiles available *)
  if (projectileAvailable = False) then
  begin
    ui.displayMessage('There is nothing you can throw');
    scrTargeting.restorePlayerGlyph;
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
    if (throwableWeapons[i].mnuOption = selection) and (throwableWeapons[i].Name <> '') then
    begin
      selectedProjectile := i;
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
  NumOfTargets := 1;
  closestID := 0;
  SetLength(tgtList, 0);

  (* Check if any enemies are near *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      (* Add NPC to list of targets *)
      SetLength(tgtList, NumOfTargets);
      tgtList[NumOfTargets - 1].id := i;
      tgtList[NumOfTargets - 1].x := entityList[i].posX;
      tgtList[NumOfTargets - 1].y := entityList[i].posY;
      tgtList[NumOfTargets - 1].Name := entityList[i].race;
      (* Calculate distance from the player *)
      dx := entityList[0].posX - entityList[i].posX;
      dy := entityList[0].posY - entityList[i].posY;
      (* Add the distance to the array *)
      tgtList[NumOfTargets - 1].distance := sqrt(dx ** 2 + dy ** 2);
      Inc(NumOfTargets);
    end;
  end;

  (* Get the closest target *)
  for i := Low(tgtList) to High(tgtList) do
  begin
    if (tgtList[i].distance < i3) and (tgtList[i].Name <> scrTargeting.empty) then
    begin
      i3 := tgtList[i].distance;
      closestID := i;
    end;
  end;
  selTarget := closestID;
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
    if (selTarget > Low(tgtList)) then
    begin
      Dec(selTarget);
      targetName := tgtList[selTarget].Name;
    end
    else
    begin
      selTarget := High(tgtList);
      targetName := tgtList[selTarget].Name;
    end;
  end
  (* Cycle through the NPC's to end of list *)
  else if (selection = 998) then
  begin
    if (selTarget < High(tgtList)) then
    begin
      Inc(selTarget);
      targetName := tgtList[selTarget].Name;
    end
    else
    begin
      selTarget := Low(tgtList);
      targetName := tgtList[selTarget].Name;
    end;
  end;

  (* Highlight the targeted NPC *)
  map.mapDisplay[tgtList[selTarget].y, tgtList[selTarget].x].GlyphColour := 'pinkBlink';
  (* Help text *)
  TextOut(centreX(targetName), 22, 'white', targetName);
  TextOut(centreX('Left and Right to cycle between targets'), 23, 'lightGrey', 'Left and Right to cycle between targets');
  TextOut(centreX('[t] Throw ' + throwableWeapons[selectedProjectile].Name + '  |  [x] Cancel'), 24, 'lightGrey', '[t] Throw ' + throwableWeapons[selectedProjectile].Name + '  |  [x] Cancel');

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
  NumOfWeapons := 0;
  lastOption := 'a';
  targetOptsMessage := 'Select something to throw';

  (* Check if player can throw something at someone *)
  if (canThrow = True) then
  begin
    (* Display list of items for player to select *)
    yPOS := (19 - NumOfWeapons);
    for i := 0 to maxWeapons do
    begin
      if (throwableWeapons[i].Name <> scrTargeting.empty) and (throwableWeapons[i].Name <> '') then
      begin
        if (throwableWeapons[i].equppd = True) then
           TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name + ' [equipped]')
        (* Projectiles on the ground *)
        else if (throwableWeapons[i].onGround = True) then
          TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name + ' [on the ground]')
        (* Everything else *)
        else
          TextOut(10, yPOS, 'white', '[' + throwableWeapons[i].mnuOption + '] ' + throwableWeapons[i].Name);
        Inc(yPOS);
      end;
    end;

    (* Get the range of choices *)
    for i := 0 to maxWeapons do
    begin
      if (throwableWeapons[i].Name <> scrTargeting.empty) then
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
  opponent := entityList[tgtList[selTarget].id].race;
  if (entityList[tgtList[selTarget].id].article = True) then
    opponent := 'the ' + opponent;

  (* Attacking an NPC automatically makes it hostile *)
  entityList[tgtList[selTarget].id].state := stateHostile;
  (* Number of turns NPC will follow you if out of sight *)
  entityList[tgtList[selTarget].id].moveCount := 10;

  (* Calculate damage caused *)

  { Convert distance to target from real number to integer }
   tgtDistance := round(tgtList[selTarget].distance);
  { Get the players Dexterity }
  dex := player_stats.dexterity;
  { if dex > tgtDistance = the remainder is added to projectile damage
    if dex < tgtDistance = the difference is removed from the damage.
    Closer targets take more damage                                    }
  damage := throwableWeapons[selectedProjectile].baseDMG;
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
  los.playerProjectilePath(entityList[0].posX, entityList[0].posY, tgtList[selTarget].x, tgtList[selTarget].y, throwableWeapons[selectedProjectile].glyph, throwableWeapons[selectedProjectile].glyphColour);

  (* Apply damage *)
  if (damage = 0) then
     ui.bufferMessage('The ' + throwableWeapons[selectedProjectile].Name + ' misses')
  else
    begin
      dmgAmount := damage - entityList[tgtList[selTarget].id].defence;
      (* If it was a hit *)
      if ((dmgAmount - entityList[0].tmrDrunk) > 0) then
      begin
        Dec(entityList[tgtList[selTarget].id].currentHP, dmgAmount);
        (* If it was a killing blow *)
        if (entityList[tgtList[selTarget].id].currentHP < 1) then
        begin
          ui.writeBufferedMessages;
          ui.bufferMessage('You kill ' + opponent);
          entities.killEntity(tgtList[selTarget].id);
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
            ui.bufferMessage('The ' + throwableWeapons[selectedProjectile].Name + ' hits ' + opponent);
      end
      else
         ui.bufferMessage('The ' + throwableWeapons[selectedProjectile].Name + ' doesn''t injure ' + opponent);
    end;

  (* Remove item from ground or inventory *)
  if (throwableWeapons[selectedProjectile].onGround = True) then
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
  (* Increase turn counter for this action *)
  Inc(entityList[0].moveCount);
  main.gameState := stGame;
  main.gameLoop;
 end;

procedure removeFromGround;
var
  i, itmID: smallint;
begin
  itmID := 0;
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
          itemName := scrTargeting.empty;
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
          dice := 0;
          adds := 0;
          discovered := False;
      end;
  ui.bufferMessage('The rock breaks on impact');
  end;
end;

procedure removeThrownFromInventory;
var
  itemNumber, dmgID, b: smallint;
  newItem: Item;
begin
  itemNumber := throwableWeapons[selectedProjectile].id;
  b := throwableWeapons[selectedProjectile].playerInventoryID;
  dmgID := player_inventory.inventory[itemNumber].id;

  (* Weapon damage for edged weapons *)
  case player_inventory.inventory[itemNumber].useID of
       2: crude_dagger.thrownDamaged(dmgID, True);
  end;

  (* Rocks break on impact *)
  if (throwableWeapons[selectedProjectile].Name <> 'rock') then
  { Create an item }
  begin
    newItem.itemID := indexID;
    newItem.itemName := player_inventory.inventory[b].Name;
    newItem.itemDescription := player_inventory.inventory[b].description;
    newItem.itemArticle := player_inventory.inventory[b].article;
    newItem.itemType := player_inventory.inventory[b].itemType;
    newItem.itemMaterial := player_inventory.inventory[b].itemMaterial;
    newItem.useID := player_inventory.inventory[b].useID;
    newItem.glyph := player_inventory.inventory[b].glyph;
    newItem.glyphColour := player_inventory.inventory[b].glyphColour;
    newItem.inView := True;
    newItem.posX := landingX;
    newItem.posY := landingY;
    newItem.NumberOfUses := player_inventory.inventory[b].numUses;
    newItem.onMap := True;
    newItem.throwable := player_inventory.inventory[b].throwable;
    newItem.throwDamage := player_inventory.inventory[b].throwDamage;
    newItem.discovered := True;
    newItem.adds := player_inventory.inventory[b].adds;
    newItem.dice := player_inventory.inventory[b].dice;
    Inc(indexID);

  { Place item on the game map }
  SetLength(itemList, Length(itemList) + 1);
  Insert(newitem, itemList, Length(itemList));
  end
  else
      ui.bufferMessage('The rock breaks on impact');

  (* Unequip weapon if equipped *)
  if (throwableWeapons[selectedProjectile].equppd = True) then
  begin
       case player_inventory.inventory[itemNumber].useID of
         2: crude_dagger.throw(itemNumber);
         4: basic_club.throw;
         8: staff_minor_scorch.throw;
         11: pointy_stick.throw;
       end;
  end;

  (* Remove from inventory *)
  player_inventory.inventory[b].sortIndex := 10;
  player_inventory.inventory[b].Name := scrTargeting.empty;
  player_inventory.inventory[b].equipped := False;
  player_inventory.inventory[b].description := 'x';
  player_inventory.inventory[b].article := 'x';
  player_inventory.inventory[b].itemType := itmEmptySlot;
  player_inventory.inventory[b].itemMaterial := matEmpty;
  player_inventory.inventory[b].glyph := 'x';
  player_inventory.inventory[b].glyphColour := 'x';
  player_inventory.inventory[b].inInventory := False;
  player_inventory.inventory[b].numUses := 0;
  player_inventory.inventory[b].throwable := False;
  player_inventory.inventory[b].throwDamage := 0;
  player_inventory.inventory[b].useID := 0;
  player_inventory.inventory[b].adds := 0;
  player_inventory.inventory[b].dice := 0;
end;

end.

