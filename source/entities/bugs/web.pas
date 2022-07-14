(* Environmental hazard - blocks entities *)

unit web;

{$mode fpc}{$H+}

interface

uses
  SysUtils;

(* Create web *)
procedure createWeb(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);

implementation

uses
  entities, globalUtils, map;

procedure createWeb(uniqueid, npcx, npcy: smallint);
begin
  (* Add a web to the list of entities *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'web';
    intName := 'stickyWeb';
    article := True;
    description := 'a sticky web';
    glyph := '/';
    glyphColour := 'lightGrey';
    maxHP := randomRange(5, 8);
    currentHP := maxHP;
    attack := 0;
    defence := randomRange(5, 12);
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := (maxHP div 2);
    visionRange := 4;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := True;
    blocks := False;
    faction := trapFaction;
    state := stateHostile;
    discovered := True;
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
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

end.

