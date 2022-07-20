(* Sleeping when first encountered, chases the player when awake *)

unit crypt_wolf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

(* Create a Crypt Wolf *)
procedure createCryptWolf(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id: smallint);
(* Decision tree for Neutral state *)
procedure decisionNeutral(id: smallint);
(* Decision tree for Hostile state *)
procedure decisionHostile(id: smallint);
(* Chase the player *)
procedure chasePlayer(id, spx, spy: smallint);
(* Check if player is next to NPC *)
function isNextToPlayer(spx, spy: smallint): boolean;
(* NPC attacks another entity *)
procedure combat(npcID, enemyID: smallint);

implementation

uses
  entities;

procedure createCryptWolf(uniqueid, npcx, npcy: smallint);
begin
  (* Detemine hostility *)
  mood := randomRange(1, 3);
  (* Add a hyena to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'Crypt Wolf';
    intName := 'crptWolf';
    article := True;
    description := 'a sleeping wolf';
    glyph := 'd';
    glyphColour := 'white';
    maxHP := randomRange(4, 6) + universe.currentDepth;
    currentHP := maxHP;
    attack := randomRange(6, 9) + universe.currentDepth;
    defence := randomRange(7, 8) + universe.currentDepth;
    weaponDice := 0;
    weaponAdds := 0;
    xpReward := maxHP;
    visionRange := 6;
    moveCount := 0;
    targetX := 0;
    targetY := 0;
    inView := False;
    blocks := False;
    faction := animalFaction;
    state := stateNeutral;
    discovered := False;
    weaponEquipped := False;
    armourEquipped := False;
    isDead := False;
    stsDrunk := False;
    stsPoison := False;
    tmrDrunk := 0;
    tmrPoison := 0;
    hasPath := False;
    destinationReached := False;
    entities.initPath(uniqueid);
    posX := npcx;
    posY := npcy;
    entities.initPath(uniqueid);
  end;
  (* Occupy tile *)
  map.occupy(npcx, npcy);
end;

procedure takeTurn(id: smallint);
begin
  case entityList[id].state of
    stateNeutral: decisionNeutral(id);
    stateHostile: decisionHostile(id);
    else
      decisionNeutral(id);
  end;
end;

procedure decisionNeutral(id: smallint);
begin
  (* The wolf is sleeping *)
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

procedure decisionHostile(id: smallint);
begin
  (* Wake up *)
  if (entityList[id].description = 'a sleeping wolf') then
  begin
    entityList[id].description := 'fierce Crypt Wolf';
    ui.displayMessage('the Crypt Wolf angrily wakes up');
  end;
  chasePlayer(id, spx, spy: smallint);
end;

procedure chasePlayer(id, spx, spy: smallint);
begin
  (* Check if the player is in sight *)



end;

function isNextToPlayer(spx, spy: smallint): boolean;
begin

end;

procedure combat(npcID, enemyID: smallint);
begin

end;

end.

