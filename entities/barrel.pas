(* A barrel, may contain items when broken apart. This is an entity instead of
an item because it may tranform into a trap or another entity when attacked *)

unit barrel;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, ui, items, ale_tankard;

(* Create a barrel *)
procedure createBarrel(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Barrel breaks open *)
procedure breakBarrel(x, y: smallint);

implementation

uses
  entities, globalutils;

procedure createBarrel(uniqueid, npcx, npcy: smallint);
begin
  // Add a Barrel to the list of creatures
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'barrel';
    description := 'a sealed, wooden barrel';
    glyph := '8';
    maxHP := randomRange(1, 3);
    currentHP := maxHP;
    attack := 0;
    defense := 0;
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 1;
    NPCsize := 1;
    trackingTurns := 0;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
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
end;

procedure takeTurn(id, spx, spy: smallint);
begin
  entities.moveNPC(id, spx, spy);
  Exit;
end;

procedure breakBarrel(x, y: smallint);
begin
  Inc(itemAmount);
  (* Drop an item - Ale Tankard *)
  createAleTankard(itemAmount, x, y);
end;

end.

