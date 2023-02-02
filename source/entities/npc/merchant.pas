(* Merchant - Buys and sells items *)

unit merchant;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

(* Create a merchant *)
procedure createMerchant(uniqueid, npcx, npcy: smallint);
(* The NPC takes their turn in the game loop *)
procedure takeTurn(id: smallint);

implementation

uses
  entities, globalutils, map;

procedure createMerchant(uniqueid, npcx, npcy: smallint);
begin
  (* Add a merchant to the list of creatures *)
  entities.listLength := length(entities.entityList);
  SetLength(entities.entityList, entities.listLength + 1);
  with entities.entityList[entities.listLength] do
  begin
    npcID := uniqueid;
    race := 'merchant';
    intName := 'Merchant';
    article := True;
    description := 'a merchant';
    glyph := '@';
    glyphColour := 'lightGreen';
    maxHP := 4000;
    currentHP := maxHP;
    attack := 1;
    defence := 1;
    weaponDice := 0;
    weaponAdds := 0;
    (* Uses the xpReward stat for how much money they have *)
    xpReward := 20;
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
  entities.moveNPC(id, entityList[id].posX, entityList[id].posY);
end;

end.
