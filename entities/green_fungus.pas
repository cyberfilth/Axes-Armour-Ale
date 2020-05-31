(* Stationary hazard, when attacked will either poison the player or release spores *)

unit green_fungus;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, globalutils, map, los, ui;

(* Create fungus *)
procedure createGreenFungus(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Fungus attacks *)
procedure combat(idOwner, idTarget: smallint);

implementation

uses
  entities;

procedure createGreenFungus(uniqueid, npcx, npcy: smallint);
begin
  // Add a green fungus to the list of creatures
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'green fungus';
    description := 'a green fungus';
    glyph := 'f';
    maxHP := randomRange(2, 6);
    currentHP := maxHP;
    attack := randomRange(4, 6);
    defense := randomRange(2, 3);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 4;
    NPCsize := 2;
    trackingTurns := 0;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := True;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    abilityTriggered := False;
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    posX := npcx;
    posY := npcy;
  end;
  (* Occupy tile *)
  map.occupy(npcx, npcy);
end;

procedure takeTurn(id, spx, spy: smallint);
begin
  (* Can the NPC see the player *)
  if (los.inView(spx, spy, entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[id].visionRange) = True) then
  begin
    if (isNextToPlayer(spx, spy) = True) then
      combat(id, 0);
    entities.moveNPC(id, spx, spy);

  end;

end;

function isNextToPlayer(spx, spy: smallint): boolean;
begin
  Result := False;
  if (map.hasPlayer(spx, spy - 1) = True) then // NORTH
    Result := True;
  if (map.hasPlayer(spx + 1, spy - 1) = True) then // NORTH EAST
    Result := True;
  if (map.hasPlayer(spx + 1, spy) = True) then // EAST
    Result := True;
  if (map.hasPlayer(spx + 1, spy + 1) = True) then // SOUTH EAST
    Result := True;
  if (map.hasPlayer(spx, spy + 1) = True) then // SOUTH
    Result := True;
  if (map.hasPlayer(spx - 1, spy + 1) = True) then // SOUTH WEST
    Result := True;
  if (map.hasPlayer(spx - 1, spy) = True) then // WEST
    Result := True;
  if (map.hasPlayer(spx - 1, spy - 1) = True) then // NORTH WEST
    Result := True;
end;

procedure combat(idOwner, idTarget: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(2, entities.entityList[idOwner].attack) -
    entities.entityList[idTarget].defense;
  if (damageAmount > 0) then
  begin
    entities.entityList[idTarget].currentHP :=
      (entities.entityList[idTarget].currentHP - damageAmount);
    if (entities.entityList[idTarget].currentHP < 1) then
    begin
      if (idTarget = 0) then
      begin
        if (killer = 'empty') then
          killer := entityList[idOwner].race;
        exit;
      end
      else
      begin
        ui.displayMessage('The fungus kills the ' + entities.entityList[idTarget].race);
        entities.killEntity(idTarget);
        (* The fungus levels up *)
        Inc(entities.entityList[idOwner].xpReward, 2);
        Inc(entities.entityList[idOwner].attack, 2);
        ui.bufferMessage('The fungus appears to grow larger');
        exit;
      end;
    end
    else
    begin // if attack causes slight damage
      if (damageAmount = 1) then
      begin
        if (idTarget = 0) then // if target is the player
        begin
          ui.writeBufferedMessages;
          ui.displayMessage('The fungus slightly wounds you');
        end
        else
        begin
          ui.writeBufferedMessages;
          ui.displayMessage('The fungus attacks the ' +
            entities.entityList[idTarget].race);
        end;
      end
      else  // if attack causes more damage
      begin
        if (idTarget = 0) then // if target is the player
        begin
          ui.bufferMessage('The fungus lashes you with its stinger, inflicting ' +
            IntToStr(damageAmount) + ' damage');
          (* Fungus does poison damage *)
          entityList[0].stsPoison := True;
          entityList[0].tmrPoison := damageAmount + 2;
          if (killer = 'empty') then
            killer := 'poisoned fungus spore';
        end
        else
          ui.bufferMessage('The fungus stings the ' +
            entities.entityList[idTarget].race);
      end;
    end;
  end
  else
    ui.bufferMessage('The fungus lashes out at you but misses');
end;


end.
