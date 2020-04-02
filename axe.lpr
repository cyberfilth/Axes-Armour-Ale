program axe;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  { you can add units after this }
  main,
  map,
  cave,
  player,
  fov,
  grid_dungeon,
  ui, entities,
  cave_rat, plot_gen;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='Axes, Armour & Ale';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TGameWindow, GameWindow);
  Application.Run;
end.
