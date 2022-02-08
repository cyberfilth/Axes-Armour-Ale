(* Unit responsible for saving and loading data *)

unit file_handling;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, DOM, XMLWrite, XMLRead, TypInfo, globalutils, universe,
  cave, items;

(* Write a newly generate level of a dungeon to disk *)
procedure writeNewDungeonLevel(idNumber, lvlNum, totalDepth, totalRooms: byte;
  dtype: dungeonTerrain);
(* Write explored dungeon level to disk *)
procedure saveDungeonLevel;
(* Read dungeon level from disk *)
procedure loadDungeonLevel(lvl: byte);
(* Delete saved game files *)
procedure deleteGameData;
(* Load a saved game *)
procedure loadGame;
(* Save game state to file *)
procedure saveGame;

implementation

uses
  map, main, entities, player_stats, player_inventory;

procedure writeNewDungeonLevel(idNumber, lvlNum, totalDepth, totalRooms: byte;
  dtype: dungeonTerrain);

var
  r, c, id_int: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName, Value: shortstring;

  procedure AddElement(Node: TDOMNode; Name, Value: UnicodeString);
  var
    NameNode, ValueNode: TDomNode;
  begin
    { creates future Node/Name }
    NameNode := Doc.CreateElement(Name);
    { creates future Node/Name/Value }
    ValueNode := Doc.CreateTextNode(Value);
    { place value in place }
    NameNode.Appendchild(ValueNode);
    { place Name in place }
    Node.Appendchild(NameNode);
  end;

  function AddChild(Node: TDOMNode; ChildName: shortstring): TDomNode;

  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(UTF8Decode(ChildName));
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
  id_int := 0;
  dfileName := globalUtils.saveDirectory + PathDelim + 'd_' +
    IntToStr(idNumber) + '_f' + IntToStr(lvlNum) + '.dat';
  try
    { Create a document }
    Doc := TXMLDocument.Create;
    { Create a root node }
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    (* Level data *)
    DataNode := AddChild(RootNode, 'levelData');
    AddElement(datanode, 'dungeonID', UTF8Decode(IntToStr(idNumber)));
    AddElement(datanode, 'canExitDungeon', UTF8Decode(BoolToStr(False)));
    AddElement(datanode, 'title', universe.title);
    AddElement(datanode, 'floor', UTF8Decode(IntToStr(lvlNum)));
    AddElement(datanode, 'levelVisited', UTF8Decode(BoolToStr(False)));
    AddElement(datanode, 'itemsOnThisFloor', UTF8Decode(IntToStr(0)));
    AddElement(datanode, 'entitiesOnThisFloor', UTF8Decode(IntToStr(0)));
    AddElement(datanode, 'totalDepth', UTF8Decode(IntToStr(totalDepth)));
    WriteStr(Value, dungeonType);
    AddElement(datanode, 'mapType', UTF8Decode(Value));
    AddElement(datanode, 'totalRooms', UTF8Decode(IntToStr(totalRooms)));

    (* map tiles *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        Inc(id_int);
        DataNode := AddChild(RootNode, 'map_tiles');
        TDOMElement(dataNode).SetAttribute('id', UTF8Decode(IntToStr(id_int)));
        { if dungeon type is a cave }
        if (dType = tCave) then
        begin
          if (cave.terrainArray[r][c] = '*') then
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(True)))
          else
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(False)));
        end;
        AddElement(datanode, 'Visible', UTF8Decode(BoolToStr(False)));
        AddElement(datanode, 'Occupied', UTF8Decode(BoolToStr(False)));
        AddElement(datanode, 'Discovered', UTF8Decode(BoolToStr(False)));
        { if dungeon type is a cave }
        if (dType = tCave) then
        begin
          AddElement(datanode, 'Glyph', UTF8Decode(cave.terrainArray[r][c]));
        end;
      end;
    end;

    (* Save XML as a .dat file *)
    WriteXMLFile(Doc, dfileName);
  finally
    { free memory }
    Doc.Free;
  end;
end;

