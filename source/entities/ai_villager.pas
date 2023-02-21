(* Shared Artificial Stupidity unit for villager AI *)

unit ai_villager;

{$mode fpc}{$H+}

interface

uses
  SysUtils;

(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Villager talks *)
procedure chat;
(* Village idiot spouts random phrases, and hints *)
procedure ramblings;

implementation

uses
  entities, map, ui, globalUtils;

procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  { Set NPC state }
  entityList[id].state := stateNeutral;
  attempts := 0;
  testx := 0;
  testy := 0;
  direction := 0;
  repeat
    (* Reset values after each failed loop so they don't keep dec/incrementing *)
    testx := spx;
    testy := spy;
    direction := random(6);
    (* limit the number of attempts to move so the game doesn't hang if NPC is stuck *)
    Inc(attempts);
    if attempts > 10 then
    begin
      entities.moveNPC(id, spx, spy);
      exit;
    end;
    case direction of
      0: Dec(testy);
      1: Inc(testy);
      2: Dec(testx);
      3: Inc(testx);
      4: testx := spx;
      5: testy := spy;
    end
  until (map.canMove(testx, testy) = True) and (map.isOccupied(testx, testy) = False);
  entities.moveNPC(id, testx, testy);
end;

procedure chat;
var
  response: packed array[0..21] of
  shortString = ('Allreet!', 'How do!', 'Greetings', 'Any news?', 'Seen any Orcs lately?', 'My bowels haven''t moved in a week...', 
                'There''s raiding parties about', 'You''re funny lookin''', 'It''s uncivilised up North!', 'Outta the way!', 'You still ''ere?',
                'Ooh look!, an ''Adventurer''. Bloody murderer more like!', 'There''s been no ale deliveries in weeks!', 'Killed any interestin'' people lately?', 
                'Ain''t nuthin'' ''ere but mud, misery and a merchant', 'Nuthin'' ''ere for you, fancy-pants!', 'What do you want?', 'I don''t have all day',
                'Don''t bother me', 'I''m not in the mood for company', 'Can''t you see I''m busy?', 'Stop bothering me');
  choice: smallint;
begin
  choice := randomRange(0, 2);
  if (choice = 1) then
    begin
      choice := randomRange(0, High(response));
      ui.displayMessage('The villager mutters...');
      ui.displayMessage('"' + response[choice] + '"');
    end
    else
      ui.displayMessage('The villager grunbles');
end;

procedure ramblings;
var
  response: packed array[0..15] of
  shortString = ('Callooh Callay, what a glorious day!', 'I''ve seen ghosts and spooks abroad!', 'My cow was laughing at me this morn''',
  							'It''s all about the axes you see...' , 'Miserable buggers in this village!', 'Orgone, it''s all gone', 'Hogwash and Balderdash! Those are my pigs!',
  							'Fractured land, fractured mind. Symmetry init?', 'Outta the way, important mad stuff to do!', 'Why is orange jam called ''marmalade''?',
  							'...flattened my rhubarb patch...', 'It''s turtles all the way down', 'It''s different every time...', 'An adventurer needs armour... and a toothbrush',
								'Destiny. But destined for what, eh?', 'Not everythings a fight, ya know?');
  choice: smallint;
begin
	choice := randomRange(0, 2);
	if (choice = 1) then
    begin
      choice := randomRange(0, High(response));
      ui.displayMessage('The villager mutters...');
      ui.displayMessage('"' + response[choice] + '"');
    end
    else if (choice = 0) then
      ui.displayMessage('The mad-looking villager laughs')
    else
      ui.displayMessage('The villager mutters to himself');  
end;

end.