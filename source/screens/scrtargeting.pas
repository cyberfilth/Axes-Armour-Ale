(* Screen used for Firing a bow *)

unit scrTargeting;

{$mode objfpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Classes, Math, map, entities, video, ui, camera, fov, items, los,
  scrGame, player_stats, animation, globalUtils, arrow;

type
  (* Weapons *)
  Equipment = record
    id, baseDMG, playerInventoryID: smallint;
    mnuOption: char;
    Name, glyph, glyphColour: shortstring;
    onGround, equppd: boolean;
  end;

const
  empty = 'Empty';

var
  (* Target coordinates *)
  targetX, targetY: smallint;
  (* The last safe coordinates *)
  safeX, safeY: smallint;
  weaponAmount, selectedTarget, tgtAmount: smallint;
  (* Path of arrows *)
  arrowFlightArray: array[1..plyrTargetRange] of TPoint;
  (* Arrow Glyph to use in animation *)
  arrowGlyph: shortstring;
  (* Coordinates where the projectile lands *)
  landingX, landingY: smallint;

(* Calculate what angle of arrow to use *)
function glyphAngle(targetX, targetY: smallint): shortstring;

(* Aim bow and arrow *)
procedure aimBow(dir: word);
(* Fire bow and arrow *)
procedure fireBow;
(* Draw trajectory of arrow *)
procedure drawTrajectory(x1, y1, x2, y2: smallint; g, col: shortstring);
(* Arrow hits an entity *)
procedure arrowHit(x, y: smallint);
(* Repaint the player when exiting look/target screen *)
procedure restorePlayerGlyph;
(* Paint over the message log *)
procedure paintOverMsg;

implementation

uses
  player_inventory, main;

function glyphAngle(targetX, targetY: smallint): shortstring;
var
  playerX, playerY, Yresult, Xresult, trajectory: smallint;
  angleGlyph: shortstring;
begin
  playerX := entityList[0].posX;
  playerY := entityList[0].posY;
  Xresult := 0;
  Yresult := 0;
  angleGlyph := '|';
  if (targetX > playerX) then
     begin
       Yresult:=playerY - targetY;
       Xresult := targetX - playerX;
     end
  else if (targetX < playerX) then
     begin
       Yresult := targetY - playerY;
       Xresult:=playerX - targetX;
     end;
  (* Store trajectory *)
  trajectory := Trunc(RadToDeg(arctan2(Yresult, Xresult)));
  (* Calculate glyph *)
  if (playerY = targetY) then
     angleGlyph:='-'
  else if (playerX = targetX) then
     angleGlyph:='|'
  (* If target is to the right of the player *)
  else if (targetX > playerX) then
     begin
       if (trajectory <= 90) and (trajectory >= 68) then
          angleGlyph:='|'
       else if (trajectory < 68) and (trajectory >= 5) then
          angleGlyph:='/'
       else if (trajectory < 5) and (trajectory > -5) then
          angleGlyph:='-'
       else if (trajectory > -68 ) and (trajectory <= -5) then
          angleGlyph:='\'
       else if (trajectory >= -78 ) and (trajectory <= -68) then
          angleGlyph:='|'
     end
  (* If target is to the left of the player *)
  else if (targetX < playerX) then
     begin
       if (trajectory >= -90) and (trajectory <= -68) then
          angleGlyph:='|'
       else if (trajectory > -68) and (trajectory <= -5) then
          angleGlyph:='\'
       else if (trajectory > -5) and (trajectory < 5) then
          angleGlyph:='-'
       else if (trajectory < 68 ) and (trajectory >= 5) then
          angleGlyph:='/'
       else if (trajectory <= 90 ) and (trajectory >= 68) then
          angleGlyph:='|'
     end
     else angleGlyph:='|';

  arrowGlyph := angleGlyph;
  Result := angleGlyph;
end;



{ Aim bow }

procedure aimBow(dir: word);
var
  bowCheck, arrowCheck: boolean;
  i, p: byte;
begin
  bowCheck := False;
  arrowCheck := False;
  LockScreenUpdate;
  (* Check if a bow is equipped *)
  if (player_stats.projectileWeaponEquipped = True) then
     bowCheck := True;
  (* Check if arrows are in inventory *)
  if (player_inventory.carryingArrows = True) then
     arrowCheck := True;
  (* If bow equipped and arrows in inventory *)
  if (bowCheck = True) and (arrowCheck = True) then
  begin
       items.redrawItems;
       (* Redraw NPC's *)
       for p := 1 to entities.npcAmount do
           entities.redrawMapDisplay(p);
  (* Clear the message log *)
  paintOverMsg;
  (* Display hint text *)
  TextOut(centreX('[f] to fire your bow'), 23, 'lightGrey', '[f] to fire your bow');
  TextOut(centreX('[x] to exit the targeting screen'), 24, 'lightGrey', '[x] to exit the targeting screen');

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
      (map.maparea[targetY, targetX].Visible = False) or (map.isWall(targetX, targetY) = True) then
    begin
      targetX := safeX;
      targetY := safeY;
    end;

    (* Redraw all NPC's *)
    for i := 1 to entities.npcAmount do
      entities.redrawMapDisplay(i);
    (* Redraw all items *)
    items.redrawItems;
    (* Draw line from player to target *)
    drawTrajectory(entityList[0].posX, entityList[0].posY, targetX, targetY, glyphAngle(targetX, targetY), 'yellow');
    (* Draw X on target *)
    map.mapDisplay[targetY, targetX].GlyphColour := 'white';
    map.mapDisplay[targetY, targetX].Glyph := 'X';
    (* Store the coordinates, so the cursor doesn't get lost off screen *)
    safeX := targetX;
    safeY := targetY;
    end;
  end
  (* If bow equipped but no arrows in inventory *)
  else if (bowCheck = True) and (arrowCheck = False) then
  begin
       ui.displayMessage('You have no arrows');
       gameState := stGame;
  end
  (* If no bow equipped *)
  else
  begin
      ui.displayMessage('You have no bow to fire');
      gameState := stGame;
  end;
  (* Draw items *)
  items.redrawItems;
  (* Repaint map *)
  camera.drawMap;
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

procedure fireBow;
var
  p: byte;
begin
  (* If the players tile is selected, fire an arrow into the ground *)
  if (targetX = entityList[0].posX) and (targetY = entityList[0].posY) then
  begin
     ui.displayMessage('You fire an arrow into the ground at your feet');
     (* Draw items *)
     items.redrawItems;
     (* redraw NPC's *)
     LockScreenUpdate;
     for p := 1 to entities.npcAmount do
         entities.redrawMapDisplay(p);
     scrTargeting.restorePlayerGlyph;
     ui.clearPopup;
     UnlockScreenUpdate;
     UpdateScreen(False);
  end
  (* Fire the arrow *)
  else
      animation.arrowAnimation(arrowFlightArray, arrowGlyph, 'white');
  (* Remove an arrow from inventory *)

  (* Return control of game back to stGame *)
  restorePlayerGlyph;
  gameState := stGame;
end;

procedure drawTrajectory(x1, y1, x2, y2: smallint; g, col: shortstring);
var
  i, deltax, deltay, numpixels, d, dinc1, dinc2, x, xinc1, xinc2, y,
  yinc1, yinc2: smallint;
begin
  (* Initialise array *)
  for i := 1 to plyrTargetRange do
  begin
    arrowFlightArray[i].X := 0;
    arrowFlightArray[i].Y := 0;
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
  (* Draw the pixels *)
  for i := 1 to numpixels do
  begin
    if (numpixels <= plyrTargetRange) then
    begin
      if (map.isWall(x, y) = True) then
         exit;
      (* Draw the trajectory *)
      if (map.maparea[y][x].Blocks = True) then
         map.mapDisplay[y, x].GlyphColour := 'red'
      else
          map.mapDisplay[y, x].GlyphColour := col;
      map.mapDisplay[y, x].Glyph := g;
      (* Add to array *)
      arrowFlightArray[i].X := x;
      arrowFlightArray[i].Y := y;
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

procedure arrowHit(x, y: smallint);
var
  opponent: shortstring;
  p: byte;
  opponentID, dmgAmount, rndOption: smallint;
begin
  dmgAmount := 0;
  rndOption := globalUtils.randomRange(0,3);
  (* Get target info *)
  opponentID := getCreatureID(x, y);
  opponent := getCreatureName(x, y);
  if (entityList[opponentID].article = True) then
     opponent := 'the ' + opponent;

  (* Attacking an NPC automatically makes it hostile *)
  entityList[opponentID].state := stateHostile;
  (* Number of turns NPC will follow you if out of sight *)
  entityList[opponentID].moveCount := 10;

  (* Damage is caused by player Dexterity *)

  dmgAmount := player_stats.dexterity - entityList[opponentID].defence;
  (* If it was a hit *)
  if ((dmgAmount - entityList[0].tmrDrunk) > 0) then
  begin
       Dec(entityList[opponentID].currentHP, dmgAmount);
       (* If it was a killing blow *)
       if (entityList[opponentID].currentHP < 1) then
       begin
          ui.writeBufferedMessages;
          ui.bufferMessage('You kill ' + opponent);
          entities.killEntity(opponentID);
          entityList[0].xpReward := entities.entityList[0].xpReward + entityList[opponentID].xpReward;
          ui.updateXP;
       end
       else
           begin
             if (rndOption = 0) then
                  ui.bufferMessage('The arrow wounds ' + opponent)
             else if (rndOption = 1) then
                  ui.bufferMessage('The arrow hits ' + opponent)
             else
                 ui.bufferMessage('The arrow strikes ' + opponent);
           end;
      end
      else
         ui.bufferMessage('The arrow glances off ' + opponent);

  (* Chance of arrow being damaged or recovered *)
  rndOption := globalUtils.randomRange(0,2);
  if (rndOption <> 2) then
  { Create an arrow }
  begin
    arrow.createArrow(targetX, targetY);
    Inc(indexID);
  end;

  ui.writeBufferedMessages;
  (* Remove arrow from inventory *)
  player_inventory.removeArrow;
  (* Draw items *)
  items.redrawItems;
  for p := 1 to entities.npcAmount do
      entities.redrawMapDisplay(p);
  scrTargeting.restorePlayerGlyph;
  ui.clearPopup;
  UnlockScreenUpdate;
  UpdateScreen(False);
  (* Increase turn counter for this action *)
  Inc(entityList[0].moveCount);
  gameState := stGame;
  main.gameLoop;
end;

{ Repaint screen }

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