procedure saveDungeonLevel;
var
  r, c, id_int: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName, Value: shortstring;

  procedure AddElement(Node: TDOMNode; Name, Value: shortstring);

  var
    NameNode, ValueNode: TDomNode;
  begin
    { creates future Node/Name }
    NameNode := Doc.CreateElement(UTF8Decode(Name));
    { creates future Node/Name/Value }
    ValueNode := Doc.CreateTextNode(UTF8Decode(Value));
    { place value in place }
    NameNode.Appendchild(ValueNode);
    { place Name in place }
    Node.Appendchild(NameNode);
  end;

  function AddChild(Node: TDOMNode; ChildName: shortstring): TDomNode;
  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(UTF8Decode(ChildName));
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
  id_int := 0;
  dfileName := (globalUtils.saveDirectory + PathDelim + 'd_' +
    IntToStr(uniqueID) + '_f' + IntToStr(currentDepth) + '.dat');
  try
    { Create a document }
    Doc := TXMLDocument.Create;
    { Create a root node }
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    (* Level data *)
    DataNode := AddChild(RootNode, 'levelData');
    AddElement(datanode, 'dungeonID', IntToStr(uniqueID));
    AddElement(datanode, 'title', UTF8Encode(universe.title));
    AddElement(datanode, 'floor', IntToStr(currentDepth));
    AddElement(datanode, 'levelVisited', BoolToStr(True));
    AddElement(datanode, 'itemsOnThisFloor', IntToStr(items.countNonEmptyItems));
    AddElement(datanode, 'entitiesOnThisFloor', IntToStr(entities.countLivingEntities));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
    WriteStr(Value, dungeonType);
    AddElement(datanode, 'mapType', Value);
    AddElement(datanode, 'totalRooms', IntToStr(totalRooms));

    (* map tiles *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        Inc(id_int);
        DataNode := AddChild(RootNode, 'map_tiles');
        TDOMElement(dataNode).SetAttribute('id', UTF8Decode(IntToStr(maparea[r][c].id)));
        AddElement(datanode, 'Blocks', BoolToStr(map.maparea[r][c].Blocks));
        AddElement(datanode, 'Visible', BoolToStr(map.maparea[r][c].Visible));
        AddElement(datanode, 'Occupied', BoolToStr(map.maparea[r][c].Occupied));
        AddElement(datanode, 'Discovered', BoolToStr(map.maparea[r][c].Discovered));
        AddElement(datanode, 'Glyph', map.maparea[r][c].Glyph);
      end;
    end;

    (* Items on the map *)
    for i := 1 to items.itemAmount do
      (* Don't save empty items *)
      if (items.itemList[i].itemType <> itmEmptySlot) then
      begin
        begin
          DataNode := AddChild(RootNode, 'Items');
          TDOMElement(dataNode).SetAttribute('itemID', UTF8Decode(IntToStr(itemList[i].itemID)));
          AddElement(DataNode, 'Name', itemList[i].itemName);
          AddElement(DataNode, 'description', itemList[i].itemDescription);
          AddElement(DataNode, 'article', itemList[i].itemArticle);
          WriteStr(Value, itemList[i].itemType);
          AddElement(DataNode, 'itemType', Value);
          WriteStr(Value, itemList[i].itemMaterial);
          AddElement(DataNode, 'itemMaterial', Value);
          AddElement(DataNode, 'useID', IntToStr(itemList[i].useID));

          { Convert extended ASCII to plain text }
          if (itemList[i].glyph = chr(24)) then
            AddElement(DataNode, 'glyph', '|')
          else if (itemList[i].glyph = chr(186)) then
            AddElement(DataNode, 'glyph', '=')
          else
            AddElement(DataNode, 'glyph', itemList[i].glyph);

          AddElement(DataNode, 'glyphColour', itemList[i].glyphColour);
          AddElement(DataNode, 'inView', BoolToStr(itemList[i].inView));
          AddElement(DataNode, 'posX', IntToStr(itemList[i].posX));
          AddElement(DataNode, 'posY', IntToStr(itemList[i].posY));
          AddElement(DataNode, 'onMap', BoolToStr(itemList[i].onMap));
          AddElement(DataNode, 'discovered', BoolToStr(itemList[i].discovered));
        end;
      end;

    { Entities on the map }
    for i := 1 to entities.npcAmount do
     (* Don't save dead entities *)
      if (entities.entityList[i].isDead = False) then
      begin
        begin
          DataNode := AddChild(RootNode, 'NPCdata');
          AddElement(DataNode, 'npcID', IntToStr(entities.entityList[i].npcID));
          AddElement(DataNode, 'race', entities.entityList[i].race);
          AddElement(DataNode, 'intName', entities.entityList[i].intName);
          AddElement(DataNode, 'article', BoolToStr(entities.entityList[i].article));
          AddElement(DataNode, 'description', entities.entityList[i].description);

           { Convert extended ASCII to plain text }
          if (entities.entityList[i].glyph = chr(1)) then
            AddElement(DataNode, 'glyph', 'h')
          else
            AddElement(DataNode, 'glyph', entities.entityList[i].glyph);

          AddElement(DataNode, 'glyphColour', entities.entityList[i].glyphColour);
          AddElement(DataNode, 'maxHP', IntToStr(entities.entityList[i].maxHP));
          AddElement(DataNode, 'currentHP', IntToStr(entities.entityList[i].currentHP));
          AddElement(DataNode, 'attack', IntToStr(entities.entityList[i].attack));
          AddElement(DataNode, 'defence', IntToStr(entities.entityList[i].defence));
          AddElement(DataNode, 'weaponDice', IntToStr(entities.entityList[i].weaponDice));
          AddElement(DataNode, 'weaponAdds', IntToStr(entities.entityList[i].weaponAdds));
          AddElement(DataNode, 'xpReward', IntToStr(entities.entityList[i].xpReward));
          AddElement(DataNode, 'visRange', IntToStr(entities.entityList[i].visionRange));
          AddElement(DataNode, 'moveCount', IntToStr(entities.entityList[i].moveCount));
          AddElement(DataNode, 'targetX', IntToStr(entities.entityList[i].targetX));
          AddElement(DataNode, 'targetY', IntToStr(entities.entityList[i].targetY));
          AddElement(DataNode, 'inView', BoolToStr(entities.entityList[i].inView));
          AddElement(DataNode, 'blocks', BoolToStr(entities.entityList[i].blocks));
          WriteStr(Value, entities.entityList[i].faction);
          AddElement(DataNode, 'faction', Value);
          WriteStr(Value, entities.entityList[i].state);
          AddElement(DataNode, 'state', Value);
          AddElement(DataNode, 'discovered', BoolToStr(entities.entityList[i].discovered));
          AddElement(DataNode, 'weaponEquipped', BoolToStr(entities.entityList[i].weaponEquipped));
          AddElement(DataNode, 'armourEquipped', BoolToStr(entities.entityList[i].armourEquipped));
          AddElement(DataNode, 'stsDrunk', BoolToStr(entities.entityList[i].stsDrunk));
          AddElement(DataNode, 'stsPoison', BoolToStr(entities.entityList[i].stsPoison));
          AddElement(DataNode, 'tmrDrunk', IntToStr(entities.entityList[i].tmrDrunk));
          AddElement(DataNode, 'tmrPoison', IntToStr(entities.entityList[i].tmrPoison));
          AddElement(DataNode, 'posX', IntToStr(entities.entityList[i].posX));
          AddElement(DataNode, 'posY', IntToStr(entities.entityList[i].posY));
        end;
      end;

    (* Save XML *)
    WriteXMLFile(Doc, dfileName);
  finally
    { free memory }
    Doc.Free;
  end;
end;

procedure loadDungeonLevel(lvl: byte);
var
  dfileName: shortstring;
  RootNode, Tile, ItemsNode, ParentNode, NPCnode, NextNode, Blocks,
  Visible, Occupied, Discovered, GlyphNode: TDOMNode;
  Doc: TXMLDocument;
  r, c: integer;
  levelVisited: boolean;
begin
  dfileName := globalUtils.saveDirectory + PathDelim + 'd_' +
    IntToStr(uniqueID) + '_f' + IntToStr(lvl) + '.dat';
  try
    (* Read in dat file from disk *)
    ReadXMLFile(Doc, dfileName);
    (* Retrieve the nodes *)
    RootNode := Doc.DocumentElement.FindNode('levelData');
    (* Name of dungeon *)
    title := RootNode.FindNode('title').TextContent;
    (* Has this level been explored already *)
    levelVisited := StrToBool(UTF8Encode(RootNode.FindNode('levelVisited').TextContent));
    (* Number of items on current level *)
    items.itemAmount := StrToInt(UTF8Encode(RootNode.FindNode('itemsOnThisFloor').TextContent));
    (* Number of entities on current level *)
    entities.npcAmount := StrToInt(UTF8Encode(RootNode.FindNode('entitiesOnThisFloor').TextContent));
    (* Total depth of current dungeon *)
    universe.totalDepth := StrToInt(UTF8Encode(RootNode.FindNode('totalDepth').TextContent));
    (* Number of rooms in current level *)
    universe.totalRooms := StrToInt(UTF8Encode(RootNode.FindNode('totalRooms').TextContent));
    universe.currentDepth := lvl;

    (* Map tile data *)
    Tile := RootNode.NextSibling;
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        map.maparea[r][c].id := StrToInt(UTF8Encode(Tile.Attributes.Item[0].NodeValue));
        Blocks := Tile.FirstChild;
        map.maparea[r][c].Blocks := StrToBool(UTF8Encode(Blocks.TextContent));
        Visible := Blocks.NextSibling;
        map.maparea[r][c].Visible := StrToBool(UTF8Encode(Visible.TextContent));
        Occupied := Visible.NextSibling;
        map.maparea[r][c].Occupied := StrToBool(UTF8Encode(Occupied.TextContent));
        Discovered := Occupied.NextSibling;
        map.maparea[r][c].Discovered := StrToBool(UTF8Encode(Discovered.TextContent));
        GlyphNode := Discovered.NextSibling;
        (* Convert String to Char *)
        map.maparea[r][c].Glyph := UTF8Encode(GlyphNode.TextContent[1]);
        NextNode := Tile.NextSibling;
        Tile := NextNode;
      end;
    end;

    (* Load items on this level if already visited *)
    if (levelVisited = True) then
    begin
      (* Items on the map *)
      SetLength(items.itemList, 1);
      ItemsNode := Doc.DocumentElement.FindNode('Items');
      for i := 1 to items.itemAmount do
      begin
        items.listLength := length(items.itemList);
        SetLength(items.itemList, items.listLength + 1);
        items.itemList[i].itemID := StrToInt(UTF8Encode(ItemsNode.Attributes.Item[0].NodeValue));
        items.itemList[i].itemName := UTF8Encode(ItemsNode.FindNode('Name').TextContent);
        items.itemList[i].itemDescription := UTF8Encode(ItemsNode.FindNode('description').TextContent);
        items.itemList[i].itemArticle := UTF8Encode(ItemsNode.FindNode('article').TextContent);
        items.itemList[i].itemType := tItem(GetEnumValue(Typeinfo(tItem), UTF8Encode(ItemsNode.FindNode('itemType').TextContent)));
        items.itemList[i].itemMaterial := tMaterial(GetEnumValue(Typeinfo(tMaterial), UTF8Encode(ItemsNode.FindNode('itemMaterial').TextContent)));
        items.itemList[i].useID := StrToInt(UTF8Encode(ItemsNode.FindNode('useID').TextContent));

        { Convert plain text to extended ASCII }
        if (ItemsNode.FindNode('glyph').TextContent[1] = '|') then
          items.itemList[i].glyph := chr(24)
        else if (ItemsNode.FindNode('glyph').TextContent[1] = '=') then
          items.itemList[i].glyph := chr(186)
        else
          items.itemList[i].glyph := char(widechar(ItemsNode.FindNode('glyph').TextContent[1]));

        items.itemList[i].glyphColour := UTF8Encode(ItemsNode.FindNode('glyphColour').TextContent);
        items.itemList[i].inView := StrToBool(UTF8Encode(ItemsNode.FindNode('inView').TextContent));
        items.itemList[i].posX := StrToInt(UTF8Encode(ItemsNode.FindNode('posX').TextContent));
        items.itemList[i].posY := StrToInt(UTF8Encode(ItemsNode.FindNode('posY').TextContent));
        items.itemList[i].onMap := StrToBool(UTF8Encode(ItemsNode.FindNode('onMap').TextContent));
        items.itemList[i].discovered := StrToBool(UTF8Encode(ItemsNode.FindNode('discovered').TextContent));
        ParentNode := ItemsNode.NextSibling;
        ItemsNode := ParentNode;
      end;
    end
    else
      (* Generate new items if floor not already visited *)
      universe.litterItems;

    (* Load entities on this level if already visited *)
    if (levelVisited = True) then
    begin
      SetLength(entities.entityList, 1);
      NPCnode := Doc.DocumentElement.FindNode('NPCdata');
      for i := 1 to entities.npcAmount do
      begin
        entities.listLength := length(entities.entityList);
        SetLength(entities.entityList, entities.listLength + 1);
        entities.entityList[i].npcID := StrToInt(UTF8Encode(NPCnode.FindNode('npcID').TextContent));
        entities.entityList[i].race := UTF8Encode(NPCnode.FindNode('race').TextContent);
        entities.entityList[i].intName := UTF8Encode(NPCnode.FindNode('intName').TextContent);
        entities.entityList[i].article := StrToBool(UTF8Encode(NPCnode.FindNode('article').TextContent));
        entities.entityList[i].description := UTF8Encode(NPCnode.FindNode('description').TextContent);

        { Convert plain text to extended ASCII }
        if (NPCnode.FindNode('glyph').TextContent[1] = 'h') then
          entities.entityList[i].glyph := chr(1)
        else
          entities.entityList[i].glyph := UTF8Encode(char(widechar(NPCnode.FindNode('glyph').TextContent[1])));

        entities.entityList[i].glyphColour := UTF8Encode(NPCnode.FindNode('glyphColour').TextContent);
        entities.entityList[i].maxHP := StrToInt(UTF8Encode(NPCnode.FindNode('maxHP').TextContent));
        entities.entityList[i].currentHP := StrToInt(UTF8Encode(NPCnode.FindNode('currentHP').TextContent));
        entities.entityList[i].attack := StrToInt(UTF8Encode(NPCnode.FindNode('attack').TextContent));
        entities.entityList[i].defence := StrToInt(UTF8Encode(NPCnode.FindNode('defence').TextContent));
        entities.entityList[i].weaponDice := StrToInt(UTF8Encode(NPCnode.FindNode('weaponDice').TextContent));
        entities.entityList[i].weaponAdds := StrToInt(UTF8Encode(NPCnode.FindNode('weaponAdds').TextContent));
        entities.entityList[i].xpReward := StrToInt(UTF8Encode(NPCnode.FindNode('xpReward').TextContent));
        entities.entityList[i].visionRange := StrToInt(UTF8Encode(NPCnode.FindNode('visRange').TextContent));
        entities.entityList[i].moveCount := StrToInt(UTF8Encode(NPCnode.FindNode('moveCount').TextContent));
        entities.entityList[i].targetX := StrToInt(UTF8Encode(NPCnode.FindNode('targetX').TextContent));
        entities.entityList[i].targetY := StrToInt(UTF8Encode(NPCnode.FindNode('targetY').TextContent));
        entities.entityList[i].inView := StrToBool(UTF8Encode(NPCnode.FindNode('inView').TextContent));
        entities.entityList[i].blocks := StrToBool(UTF8Encode(NPCnode.FindNode('blocks').TextContent));
        entities.entityList[i].faction := Tfactions(GetEnumValue(Typeinfo(Tfactions), UTF8Encode(NPCnode.FindNode('faction').TextContent)));
        entities.entityList[i].state := Tattitudes(GetEnumValue(Typeinfo(Tattitudes), UTF8Encode(NPCnode.FindNode('state').TextContent)));
        entities.entityList[i].discovered := StrToBool(UTF8Encode(NPCnode.FindNode('discovered').TextContent));
        entities.entityList[i].weaponEquipped := StrToBool(UTF8Encode(NPCnode.FindNode('weaponEquipped').TextContent));
        entities.entityList[i].armourEquipped := StrToBool(UTF8Encode(NPCnode.FindNode('armourEquipped').TextContent));
        entities.entityList[i].isDead := False;
        entities.entityList[i].stsDrunk := StrToBool(UTF8Encode(NPCnode.FindNode('stsDrunk').TextContent));
        entities.entityList[i].stsPoison := StrToBool(UTF8Encode(NPCnode.FindNode('stsPoison').TextContent));
        entities.entityList[i].tmrDrunk := StrToInt(UTF8Encode(NPCnode.FindNode('tmrDrunk').TextContent));
        entities.entityList[i].tmrPoison := StrToInt(UTF8Encode(NPCnode.FindNode('tmrPoison').TextContent));
        entities.entityList[i].posX := StrToInt(UTF8Encode(NPCnode.FindNode('posX').TextContent));
        entities.entityList[i].posY := StrToInt(UTF8Encode(NPCnode.FindNode('posY').TextContent));
        ParentNode := NPCnode.NextSibling;
        NPCnode := ParentNode;
      end;
    end
    else
      (* Generate new entities if floor not already visited *)
      universe.spawnDenizens;

  finally
    (* free memory *)
    Doc.Free;
  end;
end;

procedure deleteGameData;
var
  dfileName: shortstring;
begin
  (* Set the save game file name *)
  dfileName := (globalUtils.saveDirectory + PathDelim + globalutils.saveFile);
  if (FileExists(dfileName)) then
  begin
    DeleteFile(dfileName);
    main.saveExists := False;
  end;
end;

procedure loadGame;
var
  RootNode, ParentNode, InventoryNode, PlayerDataNode: TDOMNode;
  Doc: TXMLDocument;
  i: integer;
  dfileName: shortstring;

begin
  try
    (* Set the save game file name *)
    dfileName := (globalUtils.saveDirectory + PathDelim + globalutils.saveFile);
    (* Read xml file from disk *)
    ReadXMLFile(Doc, dfileName);
    (* Retrieve the nodes *)
    RootNode := Doc.DocumentElement.FindNode('GameData');
    ParentNode := RootNode.FirstChild.NextSibling;
    (* Random seed *)
    RandSeed := StrToDWord(UTF8Encode(RootNode.FindNode('RandSeed').TextContent));
    (* Current dungeon ID *)
    universe.uniqueID := StrToInt(UTF8Encode(RootNode.FindNode('dungeonID').TextContent));
    (* Current depth *)
    universe.currentDepth := StrToInt(UTF8Encode(RootNode.FindNode('currentDepth').TextContent));
    (* Can the player exit the dungeon *)
    player_stats.canExitDungeon := StrToBool(UTF8Encode(RootNode.FindNode('canExitDungeon').TextContent));

    (* Player data *)
    SetLength(entities.entityList, 0);
    PlayerDataNode := Doc.DocumentElement.FindNode('PlayerData');
    entities.listLength := length(entities.entityList);
    SetLength(entities.entityList, entities.listLength + 1);
    entities.entityList[0].npcID := 0;
    entities.entityList[0].race := UTF8Encode(PlayerDataNode.FindNode('race').TextContent);
    entities.entityList[0].description := UTF8Encode(PlayerDataNode.FindNode('description').TextContent);
    entities.entityList[0].glyph := UTF8Encode(char(widechar(PlayerDataNode.FindNode('glyph').TextContent[1])));
    entities.entityList[0].glyphColour := UTF8Encode(PlayerDataNode.FindNode('glyphColour').TextContent);
    entities.entityList[0].maxHP := StrToInt(UTF8Encode(PlayerDataNode.FindNode('maxHP').TextContent));
    entities.entityList[0].currentHP := StrToInt(UTF8Encode(PlayerDataNode.FindNode('currentHP').TextContent));
    entities.entityList[0].attack := StrToInt(UTF8Encode(PlayerDataNode.FindNode('attack').TextContent));
    entities.entityList[0].defence := StrToInt(UTF8Encode(PlayerDataNode.FindNode('defence').TextContent));
    entities.entityList[0].weaponDice := StrToInt(UTF8Encode(PlayerDataNode.FindNode('weaponDice').TextContent));
    entities.entityList[0].weaponAdds := StrToInt(UTF8Encode(PlayerDataNode.FindNode('weaponAdds').TextContent));
    entities.entityList[0].xpReward := StrToInt(UTF8Encode(PlayerDataNode.FindNode('xpReward').TextContent));
    entities.entityList[0].visionRange := StrToInt(UTF8Encode(PlayerDataNode.FindNode('visRange').TextContent));
    entities.entityList[0].moveCount := StrToInt(UTF8Encode(PlayerDataNode.FindNode('moveCount').TextContent));
    entities.entityList[0].targetX := StrToInt(UTF8Encode(PlayerDataNode.FindNode('targetX').TextContent));
    entities.entityList[0].targetY := StrToInt(UTF8Encode(PlayerDataNode.FindNode('targetY').TextContent));
    entities.entityList[0].inView := True;
    entities.entityList[0].blocks := False;
    entities.entityList[0].discovered := True;
    entities.entityList[0].weaponEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('weaponEquipped').TextContent));
    entities.entityList[0].armourEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('armourEquipped').TextContent));
    entities.entityList[0].isDead := False;
    entities.entityList[0].stsDrunk := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsDrunk').TextContent));
    entities.entityList[0].stsPoison := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsPoison').TextContent));
    entities.entityList[0].tmrDrunk := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrDrunk').TextContent));
    entities.entityList[0].tmrPoison := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrPoison').TextContent));
    entities.entityList[0].posX := StrToInt(UTF8Encode(PlayerDataNode.FindNode('posX').TextContent));
    entities.entityList[0].posY := StrToInt(UTF8Encode(PlayerDataNode.FindNode('posY').TextContent));

    (* Player stats *)
    player_stats.playerLevel := StrToInt(UTF8Encode(PlayerDataNode.FindNode('playerLevel').TextContent));
    player_stats.currentMagick := StrToInt(UTF8Encode(PlayerDataNode.FindNode('currentMagick').TextContent));
    player_stats.maxMagick := StrToInt(UTF8Encode(PlayerDataNode.FindNode('maxMagick').TextContent));
    player_stats.maxVisionRange := StrToInt(UTF8Encode(PlayerDataNode.FindNode('maxVisionRange').TextContent));
    player_stats.playerRace:=UTF8Encode(PlayerDataNode.FindNode('playerRace').TextContent);
    player_stats.clanName:=UTF8Encode(PlayerDataNode.FindNode('clanName').TextContent);
    player_stats.enchantedWeaponEquipped:=StrToBool(UTF8Encode(PlayerDataNode.FindNode('enchantedWeapon').TextContent));
    player_stats.enchWeapType := StrToInt(UTF8Encode(PlayerDataNode.FindNode('enchWeapType').TextContent));

    (* Player Inventory *)
    player_inventory.initialiseInventory;

    InventoryNode := Doc.DocumentElement.FindNode('playerInventory');
    for i := 0 to 9 do
    begin
      player_inventory.inventory[i].id := i;
      player_inventory.inventory[i].sortIndex := StrToInt(UTF8Encode(InventoryNode.FindNode('sortIndex').TextContent));
      player_inventory.inventory[i].Name := UTF8Encode(InventoryNode.FindNode('Name').TextContent);
      player_inventory.inventory[i].equipped := StrToBool(UTF8Encode(InventoryNode.FindNode('equipped').TextContent));
      player_inventory.inventory[i].description := UTF8Encode(InventoryNode.FindNode('description').TextContent);
      player_inventory.inventory[i].article := UTF8Encode(InventoryNode.FindNode('article').TextContent);
      player_inventory.inventory[i].itemType := tItem(GetEnumValue(Typeinfo(tItem), UTF8Encode(InventoryNode.FindNode('itemType').TextContent)));
      player_inventory.inventory[i].itemMaterial := tMaterial(GetEnumValue(Typeinfo(tMaterial), UTF8Encode(InventoryNode.FindNode('itemMaterial').TextContent)));
      player_inventory.inventory[i].useID := StrToInt(UTF8Encode(InventoryNode.FindNode('useID').TextContent));

      { Convert plain text to extended ASCII }
      if (InventoryNode.FindNode('glyph').TextContent[1] = '|') then
        player_inventory.inventory[i].glyph := chr(24)
      else if (InventoryNode.FindNode('glyph').TextContent[1] = '=') then
        player_inventory.inventory[i].glyph := chr(186)
      else
        player_inventory.inventory[i].glyph := char(widechar(InventoryNode.FindNode('glyph').TextContent[1]));

      player_inventory.inventory[i].glyphColour := UTF8Encode(InventoryNode.FindNode('glyphColour').TextContent);
      player_inventory.inventory[i].inInventory := StrToBool(UTF8Encode(InventoryNode.FindNode('inInventory').TextContent));
      ParentNode := InventoryNode.NextSibling;
      InventoryNode := ParentNode;
    end;
  finally
    (* free memory *)
    Doc.Free;
  end;
