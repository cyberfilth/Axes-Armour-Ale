(* Unit responsible for NPC stat, initialising enemies and utility functions *)

unit entities;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
{$RANGECHECKS OFF}

interface

uses
  SysUtils, Classes, globalUtils, player_stats,
  { List of creatures }
  cave_rat, giant_cave_rat, blood_bat, green_fungus, redcap_lesser,
  redcap_lesser_lobber, small_green_fungus, large_blood_bat, small_hyena,
  redcap_fungus, mushroom_person, hyena_fungus, small_hornet, small_corpse_spider,
  gnome_warrior, gnome_assassin, web, crypt_wolf, blue_fungus, embalming_spider,
  gnome_cultist, bogle_drunk, ghoul_lvl1, skeleton_lvl1, zombie_weak, goblin_necromancer;

type { NPC attitudes }
  Tattitudes = (stateNeutral, stateHostile, stateEscape);

type {NPC factions / groups }
  Tfactions = (redcapFaction, bugFaction, animalFaction, fungusFaction, undeadFaction, trapFaction);

type
  (* Store information about NPC's *)
  { Creature }
  Creature = record
    (* Unique ID *)
    npcID: smallint;
    (* Creature type *)
    race: shortstring;
    (* Internal name *)
    intName: shortstring;
    (* Article (the) *)
    article: boolean;
    (* Description of creature *)
    description: string;
    (* health and position on game map *)
    currentHP, maxHP, attack, defence, posX, posY, targetX, targetY,
    xpReward, visionRange: smallint;
    (* Weapon stats *)
    weaponDice, weaponAdds: smallint;
    (* Character used to represent NPC on game map *)
    glyph: shortstring;
    (* Colour of the glyph *)
    glyphColour: shortstring;
    (* Count of turns the entity will keep tracking the player when they're out of sight *)
    moveCount: smallint;
    (* Is the NPC in the players FoV *)
    inView: boolean;
    (* First time the player discovers the NPC *)
    discovered: boolean;
    (* Some entities block movement, i.e. barrels *)
    blocks: boolean;
    (* NPC faction *)
    faction: Tfactions;
    (* NPC finite state *)
    state: Tattitudes;
    (* Is a weapon equipped *)
    weaponEquipped: boolean;
    (* Is Armour equipped *)
    armourEquipped: boolean;
    (* Has the NPC been killed, to be removed at end of game loop *)
    isDead: boolean;
    (* status effects *)
    stsDrunk, stsPoison, stsBewild: boolean;
    (* status timers *)
    tmrDrunk, tmrPoison, tmrBewild: smallint;
    (* Pathfinding variables *)
    hasPath, destinationReached: boolean;
    smellPath: array[1..30] of TPoint;
    (* The procedure that allows each NPC to take a turn *)
    procedure entityTakeTurn(i: smallint);
    (* Actions taken when creature dies *)
    procedure entityDeath(i: smallint);
  end;

var
  entityList: array of Creature;
  npcAmount, listLength: byte;

(* Add player to list of creatures on the map *)
procedure spawnPlayer;
(* Handle death of NPC's *)
procedure killEntity(id: smallint);
(* Update NPCs X, Y coordinates *)
procedure moveNPC(id, newX, newY: smallint);
(* Get creature currentHP at coordinates *)
function getCreatureHP(x, y: smallint): smallint;
(* Get creature maxHP at coordinates *)
function getCreatureMaxHP(x, y: smallint): smallint;
(* Get creature ID at coordinates *)
function getCreatureID(x, y: smallint): smallint;
(* Get creature name at coordinates *)
function getCreatureName(x, y: smallint): shortstring;
(* Get creature description *)
function getCreatureDescription(x, y: smallint): shortstring;
(* Check if creature is visible at coordinates *)
function isCreatureVisible(x, y: smallint): boolean;
(* Ensure all NPC's are correctly occupying tiles *)
procedure occupyUpdate;
(* Update the map display to show all NPC's *)
procedure redrawMapDisplay(id: byte);
(* Clear list of NPC's *)
procedure newFloorNPCs;
(* Count all living NPC's *)
function countLivingEntities: byte;
(* When the light source goes out *)
procedure outOfView;
(* Initialise pathfinding array *)
procedure initPath(id: smallint);
(* Call Creatures.takeTurn procedure *)
procedure NPCgameLoop;

implementation

uses
  player, map, ui;

procedure spawnPlayer;
begin
  npcAmount := 1;
  (*  initialise array *)
  SetLength(entityList, 0);
  (* Add the player to Entity list *)
  player.createPlayer;
end;

procedure killEntity(id: smallint);
begin
  Inc(entityList[0].xpReward, entityList[id].xpReward);
  ui.updateXP;
  entityList[id].entityDeath(id);
  entityList[id].isDead := True;
  entityList[id].glyph := '.';
  entityList[id].blocks := False;
  map.unoccupy(entityList[id].posX, entityList[id].posY);
end;

procedure moveNPC(id, newX, newY: smallint);
begin
  (* mark tile as unoccupied *)
  map.unoccupy(entityList[id].posX, entityList[id].posY);
  (* update new position *)
  if (map.isOccupied(newX, newY) = True) and (getCreatureID(newX, newY) <> id) then
  begin
    newX := entityList[id].posX;
    newY := entityList[id].posY;
  end;
  entityList[id].posX := newX;
  entityList[id].posY := newY;

  (* Check if NPC in players FoV *)
  if (map.canSee(newX, newY) = True) then
  begin
    entityList[id].inView := True;
    if (entityList[id].discovered = False) then
    begin
      ui.displayMessage('You see ' + entityList[id].description);
      entityList[id].discovered := True;
    end;
    (* Draw to map display *)
    map.mapDisplay[newY, newX].GlyphColour := entityList[id].glyphColour;
    map.mapDisplay[newY, newX].Glyph := entityList[id].glyph;
  end
  else
    entityList[id].inView := False;
  (* mark tile as occupied *)
  map.occupy(newX, newY);
end;

function getCreatureHP(x, y: smallint): smallint;

var
  i: smallint;
begin
  Result := 0;
  for i := 0 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := entityList[i].currentHP;
  end;
end;

function getCreatureMaxHP(x, y: smallint): smallint;

var
  i: smallint;
begin
  Result := 0;
  for i := 0 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := entityList[i].maxHP;
  end;
end;

function getCreatureID(x, y: smallint): smallint;

var
  i: smallint;
begin
  Result := 0;
  { initialise variable }
  for i := 0 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := i;
  end;
end;

function getCreatureName(x, y: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
  for i := 0 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := entityList[i].race;
  end;
end;

function getCreatureDescription(x, y: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
  for i := 0 to npcAmount do
  begin
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      Result := entityList[i].description;
  end;
end;

function isCreatureVisible(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 0 to npcAmount do
    if (entityList[i].posX = x) and (entityList[i].posY = y) then
      if (entityList[i].inView = True) and (entityList[i].glyph <> '.') and (player_stats.lightEquipped = True) then
        Result := True;
end;

procedure occupyUpdate;
var
  i: smallint;
begin
  for i := 1 to npcAmount do
    if (entityList[i].isDead = False) then
      map.occupy(entityList[i].posX, entityList[i].posY);
end;

procedure redrawMapDisplay(id: byte);
begin
(* Redrawing NPC directly to map display as looping through
     entity list in the camera unit wasn't working *)
  if (entityList[id].isDead = False) and (entityList[id].inView = True) then
  begin
    map.mapDisplay[entityList[id].posY, entityList[id].posX].GlyphColour := entityList[id].glyphColour;
    map.mapDisplay[entityList[id].posY, entityList[id].posX].Glyph := entityList[id].glyph;
  end;
end;

procedure newFloorNPCs;
begin
  (* Clear the current NPC amount *)
  npcAmount := 1;
  SetLength(entityList, 1);
end;

function countLivingEntities: byte;

var
  i, Count: byte;
begin
  Count := 0;
  for i := 1 to npcAmount do
    if (entityList[i].isDead = False) then
      Inc(Count);
  Result := Count;
end;

procedure outOfView;
var
  i: smallint;
begin
  for i := 1 to npcAmount do
    entityList[i].inView := False;
end;

procedure initPath(id: smallint);
var
  i: byte;
begin
  for i := 1 to 30 do
  begin
    entityList[id].smellPath[i].X := 0;
    entityList[id].smellPath[i].Y := 0;
  end;
end;

procedure NPCgameLoop;
var
  i: smallint;
begin
  for i := 1 to High(entityList) do
    if (entityList[i].glyph <> '.') then
      entityList[i].entityTakeTurn(i);
end;

{ Creature }

procedure Creature.entityTakeTurn(i: smallint);
begin
  case (entityList[i].intName) of
    'CaveRat': cave_rat.takeTurn(i);
    'GiantRat': giant_cave_rat.takeTurn(i);
    'BloodBat':
      begin
        blood_bat.takeTurn(i);
        blood_bat.takeTurn(i);
      end;
    'LargeBloodBat': large_blood_bat.takeTurn(i);
    'GreenFungus': green_fungus.takeTurn(i);
    'SmallGreenFungus': small_green_fungus.takeTurn(i);
    'Matango': mushroom_person.takeTurn(i);
    'Hob': redcap_lesser.takeTurn(i);
    'HobLobber': redcap_lesser_lobber.takeTurn(i);
    'smallHyena': small_hyena.takeTurn(i);
    'hyenaFungus': hyena_fungus.takeTurn(i);
    'HobFungus': redcap_fungus.takeTurn(i);
    'smallHornet': small_hornet.takeTurn(i);
    'smlCorpseSpider': small_corpse_spider.takeTurn(i);
    'GnmWarr': gnome_warrior.takeTurn(i);
    'GnmAss': gnome_assassin.takeTurn(i);
    'stickyWeb': web.takeTurn(i);
    'crptWolf': crypt_wolf.takeTurn(i);
    'BlueFungus': blue_fungus.takeTurn(i);
    'embalmSpider': embalming_spider.takeTurn(i);
    'GnmCult': gnome_cultist.takeTurn(i);
    'drunkBogle': bogle_drunk.takeTurn(i);
    'ghoulLVL1': ghoul_lvl1.takeTurn(i);
    'skeletonLVL1': skeleton_lvl1.takeTurn(i);
    'zombieWeak': zombie_weak.takeTurn(i);
    'GobNecro': goblin_necromancer.takeTurn(i);
  end;
  (* Occupy their current tile *)
  occupyUpdate;
end;

procedure Creature.entityDeath(i: smallint);
begin
  case (entityList[i].intName) of
    'CaveRat': cave_rat.death;
    'GiantRat': giant_cave_rat.death;
    'BloodBat': blood_bat.death;
    'LargeBloodBat': large_blood_bat.death;
    'GreenFungus': green_fungus.death;
    'SmallGreenFungus': small_green_fungus.death;
    'Matango': mushroom_person.death;
    'Hob': redcap_lesser.death;
    'HobLobber': redcap_lesser_lobber.death;
    'smallHyena': small_hyena.death;
    'hyenaFungus': hyena_fungus.death;
    'HobFungus': redcap_fungus.death;
    'smallHornet': small_hornet.death;
    'smlCorpseSpider': small_corpse_spider.death;
    'GnmWarr': gnome_warrior.death;
    'GnmAss': gnome_assassin.death(i);
    'crptWolf': crypt_wolf.death;
    'BlueFungus': blue_fungus.death;
    'embalmSpider': embalming_spider.death;
    'GnmCult': gnome_cultist.death(i);
    'drunkBogle': bogle_drunk.death(i);
    'ghoulLVL1': ghoul_lvl1.death;
    'skeletonLVL1': skeleton_lvl1.death(i);
    'zombieWeak': zombie_weak.death(i);
    'GobNecro': goblin_necromancer.death(i);
  end;
end;

end.
