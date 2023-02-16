(* Empty inventory slot *)
  begin
      itemID := itemNumber;
      itemName := 'empty';
      itemDescription := '';
      itemArticle := '';
      itemType := itmEmptySlot;
      itemMaterial := matEmpty;
      useID := 1;
      glyph := 'x';
      glyphColour := 'lightCyan';
      inView := False;
      posX := 1;
      posY := 1;
      NumberOfUses := 0;
      value := 0;
      onMap := False;
      throwable := False;
      throwDamage := 0;
      dice := 0;
      adds := 0;
      discovered := False;
    end; 
