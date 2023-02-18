(* Empty merchant inventory slot *)
begin
  villageInv[i].id := i;
  villageInv[i].Name := 'Empty';
  villageInv[i].description := 'x';
  villageInv[i].article := 'x';
  villageInv[i].itemType := itmEmptySlot;
  villageInv[i].itemMaterial := matEmpty;
  villageInv[i].glyph := 'x';
  villageInv[i].glyphColour := 'x';
  villageInv[i].numUses := 0;
  villageInv[i].value := 0;
  villageInv[i].throwable := False;
  villageInv[i].throwDamage := 0;
  villageInv[i].dice := 0;
  villageInv[i].adds := 0;
  villageInv[i].useID := 0;
end;
