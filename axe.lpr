program axe;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  { you can add units after this }
  main, map, cave, player, fov, grid_dungeon, ui, entities, cave_rat, plot_gen,
  los, items, ale_tankard, player_inventory, hyena, dagger, leather_armour1,
  basic_club, cave_bear, barrel, cloth_armour1;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='Axes, Armour & Ale';
  {$IF FPC_FULLVERSION >= 30004}
  Application.Scaled := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TGameWindow, GameWindow);
  Application.Run;
end.
