(* STationary hazard, when attacked will either poison the player or release spores *)

unit green_fungus;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, globalutils, map, ui;

(* Create fungus *)
procedure createGreenFungus(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* Fungus attacks player *)
procedure combat(id: smallint);

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
  if (isNextToPlayer(spx, spy) = True) then
    combat(id);
  entities.moveNPC(id, spx, spy);
end;

function isNextToPlayer(spx, spy: smallint): boolean;
var
  dx, dy: smallint;
  distance: double;
begin
  Result := False;
  dx := entityList[0].posX - spx;
  dy := entityList[0].posY - spy;
  distance := sqrt(dx ** 2 + dy ** 2);
  if (round(distance) = 0) then
    Result := True;
end;

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(2, entities.entityList[id].attack) -
    entities.entityList[0].defense;
  if (damageAmount > 0) then
  begin
    entities.entityList[0].currentHP :=
      (entities.entityList[0].currentHP - damageAmount);
    if (entities.entityList[0].currentHP < 1) then
    begin
      if (killer = 'empty') then
        killer := entityList[id].race;
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.bufferMessage('The fungus slightly wounds you')
      else
      begin
        ui.bufferMessage('The fungus lashes you with its stinger, inflicting ' +
          IntToStr(damageAmount) + ' damage');
        (* Fungus does poison damage *)
        entities.entityList[0].stsPoison := True;
      end;
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
    ui.bufferMessage('The fungus lashes out at you but misses');
end;

end.

