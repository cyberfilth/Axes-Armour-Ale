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
var
  i: smallint;
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
    xpReward := 0;
    visionRange := 4;
    (* Number of turns before web dissolves *)
    i := randomRange(5, 10);
    moveCount := i;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := trapFaction;
    state := stateHostile;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    stsDrunk := False;
    stsPoison := False;
    stsBewild := False;
    stsFrozen := False;	
    tmrDrunk := 0;
    tmrPoison := 0;
    tmrBewild := 0;
    tmrFrozen := 0;
    hasPath := False;
    destinationReached := False;
    entities.initPath(uniqueid);
    posX := npcx;
    posY := npcy;
  end;
  (* Occupy tile *)
  map.occupy(npcx, npcy);
end;

procedure takeTurn(id: smallint);
begin
  Dec(entityList[id].moveCount);
  if (entityList[id].moveCount <= 0) then
  begin
    entityList[id].currentHP := 0;
    killEntity(id);
  end
  else
    entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

end.
