(* Used for logging which procedures are called and in what order *)

unit logging;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, globalUtils;

var
  (* Text file used for logging *)
  tfOut: TextFile;
  (* Log file name *)
  C_FNAME : shortstring;

procedure beginLogging;
procedure logAction(textString: string);

implementation

procedure beginLogging;
begin
  C_FNAME := (globalUtils.saveDirectory + PathDelim + 'LOGFILE.dat');
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

