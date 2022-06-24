(* Title screen *)

unit scrTitle;

{$mode fpc}{$H+}

interface

procedure displayTitleScreen(yn: byte);

implementation

uses
  ui;

procedure displayTitleScreen(yn: byte);
begin
  screenBlank;
  TextOut(18, 4, 'cyan', '                ___');
  TextOut(18, 5, 'cyan', '               / _ \');
  TextOut(18, 6, 'cyan', '              / /_\ \_  _____  ___');
  TextOut(18, 7, 'cyan', '  ,  /\  .    |  _  \ \/ / _ \/ __|');
  TextOut(18, 8, 'cyan', ' //`-||-''\\   | | | |>  <  __/\__ \_');
  TextOut(18, 9, 'cyan', '(| -=||=- |)  \_|_|_/_/\_\___||___( )');
  TextOut(18, 10, 'cyan', ' \\,-||-.//    / _ \              |/');
  TextOut(18, 11, 'cyan', '  `  ||  ''    / /_\ \_ __ _ __ ___   ___  _   _ _ __');
  TextOut(18, 12, 'cyan', '     ||       |  _  | ''__| ''_ ` _ \ / _ \| | | | ''__|');
  TextOut(18, 13, 'cyan', '     ||       | | | | |  | | | | | | (_) | |_| | |');
  TextOut(18, 14, 'cyan', '     ||       \_| |_/_|  |_| |_| |_|\___/ \__,_|_|');
  TextOut(18, 15, 'cyan', '     ||         ___     / _ \| |');
  TextOut(18, 16, 'cyan', '     ||        ( _ )   / /_\ \ | ___');
  TextOut(18, 17, 'cyan', '     ()        / _ \/\ |  _  | |/ _ \');
  TextOut(18, 18, 'cyan', '              | (_>  < | | | | |  __/');
  TextOut(18, 19, 'cyan', '               \___/\/ \_| |_/_|\___|');

  (* Check if a save file exists and display menu *)
  if (yn = 0) then
  begin
    TextOut(18, 22, 'cyan', 'n - New Game');
    TextOut(18, 23, 'cyan', 'q - Quit');
  end
  else
  begin
    TextOut(18, 22, 'cyan', 'l - Load Last Game       n - New Game');
    TextOut(18, 23, 'cyan', 'q - Quit');
  end;
end;

end.

