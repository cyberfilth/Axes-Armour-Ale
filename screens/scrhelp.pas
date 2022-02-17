(* Help screen - accessed from main game screen *)

unit scrHelp;

{$mode fpc}{$H+}

interface

uses
  ui, video, globalUtils;

(* Draw a box around the title *)
procedure drawOutline;
(* Display controls and keyboard shortcuts *)
procedure displayHelpScreen;


implementation

procedure drawOutline;
begin
  TextOut(10, 1, 'cyan', chr(218));
  for x := 11 to 69 do
    TextOut(x, 1, 'cyan', chr(196));
  TextOut(70, 1, 'cyan', chr(191));
  TextOut(10, 2, 'cyan', chr(180));
  TextOut(70, 2, 'cyan', chr(195));
  TextOut(10, 3, 'cyan', chr(192));
  for x := 11 to 69 do
    TextOut(x, 3, 'cyan', chr(196));
  TextOut(70, 3, 'cyan', chr(217));
end;

procedure displayHelpScreen;
var
  header, footer: string;
begin
  header := 'Help ' + chr(240) + ' commands and controls';
  footer := '[x] to exit this screen';
  LockScreenUpdate;
  screenBlank;
  (* Draw box around the title *)
  drawOutline;

  TextOut(ui.centreX(header), 2, 'cyan', header);
  (* This was intended to centre text on screen, no matter the terminal size.
     It doesn't seem to work as intended though *)
  TextOut(ui.centreX('Movement'), 4, 'cyan', 'Movement');
  TextOut(ui.centreX(' Your character is controlled using either the numberpad or Vi keys.'),
    5, 'cyan', ' Your character is controlled using either the numberpad or Vi keys.');
  TextOut(ui.centreX('  y  k  u      7  8  9                                              '),
    7, 'cyan', '  y  k  u      7  8  9                                              ');
  TextOut(ui.centreX('   \ | /        \ | /                You can also move up, down,    '),
    8, 'cyan', '   \ | /        \ | /                You can also move up, down,    ');
  TextOut(ui.centreX('  h-   -l      4- 5 -6               left and right using the       '),
    9, 'cyan', '  h-   -l      4- 5 -6               left and right using the       ');
  TextOut(ui.centreX('   / | \        / | \                arrow keys                     '),
    10, 'cyan', '   / | \        / | \                arrow keys                     ');
  TextOut(ui.centreX('  b  j  n      1  2  3                                              '),
    11, 'cyan', '  b  j  n      1  2  3                                              ');
  TextOut(ui.centreX('  vi-keys      numpad                                               '),
    12, 'cyan', '  vi-keys      numpad                                               ');
  TextOut(ui.centreX('Actions'), 14, 'cyan', 'Actions');
  TextOut(ui.centreX('  [g] or [,] to Get an item from the ground                         '),
    15, 'cyan', '  [g] or [,] to Get an item from the ground                         ');
  TextOut(ui.centreX('  [i] examine items in your Inventory                               '),
    16, 'cyan', '  [i] examine items in your Inventory                               ');
  TextOut(ui.centreX('  [q] Quaff / drink something in your inventory                     '),
    17, 'cyan', '  [q] Quaff / drink something in your inventory                     ');
  TextOut(ui.centreX('  [w] Wear armour or Wield a weapon                                 '),
    18, 'cyan', '  [w] Wear armour or Wield a weapon                                 ');
  TextOut(ui.centreX('  [z] Zap a magical item                                            '),
    19, 'cyan', '  [z] Zap a magical item                                            ');

  TextOut(ui.centreX(footer), 24, 'cyan', footer);
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
