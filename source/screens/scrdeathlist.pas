(* Display number of enemies killed *)

unit scrDeathList;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, video, globalUtils, entities, combat_resolver;

(* Show the game over screen *)
procedure displayKillScreen;
(* Return number of NPC's killed *)
function countKills: smallint;
(* Count number of unique NPC types *)
function uniqueKills: smallint;

implementation

uses
  ui;

procedure displayKillScreen;
var
  { Kill message is made up of the following fragments }
  killA: array[0..15] of string = (' killed ', ' despatched ',
    ' annihilated ', ' slaughtered ', ' eradicated ', ' whacked ',
    ' massacred ', ' cut down ', ' eliminated ', ' exterminated ',
    ' butchered ', ' ended ', ' bumped off ', ' destroyed ', ' murdered ', ' wasted ');
  killB: array[0..15] of string = ('assorted ', 'various ', 'sundry ',
    'manifold ', 'a swarm of ', 'a horde of ', 'a stream of ',
    'an assortment of ', 'an array of ', 'a multitude of ',
    'a diverse range of ', 'a motley collection of ', 'an eclectic mix of ',
    'a disparate mix of ', 'a gaggle of ', 'a bestiary of ');
  killC: array[0..9] of string = ('fiends.', 'creatures.', 'monsters.',
    'enemies.', 'beasts.', 'varmints.', 'monstrosities.', 'critters.',
    'beasties.', 'terrors.');
  messageText: array[0..8] of
  string = ('But ultimately, they died before their adventure had really begun...',
    'But they fell before they had really made their mark on the world...',
    'Now their body lies in a forgotten place, food for the rats...',
    'But in the grand tapestry of life, they were merely a frayed thread. Now, they are unwound...',
    'But now their short life has ended, without fame, fortune, or fanfare...',
    'But now their short life has ended, and their name will be forgotten...',
    'But now the brief candle flame of their life has been snuffed out...',
    'But now the book of their deeds shall be closed, before the ink has even dried...',
    'But their life was ended too soon. Their ale-brothers will briefly raise a toast to their name. Before it is forgotten in time, by all...');
  separateLines: array[1..6] of shortstring = (' ', ' ', ' ', ' ', ' ', ' ');
  epitaph, A, B, C, exitMessage, deathMessage, deathNumber, killType: shortstring;
  maxStrLength, iStart, iEnd, prevEnd, arrayNumber, toteKills, i,
  lineNo, totalUnique: smallint;
begin
  A := killA[Random(15)];
  B := killB[Random(15)];
  C := killC[Random(9)];
  toteKills := countKills;
  totalUnique := uniqueKills;
  i := 0;
  killType := '';
  lineNo := 8;
  (* Set the maximum length of the string *)
  maxStrLength := 70;
  iStart := 1;
  prevEnd := 0;
  (* Set the first entry in the array *)
  arrayNumber := 1;
  iEnd := maxStrLength;
  (* Create a farewell message *)
  if (toteKills = 0) then
  begin
    epitaph := entityList[0].race + ' the ' + entityList[0].description +
      ' failed to kill anything';
    deathMessage := 'With no deeds to forget, their name will pass out of memory...';
  end
  else if (toteKills = 1) then
  begin
    epitaph := entityList[0].race + ' the ' + entityList[0].description +
      ' has one kill to their name';
    deathMessage :=
      'They made no impact on the world, their name will never be remembered...';
  end
  else if (toteKills = 2) then
  begin
    epitaph := entityList[0].race + ' the ' + entityList[0].description +
      ' managed to end two lives';
    deathMessage := 'They will soon be forgotten...';
  end
  else
  begin
    epitaph := entityList[0].race + ' the ' + entityList[0].description + A + B + C;
    deathMessage := messageText[Random(8)];
  end;
  if (toteKills = 1) then
    deathNumber := '1 enemy in total'
  else
    deathNumber := IntToStr(toteKills) + ' enemies in total';
  exitMessage := 'q - Quit game   |    x - Exit to menu';
  (* Line wrap the death message so that it fits the screen *)
  (* Loop until the end of the string *)
  while iEnd < Length(deathMessage) do
  begin
    (* Go to position 'iEnd' and check if it's a space, if not go back until a space is found *)
    while deathMessage[iEnd] <> ' ' do
    begin
      Dec(iEnd);
    end;
    (* Add that line to array *)
    separateLines[arrayNumber] := copy(deathMessage, iStart, iEnd - prevEnd);
    (* Set new starting position *)
    iStart := iEnd + 1;
    prevEnd := iEnd;
    iEnd := iEnd + maxStrLength;
    Inc(arrayNumber);
  end;
  (* Add the remaining characters to the array *)
  if (iStart < Length(deathMessage)) then
    separateLines[arrayNumber] := copy(deathMessage, iStart, Length(deathMessage));

  { Closing screen update as it is currently in the main game loop }
  UnlockScreenUpdate;
  UpdateScreen(False);

  (* prepare changes to the screen *)
  LockScreenUpdate;
  ui.screenBlank;

  TextOut(ui.centreX(epitaph), 2, 'cyan', epitaph);
  TextOut(ui.centreX(deathNumber), 3, 'cyan', deathNumber);

  (* Write the message *)
  for arrayNumber := 1 to 6 do
  begin
    TextOut(5, arrayNumber + 4, 'cyan', separateLines[arrayNumber]);
  end;

  (* Display list of entities killed *)
  if (totalUnique < 16) then
  begin
    for i := Low(deathList) to High(deathList) do
    begin
      if (deathList[i] <> 0) then
      begin
        { Get entity name }
        case i of
          0: killType := 'Cave rat';
          1: killType := 'Giant rat';
          2: killType := 'Blood bat';
          3: killType := 'Large Blood bat';
          4: killType := 'Green fungus';
          5: killType := 'Small green fungus';
          6: killType := 'Fungus person';
          7: killType := 'Hob';
          8: killType := 'Hob rock thrower';
          9: killType := 'Small hyena';
          10: killType := 'Infected hyena';
          11: killType := 'Infected Hob';
          12: killType := 'Small hornet';
          13: killType := 'Small corpse spider';
          14: killType := 'Gnome warrior';
          15: killType := 'Gnome assassin';
          else
            killType := 'unknown';
        end;
        TextOut(5, lineNo, 'cyan', IntToStr(deathList[i]) + 'x ' + killType);
        Inc(lineNo);
      end;
    end;
  end;
  { As the number of NPC's increases, format a 2 column layout. Then a second screen of NPC's }

  TextOut(centreX(exitMessage), 24, 'cyan', exitMessage);
  (* Write those changes to the screen *)
  UnlockScreenUpdate;
  (* only redraws the parts that have been updated *)
  UpdateScreen(False);
end;

function countKills: smallint;
var
  i: byte;
  total: smallint;
begin
  total := 0;
  for i := Low(deathList) to High(deathList) do
  begin
    if (deathList[i] <> 0) then
      total := total + deathList[i];
  end;
  Result := total;
end;

function uniqueKills: smallint;
var
  i: byte;
  total: smallint;
begin
  total := 0;
  for i := Low(deathList) to High(deathList) do
  begin
    if (deathList[i] <> 0) then
      Inc(total);
  end;
  Result := total;
end;

end.
