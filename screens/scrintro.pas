(* Introduction screen *)

unit scrIntro;

{$mode fpc}{$H+}

interface

uses
  ui, video, globalUtils;

procedure displayIntroScreen;

implementation

procedure displayIntroScreen;
var
  header, insult, sounds: string;
  prefix: smallint;
begin
  (* Randomly select header text *)
  prefix := randomRange(1, 4);
  if (prefix = 1) then
    header := 'Thrown into the smugglers cave'
  else if (prefix = 2) then
    header := 'Kidnap! Waylaid in the night'
  else
    header := 'Every adventure begins with a single... fall';

  (* Randomly select insult *)
  prefix := randomRange(1, 5);
  if (prefix = 1) then
    insult := 'toad puke'
  else if (prefix = 2) then
    insult := 'pond scum'
  else if (prefix = 3) then
    insult := 'dung smear'
  else if (prefix = 4) then
    insult := 'slug'
  else
    insult := 'fish breath';

  (* Randomly select sounds *)
  prefix := randomRange(1, 4);
  if (prefix = 1) then
    sounds := 'scratching'
  else if (prefix = 2) then
    sounds := 'chittering'
  else
    sounds := 'squealing';

  (* prepare changes to the screen *)
  LockScreenUpdate;
  screenBlank;
  TextOut(ui.centreX(header), 2, 'cyan', header);
  { Flavour text }
  TextOut(3, 6, 'cyan',
    'The smugglers roughly grab you and throw you down the crudely carved');
  TextOut(3, 7, 'cyan',
    'stairs, into the cavern. You gaze around, struggling to penetrate the');
  TextOut(3, 8, 'cyan', 'darkness by your feeble torchlight.');
  TextOut(3, 9, 'cyan', '"Somewhere down there is the map, stolen by those thieving imps.');
  TextOut(4, 10, 'cyan', 'Find it and bring it back, you little ' + insult + '"');
  TextOut(3, 12, 'cyan', 'The door slams firmly closed behind you. Ignoring the sound of');
  TextOut(3, 13, 'cyan', sounds + ' coming from the darkness, you step forward...');

  TextOut(ui.centreX('[SPACE] to continue'), 24, 'cyan', '[SPACE] to continue');
  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

end.