end;

procedure saveGame;
var
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName, Value: shortstring;

  procedure AddElement(Node: TDOMNode; Name, Value: shortstring);
  var
    NameNode, ValueNode: TDomNode;
  begin
    { creates future Node/Name }
    NameNode := Doc.CreateElement(UTF8Decode(Name));
    { creates future Node/Name/Value }
    ValueNode := Doc.CreateTextNode(UTF8Decode(Value));
    { place value in place }
    NameNode.Appendchild(ValueNode);
    { place Name in place }
    Node.Appendchild(NameNode);
  end;

  function AddChild(Node: TDOMNode; ChildName: shortstring): TDomNode;
  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(UTF8Decode(ChildName));
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
  (* Set this floor to Visited *)
  levelVisited := True;
  (* First save the current level data *)
  saveDungeonLevel;
  (* Save game stats *)
  dfileName := (globalUtils.saveDirectory + PathDelim + globalutils.saveFile);
  try
    (* Create a document *)
    Doc := TXMLDocument.Create;
    (* Create a root node *)
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    (* Game data *)
    DataNode := AddChild(RootNode, 'GameData');
    AddElement(datanode, 'RandSeed', IntToStr(RandSeed));
    AddElement(datanode, 'dungeonID', IntToStr(uniqueID));
    AddElement(datanode, 'currentDepth', IntToStr(currentDepth));
    AddElement(datanode, 'levelVisited', BoolToStr(True));
    AddElement(datanode, 'itemsOnThisFloor', IntToStr(items.itemAmount));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
    AddElement(datanode, 'canExitDungeon', UTF8Encode(BoolToStr(player_stats.canExitDungeon)));
    WriteStr(Value, dungeonType);
    AddElement(datanode, 'mapType', Value);
    AddElement(datanode, 'npcAmount', IntToStr(entities.npcAmount));
    AddElement(datanode, 'itemAmount', IntToStr(items.itemAmount));

    (* Player data *)
    DataNode := AddChild(RootNode, 'PlayerData');
    AddElement(DataNode, 'race', entities.entityList[0].race);
    AddElement(DataNode, 'description', entities.entityList[0].description);
    AddElement(DataNode, 'glyph', entities.entityList[0].glyph);
    AddElement(DataNode, 'glyphColour', entities.entityList[0].glyphColour);
    AddElement(DataNode, 'maxHP', IntToStr(entities.entityList[0].maxHP));
    AddElement(DataNode, 'currentHP', IntToStr(entities.entityList[0].currentHP));
    AddElement(DataNode, 'attack', IntToStr(entities.entityList[0].attack));
    AddElement(DataNode, 'defence', IntToStr(entities.entityList[0].defence));
    AddElement(DataNode, 'weaponDice', IntToStr(entities.entityList[0].weaponDice));
    AddElement(DataNode, 'weaponAdds', IntToStr(entities.entityList[0].weaponAdds));
    AddElement(DataNode, 'xpReward', IntToStr(entities.entityList[0].xpReward));
    AddElement(DataNode, 'visRange', IntToStr(entities.entityList[0].visionRange));
    AddElement(DataNode, 'moveCount', IntToStr(entities.entityList[0].moveCount));
    AddElement(DataNode, 'targetX', IntToStr(entities.entityList[0].targetX));
    AddElement(DataNode, 'targetY', IntToStr(entities.entityList[0].targetY));
    AddElement(DataNode, 'weaponEquipped', BoolToStr(entities.entityList[0].weaponEquipped));
    AddElement(DataNode, 'armourEquipped', BoolToStr(entities.entityList[0].armourEquipped));
    AddElement(DataNode, 'stsDrunk', BoolToStr(entities.entityList[0].stsDrunk));
    AddElement(DataNode, 'stsPoison', BoolToStr(entities.entityList[0].stsPoison));
    AddElement(DataNode, 'tmrDrunk', IntToStr(entities.entityList[0].tmrDrunk));
    AddElement(DataNode, 'tmrPoison', IntToStr(entities.entityList[0].tmrPoison));
    AddElement(DataNode, 'posX', IntToStr(entities.entityList[0].posX));
    AddElement(DataNode, 'posY', IntToStr(entities.entityList[0].posY));

    (* Player stats *)
    AddElement(DataNode, 'playerLevel', IntToStr(player_stats.playerLevel));
    AddElement(DataNode, 'currentMagick', IntToStr(player_stats.currentMagick));
    AddElement(DataNode, 'maxMagick', IntToStr(player_stats.maxMagick));
    AddElement(DataNode, 'maxVisionRange', IntToStr(player_stats.maxVisionRange));
    AddElement(DataNode, 'playerRace', player_stats.playerRace);
    AddElement(DataNode, 'clanName', player_stats.clanName);
    AddElement(DataNode, 'enchantedWeapon', BoolToStr(player_stats.enchantedWeaponEquipped));
    AddElement(DataNode, 'enchWeapType', IntToStr(player_stats.enchWeapType));

    (* Player inventory *)
    for i := 0 to 9 do
    begin
      DataNode := AddChild(RootNode, 'playerInventory');
      TDOMElement(dataNode).SetAttribute('id', UTF8Decode(IntToStr(i)));
      AddElement(DataNode, 'sortIndex', IntToStr(inventory[i].sortIndex));
      AddElement(DataNode, 'Name', inventory[i].Name);
      AddElement(DataNode, 'equipped', BoolToStr(inventory[i].equipped));
      AddElement(DataNode, 'description', inventory[i].description);
      AddElement(DataNode, 'article', inventory[i].article);
      WriteStr(Value, inventory[i].itemType);
      AddElement(DataNode, 'itemType', Value);
      WriteStr(Value, inventory[i].itemMaterial);
      AddElement(DataNode, 'itemMaterial', Value);
      AddElement(DataNode, 'useID', IntToStr(inventory[i].useID));

      { Convert extended ASCII to plain text }
      if (inventory[i].glyph = chr(24)) then
        AddElement(DataNode, 'glyph', '|')
      else if (inventory[i].glyph = chr(186)) then
        AddElement(DataNode, 'glyph', '=')
      else
        AddElement(DataNode, 'glyph', inventory[i].glyph);

      AddElement(DataNode, 'glyphColour', inventory[i].glyphColour);
      AddElement(DataNode, 'inInventory', BoolToStr(inventory[i].inInventory));
    end;

    { Plot elements }

    (* Save XML *)
    WriteXMLFile(Doc, dfileName);
  finally
    { Free memory }
    Doc.Free;
  end;
end;

end.
