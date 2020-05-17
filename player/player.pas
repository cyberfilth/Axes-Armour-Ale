(* Player setup and stats *)
unit player;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils, plot_gen, scent_map;

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
(* Players starting inventory *)
procedure createEquipment;
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
(* Display game over screen *)
procedure gameOver;

implementation

uses
  globalutils, map, fov, ui, entities, player_inventory, items, main;

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
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := 0;
    visionRange := 4;
    NPCsize := 3;
    trackingTurns := 3;
    moveCount := 0;
    inView := True;
    discovered := True;
    weaponEquipped := False;
    armourEquipped := False;
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
  (* Generate smell map *)
  scent_map.initialiseScent(entityList[0].posX, entityList[0].posY);
  (* Draw player and FOV *)
  fov.fieldOfView(entityList[0].posX, entityList[0].posY, entityList[0].visionRange, 1);
end;

procedure createEquipment;
begin
  { TODO : Once character creation is implemented, replace this with a function that generates starting equipment based on the type of player chosen. }
  (* Add a club to the players inventory *)
  with player_inventory.inventory[0] do
  begin
    id := 0;
    Name := 'Wooden club';
    equipped := True;
    description := 'adds 1D6 to attack [equipped]';
    itemType := 'weapon';
    glyph := '4';
    inInventory := True;
    useID := 4;
  end;
  ui.updateWeapon('Wooden club');
  entityList[0].weaponEquipped := True;
  Inc(entityList[0].weaponDice);
end;

(* Move the player within the confines of the game map *)
procedure movePlayer(dir: word);
var
  (* store original values in case player cannot move *)
  originalX, originalY: smallint;
begin
  (* Unoccupy tile *)
  map.unoccupy(entityList[0].posX, entityList[0].posY);
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
  (* Occupy tile *)
  map.occupy(entityList[0].posX, entityList[0].posY);
  fov.fieldOfView(entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[0].visionRange, 1);
  (* Update the scent map *)
  scent_map.updateScent(entityList[0].posX, entityList[0].posY);
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

(*
  Combat is decided by rolling a random number between 1 and the entity's ATTACK value.
  Then modifiers are added, for example, a 1D6+4 axe will roll a 6 sided die and
  add the result plus 4 to the total damage amount. This is then removed from the
  opponents DEFENSE rating. If the opponents defense doesn't soak up the whole damage
  amount, the remainder is taken from their Health. This is partly inspired by the
  Tunnels & Trolls rules, my favourite tabletop RPG.
*)

procedure combat(npcID: smallint);
var
  damageAmount: smallint;
begin
  damageAmount :=
    (globalutils.randomRange(1, entityList[0].attack) + // Base attack
    globalutils.rollDice(entityList[0].weaponDice) +    // Weapon dice
    entityList[0].weaponAdds) -                         // Weapon adds
    entities.entityList[npcID].defense;

  if ((damageAmount - entities.entityList[0].tmrDrunk) > 0) then
  begin
    entities.entityList[npcID].currentHP :=
      (entities.entityList[npcID].currentHP - damageAmount);
    if (entities.entityList[npcID].currentHP < 1) then
    begin
      ui.bufferMessage('You kill the ' + entities.entityList[npcID].race);
      entities.killEntity(npcID);
      entities.entityList[0].xpReward :=
        entities.entityList[0].xpReward + entities.entityList[npcID].xpReward;
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
  begin
    if (entities.entityList[0].stsDrunk = True) then
      ui.bufferMessage('You drunkenly miss')
    else
      ui.bufferMessage('You miss');
  end;
end;

function combatCheck(x, y: smallint): boolean;
  { TODO : Replace this with a check to see if the tile is occupied }
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

procedure gameOver;
begin
  globalutils.deleteGame;
  main.gameState := 4;
  currentScreen := RIPscreen;
  (* Clear the screen *)
  RIPscreen.Canvas.Brush.Color := globalutils.BACKGROUNDCOLOUR;
  RIPscreen.Canvas.FillRect(0, 0, RIPscreen.Width, RIPscreen.Height);
  (* Draw title *)
  RIPscreen.Canvas.Font.Color := UITEXTCOLOUR;
  RIPscreen.Canvas.Brush.Style := bsClear;
  RIPscreen.Canvas.Font.Size := 12;
  RIPscreen.Canvas.TextOut(100, 50, 'You have died...');
  RIPscreen.Canvas.Font.Size := 10;
  (* Display message *)
  RIPscreen.Canvas.TextOut(30, 100, 'Killed by a ' + killer + ' after ' +
    IntToStr(playerTurn) + ' turns, whilst testing a roguelike ;-)');
  (* Menu options *)
  RIPscreen.Canvas.Font.Size := 9;
  RIPscreen.Canvas.TextOut(10, 410,
    'Exit game?      [Q] - Quit game    |    [X] - Exit to main menu');
end;

end.
