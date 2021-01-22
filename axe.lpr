program axe;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Forms, Interfaces,
  { you can add units after this }
  main;

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
