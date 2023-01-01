(* Additional player stats that are not shared with other entities are stored here *)

unit player_stats;

{$mode fpc}{$H+}

interface

uses
  SysUtils, video;

var
  (* Player level, dexterity, maximum vision range, enchanted weapon type and armour points *)
  playerLevel, dexterity, maxVisionRange, enchWeapType, armourPoints: smallint;
  (* Is the player Elf, Dwarf or Human. clanName is only used for Dwarven characters *)
  playerRace, clanName: shortstring;
  (* Is it possible to leave the current dungeon *)
  canExitDungeon: boolean;
  (* Is a magical weapon equipped *)
  enchantedWeaponEquipped: boolean;
  (* Is a bow equipped *)
  projectileWeaponEquipped: boolean;
  (* Is player carrying a light source *)
  lightEquipped: boolean;
  (* Number of turns light will shine *)
  lightCounter: smallint;
  (* Magical ability *)
  maxMagick, currentMagick: smallint;
  (* Durability of equipped / magical item *)
  numEquippedUses: smallint;
  (* Amount of treasure *)
  treasure: smallint;

(* Check if the player has levelled up *)
procedure checkLevel;
(* Show level up dialog *)
procedure showLevelUpOptions;
(* Increase maximum health *)
procedure increaseMaxHealth;
(* Increase attack strength *)
procedure increaseAttack;
(* Increase defence strength *)
procedure increaseDefence;
(* Increase attack & defence *)
procedure increaseAttackDefence;
(* Increase dexterity *)
procedure increaseDexterity;
(* Check the light source, decrease the timer *)
procedure processLight;

implementation

uses
  ui, entities, main, player, map, globalUtils;

procedure checkLevel;
begin
  if (playerLevel = 1) and (entityList[0].xpReward >= 100) then
    showLevelUpOptions
  else if (playerLevel = 2) and (entityList[0].xpReward >= 250) then
    showLevelUpOptions
  else if (playerLevel = 3) and (entityList[0].xpReward >= 450) then
    showLevelUpOptions
  else if (playerLevel = 4) and (entityList[0].xpReward >= 700) then
    showLevelUpOptions
  else if (playerLevel = 5) and (entityList[0].xpReward >= 1000) then
    showLevelUpOptions
  else if (playerLevel = 6) and (entityList[0].xpReward >= 1350) then
    showLevelUpOptions
  else if (playerLevel = 7) and (entityList[0].xpReward >= 1750) then
    showLevelUpOptions
  else if (playerLevel = 8) and (entityList[0].xpReward >= 2200) then
    showLevelUpOptions
  else if (playerLevel = 9) and (entityList[0].xpReward >= 2700) then
    showLevelUpOptions
  else if (playerLevel = 10) and (entityList[0].xpReward >= 3250) then
    showLevelUpOptions;
end;

procedure showLevelUpOptions;
begin
  main.gameState := stDialogLevel;
  { prepare changes to the screen }
  LockScreenUpdate;
  ui.displayDialog('level', IntToStr(playerLevel + 1));
  Inc(playerLevel);
  Inc(entityList[0].visionRange);
  Inc(maxVisionRange);
  ui.updateLevel;
  { Write those changes to the screen }
  UnlockScreenUpdate;
  { only redraws the parts that have been updated }
  UpdateScreen(False);
end;

procedure increaseMaxHealth;
var
  tempValue: real;
  NewMaxHP: smallint;
begin
  tempValue := (entityList[0].maxHP / 100) * 10;
  NewMaxHP := trunc(tempValue);
  Inc(entityList[0].maxHP, NewMaxHP);
  player.levelupHealth(player_stats.playerLevel);
  ui.updateHealth;
end;

procedure increaseAttack;
begin
  Inc(entityList[0].attack, player_stats.playerLevel);
  player.levelupHealth(player_stats.playerLevel);
  ui.updateAttack;
  ui.updateHealth;
end;

procedure increaseDefence;
begin
  Inc(entityList[0].defence, player_stats.playerLevel);
  player.levelupHealth(player_stats.playerLevel);
  ui.updateDefence;
  ui.updateHealth;
end;

procedure increaseAttackDefence;
begin
  Inc(entityList[0].defence, (player_stats.playerLevel div 2));
  Inc(entityList[0].attack, (player_stats.playerLevel div 2));
  player.levelupHealth(player_stats.playerLevel);
  ui.updateAttack;
  ui.updateDefence;
  ui.updateHealth;
end;

procedure increaseDexterity;
begin
  Inc(dexterity, (player_stats.playerLevel div 2));
  ui.updateDexterity;
end;

procedure processLight;
var
  response: smallint;
begin
  if (main.gameState <> stVillage) then
    begin
    if (lightEquipped = True) then
    begin
        Dec(lightCounter);

    (* Light starts growing dimmer *)
    if (lightCounter = 50) then
    begin
      ui.displayMessage(chr(16) + ' The light grows dimmer, your Pixie is growing weak')
    end

    else if (lightCounter = 35) and (entityList[0].visionRange > 1) then
      begin
          Dec(entityList[0].visionRange);
          entities.outOfView;
          map.notInView;
          map.loadDisplayedMap;
          ui.displayMessage(chr(16) + ' The light grows dimmer');
      end

    else if (lightCounter = 20) and (entityList[0].visionRange > 1)  then
      begin
          Dec(entityList[0].visionRange);
          entities.outOfView;
          map.notInView;
          map.loadDisplayedMap;
          ui.displayMessage(chr(16) + ' The light grows dimmer, your Pixie is dying!');
      end

    else if (lightCounter = 10) and (entityList[0].visionRange > 1)  then
      begin
          Dec(entityList[0].visionRange);
          entities.outOfView;
          map.notInView;
          map.loadDisplayedMap;
          ui.displayMessage(chr(16) + ' The light grows dimmer...');
      end

    (* The light goes out *)
    else if (lightCounter = 0) then
      begin
          response := randomRange(1, 2);
          entityList[0].visionRange := 0;
          if response = 1 then
              ui.displayMessage(chr(16) + ' The light goes out. The Pixie has expired')
          else
              ui.displayMessage(chr(16) + ' The light goes out. Your Pixie has died');
          lightEquipped := False;
          entities.outOfView;
          map.notInView;
          map.loadDisplayedMap;
          ui.displayMessage('You hear something frightful in the darkness!');
      end;
    end
    else
        begin
          killer := 'an unseen shadow';
          entityList[0].currentHP := 0;
        end;
      end;
end;

end.
