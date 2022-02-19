(* Screen used for Look and targeting *)

unit scrTargeting;

{$mode fpc}{$H+}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, map, entities, video, ui, camera, fov, items, scrGame;

var
  (* Target coordinates *)
  targetX, targetY: smallint;
  (* The last safe coordinates *)
  safeX, safeY: smallint;

procedure look(dir: word);
procedure restorePlayerGlyph;
(* Paint over the message log *)
procedure paintOverMsg;

implementation

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
