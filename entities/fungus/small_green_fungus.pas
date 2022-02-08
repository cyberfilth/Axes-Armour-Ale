(* Stationary hazard, deals poison damage in combat *)

unit small_green_fungus;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

(* Create fungus *)
procedure createSmallGreenFungus(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Fungus attacks *)
procedure combat(idOwner, idTarget: smallint);

implementation

uses
  entities, globalutils, ui, map, los, universe;

procedure createSmallGreenFungus(uniqueid, npcx, npcy: smallint);
begin
  (* Add a green fungus to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Small Green Fungus';
    intName := 'SmallGreenFungus';
    article := True;
    description := 'a poisonous fungus';
    glyph := 'f';
    glyphColour := 'green';
    maxHP := randomRange(3, 5);
    currentHP := maxHP;
    attack := randomRange(3, 5);
    defence := randomRange(3, 5);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := 1;
    visionRange := 4;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := fungusFaction;
    state := stateHostile;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
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

procedure takeTurn(id: smallint);
begin
  (* Can the NPC see the player *)
  if (los.inView(entityList[id].posX, entityList[id].posY,
    entities.entityList[0].posX, entities.entityList[0].posY,
    entities.entityList[id].visionRange) = True) then
  begin
    if (isNextToPlayer(entityList[id].posX, entityList[id].posY) = True) then
      combat(id, 0);
  end;
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

function isNextToPlayer(spx, spy: smallint): boolean;
begin
  Result := False;
  if (map.hasPlayer(spx, spy - 1) = True) then { NORTH }
    Result := True;
  if (map.hasPlayer(spx + 1, spy - 1) = True) then { NORTH EAST }
    Result := True;
  if (map.hasPlayer(spx + 1, spy) = True) then { EAST }
    Result := True;
  if (map.hasPlayer(spx + 1, spy + 1) = True) then { SOUTH EAST }
    Result := True;
  if (map.hasPlayer(spx, spy + 1) = True) then { SOUTH }
    Result := True;
  if (map.hasPlayer(spx - 1, spy + 1) = True) then { SOUTH WEST }
    Result := True;
  if (map.hasPlayer(spx - 1, spy) = True) then { WEST }
    Result := True;
  if (map.hasPlayer(spx - 1, spy - 1) = True) then { NORTH WEST }
    Result := True;
end;

procedure combat(idOwner, idTarget: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(2, entities.entityList[idOwner].attack) -
    entities.entityList[idTarget].defence;
  if (damageAmount > 0) then
  begin
    entities.entityList[idTarget].currentHP :=
      (entities.entityList[idTarget].currentHP - damageAmount);
    if (entities.entityList[idTarget].currentHP < 1) then
    begin
      if (idTarget = 0) then
      begin
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
    begin
      if (idTarget = 0) then { if target is the player }
      begin
        ui.displayMessage('The fungus lashes you with its stinger, inflicting ' +
          IntToStr(damageAmount) + ' damage');
        (* Fungus does poison damage *)
        entityList[0].stsPoison := True;
        entityList[0].tmrPoison := damageAmount + universe.currentDepth;
        if (killer = 'empty') then
          killer := 'poisonous fungus';
      end
      else
        ui.bufferMessage('The fungus stings the ' +
          entities.entityList[idTarget].race);
    end;
  end
  else
    ui.displayMessage('The fungus strikes out but misses');
end;

end.
