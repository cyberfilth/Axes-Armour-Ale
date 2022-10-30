(* Magic and Spell effects are calculated here *)

unit magicEffects;

{$mode fpc}{$H+}
{$WARN 5091 off : Local variable "$1" of a managed type does not seem to be initialized}
interface

uses
  SysUtils, video, los, items, ui, player_stats, animation;

type
  TSmallintArray = array of smallint;

(* Burn enemies in a cirle area from starting centre coordinates *)
procedure minorScorch;
(* Bewilder enemies in a circle around the player *)
procedure bewilderArea;

implementation

uses
  entities;

procedure minorScorch;
var
  i, i2, damageAmount, targetAmount, cost: smallint;
  anyTargetHit: boolean;
  targetList: TSmallintArray;
begin
  (*  Set array to 0 *)
  SetLength(targetList, 0);
  (* Cost of casting magick *)
  cost := (5 - player_stats.playerLevel);
  if (cost > player_stats.currentMagick) then
  begin
    ui.displayMessage('You don''t have enough magickal energy to cast!');
    exit;
  end;
  i := 0;
  i2 := 0;
  targetAmount := 1;
  anyTargetHit := False;
  (* Damage amount is 4 + player level *)
  damageAmount := 4 + player_stats.playerLevel;
  (* Check if any enemies are near *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      (* Area of effect is Players vision range - 1 *)
      if (los.inView(entityList[0].posX, entityList[0].posY, entityList[i].posX, entityList[i].posY, entityList[0].visionRange - 1) = True) then
      begin
        anyTargetHit := True;
        (* Add NPC to list of targets *)
        SetLength(targetList, targetAmount);
        targetList[targetAmount - 1] := i;
        Inc(targetAmount);
      end;
    end;
  end;
  (* Draw each affected NPC in red *)
  if (anyTargetHit = True) then
    animation.areaBurnEffect(targetList);

  (* Deal damage *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      (* Area of effect is Players vision range - 1 *)
      if (los.inView(entityList[0].posX, entityList[0].posY,
        entityList[i].posX, entityList[i].posY, entityList[0].visionRange - 1) =
        True) then
      begin
        entityList[i].currentHP := (entityList[i].currentHP - damageAmount);
        (* Check if NPC killed *)
        if (entityList[i].currentHP < 1) then
          entities.killEntity(i);
      end;
    end;
  end;
  (* Check if any flammable items are near *)
  for i2 := 0 to High(itemList) do
  begin
    (* First check an item is visible and flammable *)
    if (itemList[i2].inView = True) and (itemList[i2].itemMaterial = matFlammable) and (itemList[i2].itemType <> itmEmptySlot) then
    begin
      itemList[i2].itemType := itmEmptySlot;
      itemList[i2].onMap := False;
      if (itemList[i2].itemArticle <> '') then
        ui.displayMessage(itemList[i2].itemArticle + ' ' + itemList[i2].itemName + ' ignites!')
      else
        ui.displayMessage(itemList[i2].itemName + ' ignites!');
    end;
  end;

  (* Display if there were any hits or not *)
  if (anyTargetHit = False) then
    ui.displayMessage('Flames shoot out, but hit nothing')
  else
  begin
    ui.displayMessage('Flames scorch your enemies');
  end;
  Dec(player_stats.currentMagick, cost);
end;

procedure bewilderArea;
var
  i, damageAmount, targetAmount, cost: smallint;
  anyTargetHit: boolean;
  targetList: TSmallintArray;
begin
  (*  Set array to 0 *)
  SetLength(targetList, 0);
  (* Cost of casting magick *)
  cost := (5 - player_stats.playerLevel);
  if (cost > player_stats.currentMagick) then
  begin
    ui.displayMessage('You don''t have enough magickal energy to cast!');
    exit;
  end;
  i := 0;
  targetAmount := 1;
  anyTargetHit := False;
  (* Damage amount is equal to player level *)
  damageAmount := player_stats.playerLevel;
  (* Check if any enemies are near *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      (* Area of effect is Players vision range - 1 *)
      if (los.inView(entityList[0].posX, entityList[0].posY, entityList[i].posX, entityList[i].posY, entityList[0].visionRange - 1) = True) then
      begin
        anyTargetHit := True;
        (* Add NPC to list of targets *)
        SetLength(targetList, targetAmount);
        targetList[targetAmount - 1] := i;
        Inc(targetAmount);
      end;
    end;
  end;
  (* Draw each affected NPC in light blue *)
  if (anyTargetHit = True) then
    animation.areaBewilderEffect(targetList);

  (* Deal damage *)
  for i := 1 to entities.npcAmount do
  begin
    (* First check an NPC is visible (and not dead) *)
    if (entityList[i].inView = True) and (entityList[i].isDead = False) then
    begin
      (* Area of effect is Players vision range - 1 *)
      if (los.inView(entityList[0].posX, entityList[0].posY, entityList[i].posX, entityList[i].posY, entityList[0].visionRange - 1) = True) then
      begin
        (* Initial damage *)
        entityList[i].currentHP := (entityList[i].currentHP - damageAmount);
        (* Bewilder NPC's *)
        entityList[i].stsBewild := True;
        entityList[i].tmrBewild := 4 + player_stats.playerLevel;
        (* Check if NPC killed *)
        if (entityList[i].currentHP < 1) then
          entities.killEntity(i);
      end;
    end;
  end;

  (* Display if there were any hits or not *)
  if (anyTargetHit = False) then
    ui.displayMessage('Magick shoots out, but hits nothing')
  else
  begin
    ui.displayMessage('Bewilderment curse affects your enemies');
  end;
  Dec(player_stats.currentMagick, cost);
end;

end.
