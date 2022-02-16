(* Help screen - accessed from main game screen *)

unit scrHelpMainGame;

{$mode fpc}{$H+}

interface

uses
  ui, video, globalUtils;

procedure displayHelpScreen;


implementation

procedure displayHelpScreen;
var
  header, footer: string;
begin
  header := 'Axes, Armour & Ale :: Commands';
  footer := '[x] to exit this screen';
  LockScreenUpdate;
  screenBlank;
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
