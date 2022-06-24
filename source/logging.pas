(* Used for logging which procedures are called and in what order *)

unit logging;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

const
  (* Log file name *)
  C_FNAME = 'LOGFILE.txt';

var
  (* Text file used for logging *)
  tfOut: TextFile;

procedure beginLogging;
procedure logAction(textString: string);

implementation

procedure beginLogging;
begin
  AssignFile(tfOut, C_FNAME);
  rewrite(tfOut);
  writeln(tfOut, 'Initialised. Random seed is ' + IntToStr(RandSeed));
  closeFile(tfOut);
end;

procedure logAction(textString: string);
begin
  AssignFile(tfOut, C_FNAME);
  append(tfOut);
  writeln(tfOut, textString);
  CloseFile(tfOut);
end;

end.

