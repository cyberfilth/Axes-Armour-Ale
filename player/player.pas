(* Player setup and stats *)
unit player;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils, plot_gen;

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

(* Create player character *)
procedure createPlayer;
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
  globalutils, map, fov, ui, entities, player_inventory, items;

procedure createPlayer;
begin
  plot_gen.generateName;
  // Add Player to the list of creatures
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[0] do
  begin
    npcID := 0;
    race := plot_gen.playerName;
    description := 'your character';
    glyph := '@';
    maxHP := 20;
    currentHP := 20;
    attack := 5;
    defense := 2;
    xpReward := 0;
    visionRange := 4;
    NPCsize := 3;
    trackingTurns := 3;
    moveCount := 0;
    inView := True;
    discovered := True;
    isDead := False;
    abilityTriggered := False;
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    posX := map.startX;
    posY := map.startY;
  end;
  (* set up inventory *)
  player_inventory.initialiseInventory;
  (* Draw player and FOV *)
  fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[0].visionRange, 1);
end;

(* Move the player within the confines of the game map *)
procedure movePlayer(dir: word);
var
  (* store original values in case player cannot move *)
  originalX, originalY: smallint;
begin
  (* Repaint visited tiles *)
  fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[0].visionRange, 0);
  originalX := entities.entityList[0].posX;
  originalY := entities.entityList[0].posY;
  case dir of
    1: Dec(entities.entityList[0].posY); // N
    2: Dec(entities.entityList[0].posX); // W
    3: Inc(entities.entityList[0].posY); // S
    4: Inc(entities.entityList[0].posX); // E
    5:                      // NE
    begin
      Inc(entities.entityList[0].posX);
      Dec(entities.entityList[0].posY);
    end;
    6:                      // SE
    begin
      Inc(entities.entityList[0].posX);
      Inc(entities.entityList[0].posY);
    end;
    7:                      // SW
    begin
      Dec(entities.entityList[0].posX);
      Inc(entities.entityList[0].posY);
    end;
    8:                      // NW
    begin
      Dec(entities.entityList[0].posX);
      Dec(entities.entityList[0].posY);
    end;
  end;
  (* check if tile is occupied *)
  if (map.isOccupied(entities.entityList[0].posX, entities.entityList[0].posY) =
    True) then
    (* check if tile is occupied by hostile NPC *)
    if (combatCheck(entities.entityList[0].posX, entities.entityList[0].posY) =
      True) then
    begin
      entities.entityList[0].posX := originalX;
      entities.entityList[0].posY := originalY;
    end;
  Inc(playerTurn);
  (* check if tile is walkable *)
  if (map.canMove(entities.entityList[0].posX, entities.entityList[0].posY) = False) then
  begin
    entities.entityList[0].posX := originalX;
    entities.entityList[0].posY := originalY;
    ui.displayMessage('You bump into a wall');
    Dec(playerTurn);
  end;
  fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[0].visionRange, 1);
  ui.writeBufferedMessages;
end;

procedure processStatus;
begin
  (* Inebriation *)
  if (entities.entityList[0].stsDrunk = True) then
  begin
    if (entities.entityList[0].tmrDrunk <= 0) then
    begin
      entities.entityList[0].tmrDrunk := 0;
      entities.entityList[0].stsDrunk := False;
      ui.bufferMessage('The effects of the alcohol wear off');
    end
    else
      Dec(entities.entityList[0].tmrDrunk);
  end;
  (* Poison *)
  if (entities.entityList[0].stsPoison = True) then
  begin
    if (entities.entityList[0].tmrPoison <= 0) then
    begin
      entities.entityList[0].tmrPoison := 0;
      entities.entityList[0].stsPoison := False;
    end
    else
      Dec(entities.entityList[0].tmrPoison);
  end;
end;

procedure combat(npcID: smallint);
var
  damageAmount: smallint;
begin
  //damageAmount := globalutils.randomRange(1, entities.entityList[0].attack) -
  //  entities.entityList[npcID].defense;
  //if ((damageAmount - ThePlayer.tmrDrunk) > 0) then
  //begin
  //  entities.entityList[npcID].currentHP :=
  //    (entities.entityList[npcID].currentHP - damageAmount);
  //  if (entities.entityList[npcID].currentHP < 1) then
  //  begin
  //    ui.bufferMessage('You kill the ' + entities.entityList[npcID].race);
  //    entities.entityList[npcID].isDead := True;
  //    entities.entityList[npcID].glyph := '%';
  //    map.unoccupy(entities.entityList[npcID].posX, entities.entityList[npcID].posY);
  //    ThePlayer.experience := ThePlayer.experience + entities.entityList[npcID].xpReward;
  //    ui.updateXP;
  //    exit;
  //  end
  //  else
  //  if (damageAmount = 1) then
  //    ui.bufferMessage('You slightly injure the ' + entities.entityList[npcID].race)
  //  else
  //    ui.bufferMessage('You hit the ' + entities.entityList[npcID].race +
  //      ' for ' + IntToStr(damageAmount) + ' points of damage');
  //end
  //else
  //begin
  //  if (ThePlayer.stsDrunk = True) then
  //    ui.bufferMessage('You drunkenly miss')
  //else
  //  ui.bufferMessage('You miss');
  //end;
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
    if (entities.entityList[0].posX = itemList[i].posX) and
      (entities.entityList[0].posY = itemList[i].posY) and
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
  if (entities.entityList[0].currentHP <> entities.entityList[0].maxHP) then
  begin
    if ((entities.entityList[0].currentHP + amount) >= entities.entityList[0].maxHP) then
      entities.entityList[0].currentHP := entities.entityList[0].maxHP
    else
      entities.entityList[0].currentHP := entities.entityList[0].currentHP + amount;
    ui.updateHealth;
    ui.bufferMessage('You feel restored');
  end
  else
    ui.bufferMessage('You are already at full health');
end;

end.
