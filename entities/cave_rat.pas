(* Weak enemy with simple AI *)

unit cave_rat;

{$mode objfpc}{$H+}

interface

uses
  Graphics, map;

(* Create a cave rat *)
procedure createCaveRat(uniqueid, npcx, npcy: smallint);
(* Take a turn *)
procedure takeTurn(id, spx, spy: smallint);
(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);

implementation

uses
  entities;

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
    glyphColour:=clYellow;
    currentHP := 2;
    maxHP := 10;
    attack := 3;
    defense := 2;
    inView := False;
    discovered:= False;
    isDead := False;
    posX := npcx;
    posY := npcy;
  end;
end;

procedure takeTurn(id, spx, spy: smallint);
begin
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
      exit;
    end;
    case direction of
      0: Dec(testy);
      1: Inc(testy);
      2: Dec(testx);
      3: Inc(testx);
      4: testx := spx;
      5: testy := spy;
    end
  until (map.canMove(testx, testy) = True) and (map.isOccupied(testx, testy) = False);
  entities.moveNPC(id, testx, testy);
end;

end.

