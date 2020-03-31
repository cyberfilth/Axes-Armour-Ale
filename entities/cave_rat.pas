(* Weak enemy with simple AI, no pathfinding *)

unit cave_rat;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils, map;

(* Create a cave rat *)
procedure createCaveRat(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Run from player *)
procedure escapePlayer(id, spx, spy: smallint);
(* Combat *)
procedure combat(id: smallint);

implementation

uses
  entities, player, globalutils, ui;

procedure createCaveRat(uniqueid, npcx, npcy: smallint);
begin
  // Add a cave rat to the list of creatures
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'cave rat';
    description := 'a large rat';
    glyph := 'r';
    glyphColour := $20B2FB;
    maxHP := randomRange(2, 5);
    currentHP := maxHP;
    attack := randomRange(2, 3);
    defense := randomRange(1, 3);
    inView := False;
    discovered := False;
    isDead := False;
    posX := npcx;
    posY := npcy;
  end;
end;

procedure takeTurn(id, spx, spy: smallint);
begin
  (* Check if the NPC is in the players FoV *)
  if (map.canSee(spx, spy) = True) then
  begin { TODO : Check if player is adjacent to the entity, otherwise they will always be stuck in a retreat loop }
    (* If NPC is at half health, they run *)
    if (entities.entityList[id].currentHP < entities.entityList[id].maxHP) then
      escapePlayer(id, spx, spy)
    else
      chasePlayer(id, spx, spy);
  end
  else
    wander(id, spx, spy);
end;

procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  attempts := 0;
  repeat
    // Reset values after each failed loop so they don't keep dec/incrementing
    testx := spx;
    testy := spy;
    direction := random(6);
    // limit the number of attempts to move so the game doesn't hang if NPC is stuck
    Inc(attempts);
    if attempts > 10 then
    begin
      entities.moveNPC(id, spx, spy);
      break;
    end;
    case direction of
      0: Dec(testy);
      1: Inc(testy);
      2: Dec(testx);
      3: Inc(testx);
      4: testx := spx;
      5: testy := spy;
    end
  until (map.canMove(testx, testy) = True) and (map.isOccupied(testx, testy) = True);
  entities.moveNPC(id, testx, testy);
end;

procedure chasePlayer(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to chase the player *)
  if (spx > player.ThePlayer.posX) and (spy > player.ThePlayer.posY) then
  begin
    newX := spx - 1;
    newY := spy - 1;
  end
  else if (spx < player.ThePlayer.posX) and (spy < player.ThePlayer.posY) then
  begin
    newX := spx + 1;
    newY := spy + 1;
  end
  else if (spx < player.ThePlayer.posX) then
  begin
    newX := spx + 1;
    newY := spy;
  end
  else if (spx > player.ThePlayer.posX) then
  begin
    newX := spx - 1;
    newY := spy;
  end
  else if (spy < player.ThePlayer.posY) then
  begin
    newX := spx;
    newY := spy + 1;
  end
  else if (spy > player.ThePlayer.posY) then
  begin
    newX := spx;
    newY := spy - 1;
  end;
  if (map.canMove(newX, newY) = True) then
  begin
    if (map.hasPlayer(newX, newY) = True) then
    begin
      entities.moveNPC(id, spx, spy);
      combat(id);
    end
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  else
    wander(id, spx, spy);
end;

procedure escapePlayer(id, spx, spy: smallint);
var
  newX, newY: smallint;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to run away from player *)
  if (spx > player.ThePlayer.posX) and (spy > player.ThePlayer.posY) then
  begin
    newX := spx + 1;
    newY := spy + 1;
  end
  else if (spx < player.ThePlayer.posX) and (spy < player.ThePlayer.posY) then
  begin
    newX := spx - 1;
    newY := spy - 1;
  end
  else if (spx < player.ThePlayer.posX) then
  begin
    newX := spx - 1;
    newY := spy;
  end
  else if (spx > player.ThePlayer.posX) then
  begin
    newX := spx + 1;
    newY := spy;
  end
  else if (spy < player.ThePlayer.posY) then
  begin
    newX := spx;
    newY := spy - 1;
  end
  else if (spy > player.ThePlayer.posY) then
  begin
    newX := spx;
    newY := spy + 1;
  end;
  if (map.canMove(newX, newY) = True) then
  begin
    if (map.hasPlayer(newX, newY) = True) then
    begin
      entities.moveNPC(id, spx, spy);
      combat(id);
    end
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  else
    wander(id, spx, spy);
end;

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) -
    player.ThePlayer.defense;
  if (damageAmount > 0) then
  begin
    player.ThePlayer.currentHP := (player.ThePlayer.currentHP - damageAmount);
    if (player.ThePlayer.currentHP < 1) then
    begin   { TODO : Create player.playerDeath function that handles this }
      ui.displayMessage('You are dead!');
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.displayMessage('The cave rat slightly wounds you')
      else
        ui.displayMessage('The cave rat bites you, inflicting ' +
          IntToStr(damageAmount) + ' damage');
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
    ui.displayMessage('The ' + entities.entityList[id].race + ' attacks but misses.');
end;

end.
