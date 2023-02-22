(* Wandering village pig *)

unit pig;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, ai_villager;

(* Create a pig *)
procedure createPig(uniqueid, npcx, npcy: smallint);
(* Pig takes their turn in the game loop *)
procedure takeTurn(id: smallint);
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Check if player is next to pig *)
function isNextToPlayer(spx, spy: smallint): boolean;

implementation

uses
  entities, globalutils, map;

procedure createPig(uniqueid, npcx, npcy: smallint);
begin
  (* Add createPig to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'pig';
    intName := 'pig';
    article := True;
    description := 'a large pig';
    glyph := 'p';
    glyphColour := 'pink';
    maxHP := 4;
    currentHP := maxHP;
    attack := 1;
    defence := 1;
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 4;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := npcFaction;
    state := stateNeutral;
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
  decisionNeutral(id);
end;

procedure decisionNeutral(id: smallint);
var
  stopAndSmellFlowers: byte;
begin
  stopAndSmellFlowers := globalutils.randomRange(1, 3);
  if (stopAndSmellFlowers = 1) then
    { Either wander randomly }
    ai_villager.wander(id, entityList[id].posX, entityList[id].posY)
  else
    { or stay in place }
    entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

{$I nextto}

end.
