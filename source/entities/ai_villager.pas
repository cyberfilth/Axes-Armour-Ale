(* Shared Artificial Stupidity unit for villager AI *)

unit ai_villager;

{$mode fpc}{$H+}

interface

uses
  SysUtils, Math;

(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Villager talks *)
procedure chat(id: smallint);

implementation

uses
  entities, map, ui, globalUtils;

procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  { Set NPC state }
  entityList[id].state := stateNeutral;
  attempts := 0;
  testx := 0;
  testy := 0;
  direction := 0;
  repeat
    (* Reset values after each failed loop so they don't keep dec/incrementing *)
    testx := spx;
    testy := spy;
    direction := random(6);
    (* limit the number of attempts to move so the game doesn't hang if NPC is stuck *)
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

procedure chat(id: smallint);
begin

end;

end.