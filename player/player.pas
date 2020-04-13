(* Player setup and stats *)
unit player;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils;

type
  (* Store information about the player *)
  Creature = record
    currentHP, maxHP, attack, defense, posX, posY, visionRange: smallint;
    experience: integer;
    playerName, title: string;
    (* status effects *)
    stsDrunk, stsPoison: boolean;
    (* status timers *)
    tmrDrunk, tmrPoison: smallint;
    (* Player Glyph *)
    glyph: TBitmap;
  end;


var
  (* Player character *)
  ThePlayer: Creature;

(* Places the player on the map *)
procedure spawnPlayer(startX, startY: smallint);
(* Moves the player on the map *)
procedure movePlayer(dir: word);
(* Process status effects *)
procedure processStatus;
(* Attack NPC *)
procedure combat(npcID: smallint);
(* Check if tile is occupied by an NPC *)
function combatCheck(x, y: smallint): boolean;
(* Pick up an item from the floor *)
procedure pickUp;
(*Increase Health, no more than maxHP *)
procedure increaseHealth(amount: smallint);

implementation

uses
  globalutils, map, fov, ui, entities, plot_gen, player_inventory, items;

procedure spawnPlayer(startX, startY: smallint);
begin
  (* Setup player stats *)
  with ThePlayer do
  begin
    currentHP := 20;
    maxHP := 20;
    attack := 5;
    defense := 2;
    experience := 0;
    posX := startX;
    posY := startY;
    visionRange := 4;
    playerName := 'Default';
    title := 'the nobody';
    glyph := TBitmap.Create;
    glyph.LoadFromResourceName(HINSTANCE, 'PLAYER_GLYPH');
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    (* Generate a name for the player *)
    plot_gen.generateName;
    (* set up inventory *)
    player_inventory.initialiseInventory;
    (* Draw player and FOV *)
    fov.fieldOfView(ThePlayer.posX, ThePlayer.posY, ThePlayer.visionRange, 1);
    drawToBuffer(map.mapToScreen(ThePlayer.posX),
      map.mapToScreen(ThePlayer.posY), glyph);
  end;
end;

(* Move the player within the confines of the game map *)
procedure movePlayer(dir: word);
var
  (* store original values in case player cannot move *)
  originalX, originalY: smallint;
begin
  (* Repaint visited tiles *)
  fov.fieldOfView(ThePlayer.posX, ThePlayer.posY, ThePlayer.visionRange, 0);
  originalX := ThePlayer.posX;
  originalY := ThePlayer.posY;
  case dir of
    1: Dec(ThePlayer.posY); // N
    2: Dec(ThePlayer.posX); // W
    3: Inc(ThePlayer.posY); // S
    4: Inc(ThePlayer.posX); // E
    5:                      // NE
    begin
      Inc(ThePlayer.posX);
      Dec(ThePlayer.posY);
    end;
    6:                      // SE
    begin
      Inc(ThePlayer.posX);
      Inc(ThePlayer.posY);
    end;
    7:                      // SW
    begin
      Dec(ThePlayer.posX);
      Inc(ThePlayer.posY);
    end;
    8:                      // NW
    begin
      Dec(ThePlayer.posX);
      Dec(ThePlayer.posY);
    end;
  end;
  (* check if tile is occupied *)
  if (map.isOccupied(ThePlayer.posX, ThePlayer.posY) = True) then
    (* check if tile is occupied by hostile NPC *)
    if (combatCheck(ThePlayer.posX, ThePlayer.posY) = True) then
    begin
      ThePlayer.posX := originalX;
      ThePlayer.posY := originalY;
    end;
  Inc(playerTurn);
  (* check if tile is walkable *)
  if (map.canMove(ThePlayer.posX, ThePlayer.posY) = False) then
  begin
    ThePlayer.posX := originalX;
    ThePlayer.posY := originalY;
    ui.displayMessage('You bump into a wall');
    Dec(playerTurn);
  end;
  fov.fieldOfView(ThePlayer.posX, ThePlayer.posY, ThePlayer.visionRange, 1);
  ui.writeBufferedMessages;
end;

procedure processStatus;
begin
  (* Inebriation *)
  if (ThePlayer.stsDrunk = True) then
  begin
    if (ThePlayer.tmrDrunk <= 0) then
    begin
      ThePlayer.tmrDrunk := 0;
      ThePlayer.stsDrunk := False;
      ui.bufferMessage('The effects of the alcohol wear off');
    end
    else
      Dec(ThePlayer.tmrDrunk);
  end;
  (* Poison *)
  if (ThePlayer.stsPoison = True) then
  begin
    if (ThePlayer.tmrPoison <= 0) then
    begin
      ThePlayer.tmrPoison := 0;
      ThePlayer.stsPoison := False;
    end
    else
      Dec(ThePlayer.tmrPoison);
  end;
end;

procedure combat(npcID: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, ThePlayer.attack) -
    entities.entityList[npcID].defense;
  if (damageAmount > 0) then
  begin
    entities.entityList[npcID].currentHP :=
      (entities.entityList[npcID].currentHP - damageAmount);
    if (entities.entityList[npcID].currentHP < 1) then
    begin
      ui.bufferMessage('You kill the ' + entities.entityList[npcID].race);
      entities.entityList[npcID].isDead := True;
      entities.entityList[npcID].glyph := '%';
      map.unoccupy(entities.entityList[npcID].posX, entities.entityList[npcID].posY);
      ThePlayer.experience := ThePlayer.experience + entities.entityList[npcID].xpReward;
      ui.updateXP;
      exit;
    end
    else
    if (damageAmount = 1) then
      ui.bufferMessage('You slightly injure the ' + entities.entityList[npcID].race)
    else
      ui.bufferMessage('You hit the ' + entities.entityList[npcID].race +
        ' for ' + IntToStr(damageAmount) + ' points of damage');
  end
  else
    ui.bufferMessage('You miss');
end;

function combatCheck(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 1 to entities.npcAmount do
  begin
    if (x = entities.entityList[i].posX) then
    begin
      if (y = entities.entityList[i].posY) then
        player.combat(i);
      Result := True;
    end;
  end;
end;

procedure pickUp;
var
  i: smallint;
begin
  for i := 1 to itemAmount do
  begin
    if (ThePlayer.posX = itemList[i].posX) and (ThePlayer.posY = itemList[i].posY) and
      (itemList[i].onMap = True) then
    begin
      player_inventory.addToInventory(i);
      Inc(playerTurn);
    end
    else
      ui.displayMessage('There is nothing on the ground here');
  end;
end;

procedure increaseHealth(amount: smallint);
begin
  if ((ThePlayer.currentHP + amount) >= ThePlayer.maxHP) then
    ThePlayer.currentHP := ThePlayer.maxHP
  else
    ThePlayer.currentHP := ThePlayer.currentHP + amount;
  ui.updateHealth;
  ui.bufferMessage('You feel restored');
end;

end.
