(* Helper functions when debugging, printing out maps, topping up HP, etc *)

unit debuggingFunctions;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, entities, player_stats;

(* Increases HP and light timer, to aid exploration *)
procedure topUpStats;

implementation

procedure topUpStats;
begin
  Inc(entityList[0].maxHP, 100);
  entityList[0].currentHP:= entityList[0].maxHP;
  Inc(player_stats.lightCounter, 500);
end;

end.

