(* Shown when exiting the Smugglers cave and starting the larger adventure *)

unit scrWinAlpha;

{$mode fpc}{$H+}

interface

uses
  SysUtils, video, ui, universe;

(* Show the Win screen *)
procedure displayWinscreen;

implementation

procedure displayWinscreen;
begin
  { Closing screen update as it is currently in the main game loop }
  UnlockScreenUpdate;
  UpdateScreen(False);
  (* prepare changes to the screen *)
  LockScreenUpdate;

  ui.screenBlank;
  TextOut(centreX('You exit the cave!'), 2, 'white', 'You exit the cave!');
  TextOut(5, 5, 'cyan', 'Battered and bruised, you climb out of the cave and hand over');
  TextOut(5, 6, 'cyan', 'the map. The smugglers grin, thank you for your trouble, and');
  TextOut(5, 7, 'cyan', 'leave.');
  TextOut(5, 9, 'cyan', 'You are once again alone, on the isle of Ellan Toll. The way');
  TextOut(5, 10, 'cyan', 'ahead promises adventure, and more than a little danger.');
  TextOut(5, 11, 'cyan', 'There are ruins to explore and treasure to plunder, you set out...');

  UnlockScreenUpdate;
  UpdateScreen(False);
  (* Create overworld map *)
  universe.createEllanToll;
  LockScreenUpdate;
  TextOut(centreX('x - to continue'), 24, 'cyan', 'x - to continue');
  UnlockScreenUpdate;
  UpdateScreen(False);
end;

end.
