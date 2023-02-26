(* Unit responsible for saving and loading data *)

unit file_handling;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, DOM, XMLWrite, XMLRead, TypInfo, globalutils, universe, island,cave, smallGrid, crypt, stone_cavern, village, combat_resolver, ui;

(* Save the overworld map to disk *)
procedure saveOverworldMap;
(* Read overworld map from disk *)
procedure loadOverworldMap;
(* Write a newly generate level of a dungeon to disk *)
procedure writeNewDungeonLevel(title: string; idNumber, lvlNum, totalDepth, totalRooms: byte; dtype: dungeonTerrain);
(* Write explored dungeon level to disk *)
procedure saveDungeonLevel;
(* Read dungeon level from disk *)
procedure loadDungeonLevel(dungeonID: smallint; lvl: byte);
(* Delete saved game files *)
procedure deleteGameData;
(* Load a saved game *)
procedure loadGame;
(* Save game state to file *)
procedure saveGame;
(* Convert enums to values for save files *)
function terrainLookup(inputTerrain: overworldTerrain):char;
function terrainReverseLookup(inputTerrain: char):overworldTerrain;
function colourLookup(inputColour: shortstring):shortstring;
function colourReverseLookup(inputColour: shortstring):shortstring;
function materialLookup(inputMaterial: tMaterial):shortstring;
function materialReverseLookup(inputMaterial: shortstring):tMaterial;

implementation

uses
  map, main, entities, player_stats, player_inventory, overworld, items, merchant_inventory;

procedure saveOverworldMap;
var
  r, c, id_int: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName: shortstring;
  Gplaceholder: char;

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
  dfileName := (globalUtils.saveDirectory + PathDelim + 'ellanToll.dat');
  try
    { Create a document }
    Doc := TXMLDocument.Create;
    { Create a root node }
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;


    (* map tiles *)
    for r := 1 to overworld.MAXR do
    begin
      for c := 1 to overworld.MAXC do
      begin
        Inc(id_int);
        DataNode := AddChild(RootNode, 'et');
        TDOMElement(dataNode).SetAttribute('id', UTF8Decode(IntToStr(id_int)));

        AddElement(datanode, 'B', BoolToStr(island.overworldMap[r][c].Blocks));
        AddElement(datanode, 'O', BoolToStr(island.overworldMap[r][c].Occupied));
        AddElement(datanode, 'D', BoolToStr(island.overworldMap[r][c].Discovered));
        AddElement(datanode, 'T', terrainLookup(island.overworldMap[r][c].TerrainType));
        { Translate the Glyph to ASCII }
        if (island.overworldMap[r][c].Glyph = chr(6)) and
          (island.overworldMap[r][c].GlyphColour = 'green') then
          Gplaceholder := 'A'
        else if (island.overworldMap[r][c].Glyph = chr(6)) and
          (island.overworldMap[r][c].GlyphColour = 'lightGreen') then
          Gplaceholder := 'B'
        else if (island.overworldMap[r][c].Glyph = chr(5)) then
          Gplaceholder := 'C'
        else if (island.overworldMap[r][c].Glyph = '"') and
          (island.overworldMap[r][c].GlyphColour = 'green') then
          Gplaceholder := 'D'
        else if (island.overworldMap[r][c].Glyph = '''') and
          (island.overworldMap[r][c].GlyphColour = 'green') then
          Gplaceholder := 'E'
        else if (island.overworldMap[r][c].Glyph = '"') and
          (island.overworldMap[r][c].GlyphColour = 'lightGreen') then
          Gplaceholder := 'F'
        else if (island.overworldMap[r][c].Glyph = '''') and
          (island.overworldMap[r][c].GlyphColour = 'lightGreen') then
          Gplaceholder := 'G'
        else if (island.overworldMap[r][c].Glyph = '.') and
          (island.overworldMap[r][c].GlyphColour = 'brown') then
          Gplaceholder := 'H'
        else if (island.overworldMap[r][c].Glyph = ',') and
          (island.overworldMap[r][c].GlyphColour = 'brown') then
          Gplaceholder := 'I'
        else if (island.overworldMap[r][c].Glyph = '.') and
          (island.overworldMap[r][c].GlyphColour = 'yellow') then
          Gplaceholder := 'J'
        else if (island.overworldMap[r][c].Glyph = chr(94)) then
          Gplaceholder := 'K'
        else if (island.overworldMap[r][c].Glyph = ':') and
          (island.overworldMap[r][c].GlyphColour = 'brown') then
          Gplaceholder := 'L'
        else if (island.overworldMap[r][c].Glyph = ';') and
          (island.overworldMap[r][c].GlyphColour = 'brown') then
          Gplaceholder := 'M'
        else if (island.overworldMap[r][c].Glyph = ':') and
          (island.overworldMap[r][c].GlyphColour = 'yellow') then
          Gplaceholder := 'N'
        else if (island.overworldMap[r][c].Glyph = '~') and
          (island.overworldMap[r][c].GlyphColour = 'lightBlue') then
          Gplaceholder := '-'
        else if (island.overworldMap[r][c].Glyph = chr(247)) and
          (island.overworldMap[r][c].GlyphColour = 'blue') then
          Gplaceholder := '~'
        else if (island.overworldMap[r][c].Glyph = '>') then
          Gplaceholder := '>'
        else
          Gplaceholder := 'X';
        AddElement(datanode, 'G', Gplaceholder);
      end;
    end;
    (* Save XML *)
    WriteXMLFile(Doc, dfileName);
  finally
    { free memory }
    Doc.Free;
  end;  
end;

procedure loadOverworldMap;
var
  RootNode, NextNode, Blocks, Occupied, Discovered, TerrainType, Glyph: TDOMNode;
  Doc: TXMLDocument;
  dfileName: shortstring;
  r, c: smallint;
begin
  dfileName := (globalUtils.saveDirectory + PathDelim + 'ellanToll.dat');
  try
    (* Read in dat file from disk *)
    ReadXMLFile(Doc, dfileName);
    (* Retrieve the nodes *)
    RootNode := Doc.DocumentElement.FindNode('et');

    for r := 1 to overworld.MAXR do
    begin
      for c := 1 to overworld.MAXC do
      begin
        island.overworldMap[r][c].id := StrToInt(UTF8Encode(RootNode.Attributes.Item[0].NodeValue));
        Blocks := RootNode.FirstChild;
        island.overworldMap[r][c].Blocks := StrToBool(UTF8Encode(Blocks.TextContent));
        Occupied := Blocks.NextSibling;
        island.overworldMap[r][c].Occupied := StrToBool(UTF8Encode(Occupied.TextContent));
        Discovered := Occupied.NextSibling;
        island.overworldMap[r][c].Discovered := StrToBool(UTF8Encode(Discovered.TextContent));
        TerrainType := Discovered.NextSibling;
        island.overworldMap[r][c].TerrainType := terrainReverseLookup(TerrainType.TextContent[1]);
        Glyph := TerrainType.NextSibling;
        if (UTF8Encode(Glyph.TextContent[1]) = 'A') then
        begin
          island.overworldMap[r][c].Glyph := chr(6);
          island.overworldMap[r][c].GlyphColour := 'green';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'B') then
        begin
          island.overworldMap[r][c].Glyph := chr(6);
          island.overworldMap[r][c].GlyphColour := 'lightGreen';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'C') then
        begin
          island.overworldMap[r][c].Glyph := chr(5);
          island.overworldMap[r][c].GlyphColour := 'green';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'D') then
        begin
          island.overworldMap[r][c].Glyph := '"';
          island.overworldMap[r][c].GlyphColour := 'green';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'E') then
        begin
          island.overworldMap[r][c].Glyph := '''';
          island.overworldMap[r][c].GlyphColour := 'green';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'F') then
        begin
          island.overworldMap[r][c].Glyph := '"';
          island.overworldMap[r][c].GlyphColour := 'lightGreen';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'G') then
        begin
          island.overworldMap[r][c].Glyph := '''';
          island.overworldMap[r][c].GlyphColour := 'lightGreen';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'H') then
        begin
          island.overworldMap[r][c].Glyph := '.';
          island.overworldMap[r][c].GlyphColour := 'brown';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'I') then
        begin
          island.overworldMap[r][c].Glyph := ',';
          island.overworldMap[r][c].GlyphColour := 'brown';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'J') then
        begin
          island.overworldMap[r][c].Glyph := '.';
          island.overworldMap[r][c].GlyphColour := 'yellow';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'K') then
        begin
          island.overworldMap[r][c].Glyph := chr(94);
          island.overworldMap[r][c].GlyphColour := 'brown';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'L') then
        begin
          island.overworldMap[r][c].Glyph := ':';
          island.overworldMap[r][c].GlyphColour := 'brown';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'M') then
        begin
          island.overworldMap[r][c].Glyph := ';';
          island.overworldMap[r][c].GlyphColour := 'brown';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'N') then
        begin
          island.overworldMap[r][c].Glyph := ':';
          island.overworldMap[r][c].GlyphColour := 'yellow';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = '>') then
        begin
          island.overworldMap[r][c].Glyph := '>';
          island.overworldMap[r][c].GlyphColour := 'white';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = '~') then
        begin
          island.overworldMap[r][c].Glyph := chr(247);
          island.overworldMap[r][c].GlyphColour := 'blue';
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = '-') then
        begin
          island.overworldMap[r][c].Glyph := '~';
          island.overworldMap[r][c].GlyphColour := 'lightBlue';
        end;
        NextNode := RootNode.NextSibling;
        RootNode := NextNode;
      end;
    end;
  finally
    (* free memory *)
    Doc.Free;
  end;
end;

procedure writeNewDungeonLevel(title: string; idNumber, lvlNum, totalDepth, totalRooms: byte; dtype: dungeonTerrain);
var
  r, c, id_int: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName: shortstring;

  procedure AddElement(Node: TDOMNode; Name, Value: unicodestring);
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
  dfileName := globalUtils.saveDirectory + PathDelim + 'd_' + IntToStr(idNumber) + '_f' + IntToStr(lvlNum) + '.dat';
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
    AddElement(datanode, 'title', UTF8Decode(title));
    AddElement(datanode, 'floor', UTF8Decode(IntToStr(lvlNum)));
    AddElement(datanode, 'levelVisited', UTF8Decode(BoolToStr(False)));
    AddElement(datanode, 'itemsOnThisFloor', UTF8Decode(IntToStr(0)));
    AddElement(datanode, 'entitiesOnThisFloor', UTF8Decode(IntToStr(0)));
    AddElement(datanode, 'totalDepth', UTF8Decode(IntToStr(totalDepth)));
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
        end
        { if dungeon type is a dungeon }
        else if (dType = tDungeon) then
        begin
          if (smallGrid.processed_dungeon[r][c] = '.') or (smallGrid.processed_dungeon[r][c] = 'X') or
            (smallGrid.processed_dungeon[r][c] = '>') or (smallGrid.processed_dungeon[r][c] = '<') then
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(True)));
        end
        { if location is a village }
        else if (dType = tVillage) then
        begin
          if (village.dungeonArray[r][c] = '.') or (village.dungeonArray[r][c] = '<') or
            (village.dungeonArray[r][c] = '"') then
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(True)));
        end
        { if dungeon type is a crypt }
        else if (dType = tCrypt) then
        begin
          if (crypt.dungeonArray[r][c] = '.') or (crypt.dungeonArray[r][c] = 'X') or
            (crypt.dungeonArray[r][c] = '>') or (crypt.dungeonArray[r][c] = '<') then
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(True)));
        end
        { if dungeon type is a stone cavern }
        else if (dType = tStoneCavern) then
        begin
          if (stone_cavern.terrainArray[r][c] = '.') or (stone_cavern.terrainArray[r][c] = 'X') or
            (stone_cavern.terrainArray[r][c] = '>') or (stone_cavern.terrainArray[r][c] = '<') then
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'Blocks', UTF8Decode(BoolToStr(True)));
        end;
        AddElement(datanode, 'Visible', UTF8Decode(BoolToStr(False)));
        AddElement(datanode, 'Occupied', UTF8Decode(BoolToStr(False)));
        AddElement(datanode, 'Discovered', UTF8Decode(BoolToStr(False)));
        { if dungeon type is a cave }
        if (dType = tCave) then
        begin
          AddElement(datanode, 'Glyph', UTF8Decode(cave.terrainArray[r][c]));
        end
        { if dungeon type is a dungeon }
        else if (dType = tDungeon) then
        begin
          AddElement(datanode, 'Glyph', UTF8Decode(smallGrid.processed_dungeon[r][c]));
        end
        { if location is a village }
        else if (dType = tVillage) then
        begin
          AddElement(datanode, 'Glyph', UTF8Decode(village.dungeonArray[r][c]));
        end
        { if dungeon type is a crypt }
        else if (dType = tCrypt) then
        begin
          AddElement(datanode, 'Glyph', UTF8Decode(crypt.dungeonArray[r][c]));
        end
        { if dungeon type is a stone crypt }
        else if (dType = tStoneCavern) then
        begin
          AddElement(datanode, 'Glyph', UTF8Decode(stone_cavern.terrainArray[r][c]));
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
  r, c, id_int, i, coords: smallint;
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
  dfileName := (globalUtils.saveDirectory + PathDelim + 'd_' + IntToStr(uniqueID) + '_f' + IntToStr(currentDepth) + '.dat');
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
    if (womblingFree = 'underground') then
      AddElement(datanode, 'itemsOnThisFloor', IntToStr(items.countNonEmptyItems))
    else
      AddElement(datanode, 'itemsOnThisFloor', '0');
    AddElement(datanode, 'entitiesOnThisFloor', IntToStr(entities.countLivingEntities));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
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
    for i := Low(itemList) to High(itemList) do
      (* Don't save empty items *)
      if (items.itemList[i].itemType <> itmEmptySlot) and
        ((items.itemList[i].itemName <> '')) then
      begin
        begin
          DataNode := AddChild(RootNode, 'Items');
          TDOMElement(dataNode).SetAttribute('itemID',
            UTF8Decode(IntToStr(itemList[i].itemID)));
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
            AddElement(DataNode, 'glyph', 'T')
          else if (itemList[i].glyph = chr(186)) then
            AddElement(DataNode, 'glyph', '=')
          else if (itemList[i].glyph = chr(7)) then
            AddElement(DataNode, 'glyph', '*')
          else if (itemList[i].glyph = chr(173)) then
            AddElement(DataNode, 'glyph', 'i')
          else if (itemList[i].glyph = chr(232)) then
            AddElement(DataNode, 'glyph', '0')
          else if (itemList[i].glyph = chr(194)) then
            AddElement(DataNode, 'glyph', 'A')
          else
            AddElement(DataNode, 'glyph', itemList[i].glyph);

          AddElement(DataNode, 'glyphColour', itemList[i].glyphColour);
          AddElement(DataNode, 'inView', BoolToStr(itemList[i].inView));
          AddElement(DataNode, 'posX', IntToStr(itemList[i].posX));
          AddElement(DataNode, 'posY', IntToStr(itemList[i].posY));
          AddElement(DataNode, 'numUses', IntToStr(itemList[i].NumberOfUses));
          AddElement(DataNode, 'val', IntToStr(itemList[i].value));
          AddElement(DataNode, 'onMap', BoolToStr(itemList[i].onMap));
          AddElement(DataNode, 'throwable', BoolToStr(itemList[i].throwable));
          AddElement(DataNode, 'throwDamage', IntToStr(itemList[i].throwDamage));
          AddElement(DataNode, 'dice', IntToStr(itemList[i].dice));
          AddElement(DataNode, 'adds', IntToStr(itemList[i].adds));
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
            AddElement(DataNode, 'glyph', '=') { Hob }
          else if (entities.entityList[i].glyph = chr(2)) then
            AddElement(DataNode, 'glyph', '#') { Trog }
          else if (entities.entityList[i].glyph = chr(157)) then
            AddElement(DataNode, 'glyph', '!') { Hornet }
          else
            AddElement(DataNode, 'glyph', entities.entityList[i].glyph);

          AddElement(DataNode, 'glyphColour', entities.entityList[i].glyphColour);
          AddElement(DataNode, 'maxHP', IntToStr(entities.entityList[i].maxHP));
          AddElement(DataNode, 'currentHP', IntToStr(entities.entityList[i].currentHP));
          AddElement(DataNode, 'attack', IntToStr(entities.entityList[i].attack));
          AddElement(DataNode, 'defence', IntToStr(entities.entityList[i].defence));
          AddElement(DataNode, 'weaponDice',
            IntToStr(entities.entityList[i].weaponDice));
          AddElement(DataNode, 'weaponAdds',
            IntToStr(entities.entityList[i].weaponAdds));
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
          AddElement(DataNode, 'stsBewild', BoolToStr(entities.entityList[i].stsBewild));
          AddElement(DataNode, 'stsFrozen', BoolToStr(entities.entityList[i].stsFrozen));
          AddElement(DataNode, 'tmrDrunk', IntToStr(entities.entityList[i].tmrDrunk));
          AddElement(DataNode, 'tmrPoison', IntToStr(entities.entityList[i].tmrPoison));
          AddElement(DataNode, 'tmrBewild', IntToStr(entities.entityList[i].tmrBewild));
          AddElement(DataNode, 'tmrFrozen', IntToStr(entities.entityList[i].tmrFrozen));
          AddElement(DataNode, 'hasPath', BoolToStr(entities.entityList[i].hasPath));
          AddElement(DataNode, 'destReach', BoolToStr(entities.entityList[i].destinationReached));
          (* Save path coordinates *)
          for coords := 1 to 30 do
          begin
            AddElement(DataNode, 'coordX' + IntToStr(coords), IntToStr(entities.entityList[i].smellPath[coords].X));
            AddElement(DataNode, 'coordY' + IntToStr(coords), IntToStr(entities.entityList[i].smellPath[coords].Y));
          end;
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

procedure loadDungeonLevel(dungeonID: smallint; lvl: byte);
var
  dfileName: shortstring;
  RootNode, Tile, ItemsNode, ParentNode, NPCnode, NextNode, Blocks, Visible, Occupied, Discovered, GlyphNode: TDOMNode;
  Doc: TXMLDocument;
  r, c, itemAmount, i, coords: integer;
  levelVisited: boolean;
begin
  dfileName := globalUtils.saveDirectory + PathDelim + 'd_' + IntToStr(dungeonID) + '_f' + IntToStr(lvl) + '.dat';
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
    itemAmount := StrToInt(UTF8Encode(RootNode.FindNode( 'itemsOnThisFloor').TextContent));
    (* Number of entities on current level *)
    entities.npcAmount := StrToInt( UTF8Encode(RootNode.FindNode('entitiesOnThisFloor').TextContent));
    (* Total depth of current dungeon *)
    universe.totalDepth := StrToInt( UTF8Encode(RootNode.FindNode('totalDepth').TextContent));
    (* Number of rooms in current level *)
    universe.totalRooms := StrToInt( UTF8Encode(RootNode.FindNode('totalRooms').TextContent));
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
      ItemsNode := Doc.DocumentElement.FindNode('Items');
      SetLength(itemList, itemAmount);
      for i := Low(itemList) to High(itemList) do
      begin
        items.itemList[i].itemID := StrToInt(UTF8Encode(ItemsNode.Attributes.Item[0].NodeValue));
        items.itemList[i].itemName := UTF8Encode(ItemsNode.FindNode('Name').TextContent);
        items.itemList[i].itemDescription := UTF8Encode(ItemsNode.FindNode('description').TextContent);
        items.itemList[i].itemArticle := UTF8Encode(ItemsNode.FindNode('article').TextContent);
        items.itemList[i].itemType := tItem(GetEnumValue(Typeinfo(tItem), UTF8Encode(ItemsNode.FindNode('itemType').TextContent)));
        items.itemList[i].itemMaterial := tMaterial(GetEnumValue(Typeinfo(tMaterial), UTF8Encode(ItemsNode.FindNode('itemMaterial').TextContent)));
        items.itemList[i].useID := StrToInt(UTF8Encode(ItemsNode.FindNode('useID').TextContent));

        { Convert plain text to extended ASCII }
        if (ItemsNode.FindNode('glyph').TextContent[1] = 'T') then { club / dagger }
          items.itemList[i].glyph := chr(24)
        else if (ItemsNode.FindNode('glyph').TextContent[1] = '=') then
          { Magickal staff }
          items.itemList[i].glyph := chr(186)
        else if (ItemsNode.FindNode('glyph').TextContent[1] = '*') then { rock }
          items.itemList[i].glyph := chr(7)
        else if (ItemsNode.FindNode('glyph').TextContent[1] = 'i') then { pointy stick }
          items.itemList[i].glyph := chr(173)
        else if (ItemsNode.FindNode('glyph').TextContent[1] = '0') then
          { Pixie in a jar }
          items.itemList[i].glyph := chr(232)
        else if (ItemsNode.FindNode('glyph').TextContent[1] = 'A') then { axe }
          items.itemList[i].glyph := chr(194)
        else
          items.itemList[i].glyph := char(widechar(ItemsNode.FindNode('glyph').TextContent[1]));

        items.itemList[i].glyphColour := UTF8Encode(ItemsNode.FindNode('glyphColour').TextContent);
        items.itemList[i].inView := StrToBool(UTF8Encode(ItemsNode.FindNode('inView').TextContent));
        items.itemList[i].posX := StrToInt(UTF8Encode(ItemsNode.FindNode('posX').TextContent));
        items.itemList[i].posY := StrToInt(UTF8Encode(ItemsNode.FindNode('posY').TextContent));
        items.itemList[i].NumberOfUses := StrToInt(UTF8Encode(ItemsNode.FindNode('numUses').TextContent));
        items.itemList[i].value := StrToInt(UTF8Encode(ItemsNode.FindNode('val').TextContent));
        items.itemList[i].onMap := StrToBool(UTF8Encode(ItemsNode.FindNode('onMap').TextContent));
        items.itemList[i].throwable := StrToBool(UTF8Encode(ItemsNode.FindNode('throwable').TextContent));
        items.itemList[i].throwDamage := StrToInt(UTF8Encode(ItemsNode.FindNode('throwDamage').TextContent));
        items.itemList[i].dice := StrToInt(UTF8Encode(ItemsNode.FindNode('dice').TextContent));
        items.itemList[i].adds := StrToInt(UTF8Encode(ItemsNode.FindNode('adds').TextContent));
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
        if (NPCnode.FindNode('glyph').TextContent[1] = '=') then
          entities.entityList[i].glyph := chr(1)
        else if (NPCnode.FindNode('glyph').TextContent[1] = '#') then
          entities.entityList[i].glyph := chr(2)
        else if (NPCnode.FindNode('glyph').TextContent[1] = '!') then
          entities.entityList[i].glyph := chr(157)
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
        entities.entityList[i].stsBewild := StrToBool(UTF8Encode(NPCnode.FindNode('stsBewild').TextContent));
        entities.entityList[i].tmrDrunk := StrToInt(UTF8Encode(NPCnode.FindNode('tmrDrunk').TextContent));
        entities.entityList[i].tmrPoison := StrToInt(UTF8Encode(NPCnode.FindNode('tmrPoison').TextContent));
        entities.entityList[i].tmrBewild := StrToInt(UTF8Encode(NPCnode.FindNode('tmrBewild').TextContent));
        entities.entityList[i].hasPath := StrToBool(UTF8Encode(NPCnode.FindNode('hasPath').TextContent));
        entities.entityList[i].destinationReached := StrToBool(UTF8Encode(NPCnode.FindNode('destReach').TextContent));
        for coords := 1 to 30 do
        begin
          entities.entityList[i].smellPath[coords].X := StrToInt(UTF8Encode(NPCnode.FindNode(UTF8Decode('coordX' + IntToStr(coords))).TextContent));
          entities.entityList[i].smellPath[coords].Y := StrToInt(UTF8Encode(NPCnode.FindNode(UTF8Decode('coordY' + IntToStr(coords))).TextContent));
        end;
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
  D, currentDir: shortstring;
  Info: TSearchRec;
begin
  currentDir := GetCurrentDir;
  (* Set the save game directory *)
  D := globalUtils.saveDirectory;
  ChDir(D);
  if FindFirst('*.dat', faAnyFile, Info) = 0 then
  begin
    repeat
      with Info do
        DeleteFile(Name);
    until FindNext(info) <> 0;
    FindClose(Info);
    main.saveExists := False;
    Chdir(currentDir);
  end;
end;

procedure loadGame;
var
  RootNode, ParentNode, InventoryNode, PlayerDataNode, locationNode, deathNode: TDOMNode;
  Doc: TXMLDocument;
  i: integer;
  dfileName: shortstring;
  deathTotal: smallint;
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
    (* Above or below ground *)
    globalutils.womblingFree := (UTF8Encode(RootNode.FindNode('womble').TextContent));
    (* Total number of unique NPC's in game *)
    deathTotal := StrToInt(UTF8Encode(RootNode.FindNode('dthlst').TextContent));
    (* Last overworld coordinates *)
    globalutils.OWx := StrToInt(UTF8Encode(RootNode.FindNode('owx').TextContent));
    globalutils.OWy := StrToInt(UTF8Encode(RootNode.FindNode('owy').TextContent));
    universe.OWgen := StrToBool(UTF8Encode(RootNode.FindNode('OWgen').TextContent));
    universe.homeland := RootNode.FindNode('homeland').TextContent;
    (* Total number of unique locations *)
    SetLength(island.locationLookup, StrToInt(UTF8Encode(RootNode.FindNode('locations').TextContent)));
    (* Current dungeon ID *)
    universe.uniqueID := StrToInt( UTF8Encode(RootNode.FindNode('dungeonID').TextContent));
    (* Current depth *)
    universe.currentDepth := StrToInt(UTF8Encode(RootNode.FindNode('currentDepth').TextContent));
    (* Can the player exit the dungeon *)
    player_stats.canExitDungeon := StrToBool(UTF8Encode(RootNode.FindNode('canExitDungeon').TextContent));
    (* Type of map *)
    map.mapType := dungeonTerrain(GetEnumValue(Typeinfo(dungeonTerrain), UTF8Encode(RootNode.FindNode('mapType').TextContent)));
    universe.dungeonType := dungeonTerrain(GetEnumValue(Typeinfo(dungeonTerrain), UTF8Encode(RootNode.FindNode('mapType').TextContent)));
    (* List of enemies killed *)
    deathNode := Doc.DocumentElement.FindNode('DL');
    for i := 0 to deathTotal do
      combat_resolver.deathList[i] := StrToInt(UTF8Encode(deathNode.FindNode(UTF8Decode('kill_' + IntToStr(i))).TextContent));
    (* Amount of cash the village merchant has *)
    merchant_inventory.villagePurse := StrToDWord(UTF8Encode(RootNode.FindNode('villPurse').TextContent));

    (* Location data *)
    locationNode := Doc.DocumentElement.FindNode('locData');
    for i := 0 to High(island.locationLookup) do
    begin
      island.locationLookup[i].X := StrToInt(UTF8Encode(locationNode.FindNode('X').TextContent));
      island.locationLookup[i].Y := StrToInt(UTF8Encode(locationNode.FindNode('Y').TextContent));
      island.locationLookup[i].id := StrToInt(UTF8Encode(locationNode.FindNode('id').TextContent));
      island.locationLookup[i].Name := UTF8Encode(locationNode.FindNode('name').TextContent);
      island.locationLookup[i].generated := StrToBool(UTF8Encode(locationNode.FindNode('generated').TextContent));
      island.locationLookup[i].theme := dungeonTerrain(GetEnumValue(Typeinfo(dungeonTerrain), (UTF8Encode(locationNode.FindNode('theme').TextContent))));
      ParentNode := locationNode.NextSibling;
      locationNode := ParentNode;
    end;

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
    entities.entityList[0].stsBewild := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsBewild').TextContent));
    entities.entityList[0].stsFrozen := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsFrozen').TextContent));
    entities.entityList[0].tmrDrunk := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrDrunk').TextContent));
    entities.entityList[0].tmrPoison := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrPoison').TextContent));
    entities.entityList[0].tmrBewild := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrBewild').TextContent));
    entities.entityList[0].tmrFrozen := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrFrozen').TextContent));
    entities.entityList[0].posX := StrToInt(UTF8Encode(PlayerDataNode.FindNode('posX').TextContent));
    entities.entityList[0].posY := StrToInt(UTF8Encode(PlayerDataNode.FindNode('posY').TextContent));

    (* Set status variables *)
    if (entityList[0].stsPoison = True) then
      ui.poisonStatusSet := True;
    if (entityList[0].stsBewild = True) then
      ui.bewilderedStatusSet := True;
    if (entityList[0].stsFrozen = True) then
      ui.frozenStatusSet := True;

    (* Player stats *)
    player_stats.playerLevel := StrToInt(UTF8Encode(PlayerDataNode.FindNode('playerLevel').TextContent));
    player_stats.dexterity := StrToInt(UTF8Encode(PlayerDataNode.FindNode('dexterity').TextContent));
    player_stats.currentMagick := StrToInt(UTF8Encode(PlayerDataNode.FindNode('currentMagick').TextContent));
    player_stats.maxMagick := StrToInt(UTF8Encode(PlayerDataNode.FindNode('maxMagick').TextContent));
    player_stats.maxVisionRange := StrToInt(UTF8Encode(PlayerDataNode.FindNode('maxVisionRange').TextContent));
    player_stats.playerRace := UTF8Encode(PlayerDataNode.FindNode( 'playerRace').TextContent);
    player_stats.clanName := UTF8Encode(PlayerDataNode.FindNode('clanName').TextContent);
    player_stats.enchantedWeaponEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('enchantedWeapon').TextContent));
    player_stats.projectileWeaponEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('projectileWeapon').TextContent));
    player_stats.lightEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('lightEquipped').TextContent));
    player_stats.enchWeapType := StrToInt(UTF8Encode(PlayerDataNode.FindNode('enchWeapType').TextContent));
    player_stats.lightCounter := StrToInt(UTF8Encode(PlayerDataNode.FindNode('lightCounter').TextContent));
    player_stats.armourPoints := StrToInt(UTF8Encode(PlayerDataNode.FindNode('armourPoints').TextContent));
    player_stats.treasure := StrToInt(UTF8Encode(PlayerDataNode.FindNode('treasure').TextContent));

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
      if (InventoryNode.FindNode('glyph').TextContent[1] = 'T') then
        player_inventory.inventory[i].glyph := chr(24)
      else if (InventoryNode.FindNode('glyph').TextContent[1] = '=') then
        player_inventory.inventory[i].glyph := chr(186)
      else if (InventoryNode.FindNode('glyph').TextContent[1] = '*') then
        player_inventory.inventory[i].glyph := chr(7)
      else if (InventoryNode.FindNode('glyph').TextContent[1] = 'i') then
        player_inventory.inventory[i].glyph := chr(173)
      else if (InventoryNode.FindNode('glyph').TextContent[1] = '0') then
        player_inventory.inventory[i].glyph := chr(232)
      else if (InventoryNode.FindNode('glyph').TextContent[1] = 'A') then
        player_inventory.inventory[i].glyph := chr(194)
      else
        player_inventory.inventory[i].glyph := char(widechar(InventoryNode.FindNode('glyph').TextContent[1]));

      player_inventory.inventory[i].glyphColour := UTF8Encode(InventoryNode.FindNode('glyphColour').TextContent);
      player_inventory.inventory[i].numUses := StrToInt(UTF8Encode(InventoryNode.FindNode('numUses').TextContent));
      player_inventory.inventory[i].value := StrToInt(UTF8Encode(InventoryNode.FindNode('val').TextContent));
      player_inventory.inventory[i].throwable := StrToBool(UTF8Encode(InventoryNode.FindNode('throwable').TextContent));
      player_inventory.inventory[i].throwDamage := StrToInt(UTF8Encode(InventoryNode.FindNode('throwDamage').TextContent));
      player_inventory.inventory[i].dice := StrToInt(UTF8Encode(InventoryNode.FindNode('dice').TextContent));
      player_inventory.inventory[i].adds := StrToInt(UTF8Encode(InventoryNode.FindNode('adds').TextContent));
      player_inventory.inventory[i].inInventory := StrToBool(UTF8Encode(InventoryNode.FindNode('inInventory').TextContent));
      ParentNode := InventoryNode.NextSibling;
      InventoryNode := ParentNode;
    end;

    (* Merchant Inventory *)
    merchant_inventory.initialiseVillageInventory;

    InventoryNode := Doc.DocumentElement.FindNode('VMI');
    for i := 0 to 9 do
    begin
      merchant_inventory.villageInv[i].id := i;
      merchant_inventory.villageInv[i].Name := UTF8Encode(InventoryNode.FindNode('nm').TextContent);
      merchant_inventory.villageInv[i].description := UTF8Encode(InventoryNode.FindNode('dsc').TextContent);
      merchant_inventory.villageInv[i].article := UTF8Encode(InventoryNode.FindNode('art').TextContent);
      merchant_inventory.villageInv[i].itemType := tItem(GetEnumValue(Typeinfo(tItem), UTF8Encode(InventoryNode.FindNode('typ').TextContent)));
      merchant_inventory.villageInv[i].itemMaterial := tMaterial(GetEnumValue(Typeinfo(tMaterial), UTF8Encode(InventoryNode.FindNode('mat').TextContent)));
      merchant_inventory.villageInv[i].useID := StrToInt(UTF8Encode(InventoryNode.FindNode('uid').TextContent));

      { Convert plain text to extended ASCII }
      if (InventoryNode.FindNode('gly').TextContent[1] = 'T') then
        merchant_inventory.villageInv[i].glyph := chr(24)
      else if (InventoryNode.FindNode('gly').TextContent[1] = '=') then
        merchant_inventory.villageInv[i].glyph := chr(186)
      else if (InventoryNode.FindNode('gly').TextContent[1] = '*') then
        merchant_inventory.villageInv[i].glyph := chr(7)
      else if (InventoryNode.FindNode('gly').TextContent[1] = 'i') then
        merchant_inventory.villageInv[i].glyph := chr(173)
      else if (InventoryNode.FindNode('gly').TextContent[1] = '0') then
        merchant_inventory.villageInv[i].glyph := chr(232)
      else if (InventoryNode.FindNode('gly').TextContent[1] = 'A') then
        merchant_inventory.villageInv[i].glyph := chr(194)
      else
        merchant_inventory.villageInv[i].glyph := char(widechar(InventoryNode.FindNode('gly').TextContent[1]));

      merchant_inventory.villageInv[i].glyphColour := UTF8Encode(InventoryNode.FindNode('col').TextContent);
      merchant_inventory.villageInv[i].numUses := StrToInt(UTF8Encode(InventoryNode.FindNode('use').TextContent));
      merchant_inventory.villageInv[i].value := StrToInt(UTF8Encode(InventoryNode.FindNode('val').TextContent));
      merchant_inventory.villageInv[i].throwable := StrToBool(UTF8Encode(InventoryNode.FindNode('thr').TextContent));
      merchant_inventory.villageInv[i].throwDamage := StrToInt(UTF8Encode(InventoryNode.FindNode('dam').TextContent));
      merchant_inventory.villageInv[i].dice := StrToInt(UTF8Encode(InventoryNode.FindNode('dce').TextContent));
      merchant_inventory.villageInv[i].adds := StrToInt(UTF8Encode(InventoryNode.FindNode('add').TextContent));
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
  dfileName, Value, TypeValue: shortstring;

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
  if (womblingFree = 'underground') then
  begin
    (* Set this floor to Visited *)
    levelVisited := True;
    (* First save the current level data *)
    saveDungeonLevel;
  end
  else
  begin
    saveOverworldMap;
  end;
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
    AddElement(datanode, 'womble', globalutils.womblingFree);
    AddElement(datanode, 'dthlst', IntToStr(High(deathList)));
    AddElement(datanode, 'owx', IntToStr(globalutils.OWx));
    AddElement(datanode, 'owy', IntToStr(globalutils.OWy));
    AddElement(datanode, 'OWgen', BoolToStr(universe.OWgen));
    AddElement(datanode, 'homeland', UTF8Encode(universe.homeland));
    AddElement(datanode, 'locations', IntToStr(Length(island.locationLookup)));
    AddElement(datanode, 'dungeonID', IntToStr(uniqueID));
    AddElement(datanode, 'currentDepth', IntToStr(currentDepth));
    AddElement(datanode, 'levelVisited', BoolToStr(True));
    AddElement(datanode, 'indexID', IntToStr(items.indexID));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
    AddElement(datanode, 'canExitDungeon', UTF8Encode(BoolToStr(player_stats.canExitDungeon)));
    WriteStr(Value, map.mapType);
    AddElement(datanode, 'mapType', Value);
    AddElement(datanode, 'villPurse', IntToStr(merchant_inventory.villagePurse));

    (* List of enemies killed *)
    DataNode := AddChild(RootNode, 'DL');
    for i := Low(combat_resolver.deathList) to High(combat_resolver.deathList) do
    begin
      AddElement(DataNode, 'kill_' + IntToStr(i), IntToStr(combat_resolver.deathList[i]));
    end;

    (* Location data *)
    for i := Low(island.locationLookup) to High(island.locationLookup) do
    begin
      DataNode := AddChild(RootNode, 'locData');
      AddElement(DataNode, 'X', IntToStr(island.locationLookup[i].X));
      AddElement(DataNode, 'Y', IntToStr(island.locationLookup[i].Y));
      AddElement(DataNode, 'id', IntToStr(island.locationLookup[i].id));
      AddElement(DataNode, 'name', island.locationLookup[i].Name);
      AddElement(DataNode, 'generated', BoolToStr(island.locationLookup[i].generated));
      WriteStr(TypeValue, island.locationLookup[i].theme);
      AddElement(datanode, 'theme', TypeValue);
    end;

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
    AddElement(DataNode, 'stsBewild', BoolToStr(entities.entityList[0].stsBewild));
    AddElement(DataNode, 'stsFrozen', BoolToStr(entities.entityList[0].stsFrozen));
    AddElement(DataNode, 'tmrDrunk', IntToStr(entities.entityList[0].tmrDrunk));
    AddElement(DataNode, 'tmrPoison', IntToStr(entities.entityList[0].tmrPoison));
    AddElement(DataNode, 'tmrBewild', IntToStr(entities.entityList[0].tmrBewild));
    AddElement(DataNode, 'tmrFrozen', IntToStr(entities.entityList[0].tmrFrozen));
    AddElement(DataNode, 'posX', IntToStr(entities.entityList[0].posX));
    AddElement(DataNode, 'posY', IntToStr(entities.entityList[0].posY));

    (* Player stats *)
    AddElement(DataNode, 'playerLevel', IntToStr(player_stats.playerLevel));
    AddElement(DataNode, 'dexterity', IntToStr(player_stats.dexterity));
    AddElement(DataNode, 'currentMagick', IntToStr(player_stats.currentMagick));
    AddElement(DataNode, 'maxMagick', IntToStr(player_stats.maxMagick));
    AddElement(DataNode, 'maxVisionRange', IntToStr(player_stats.maxVisionRange));
    AddElement(DataNode, 'playerRace', player_stats.playerRace);
    AddElement(DataNode, 'clanName', player_stats.clanName);
    AddElement(DataNode, 'enchantedWeapon', BoolToStr(player_stats.enchantedWeaponEquipped));
    AddElement(DataNode, 'projectileWeapon', BoolToStr(player_stats.projectileWeaponEquipped));
    AddElement(DataNode, 'lightEquipped', BoolToStr(player_stats.lightEquipped));
    AddElement(DataNode, 'enchWeapType', IntToStr(player_stats.enchWeapType));
    AddElement(DataNode, 'lightCounter', IntToStr(player_stats.lightCounter));
    AddElement(DataNode, 'armourPoints', IntToStr(player_stats.armourPoints));
    AddElement(DataNode, 'treasure', IntToStr(player_stats.treasure));

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
        AddElement(DataNode, 'glyph', 'T')
      else if (inventory[i].glyph = chr(186)) then
        AddElement(DataNode, 'glyph', '=')
      else if (inventory[i].glyph = chr(7)) then
        AddElement(DataNode, 'glyph', '*')
      else if (inventory[i].glyph = chr(173)) then
        AddElement(DataNode, 'glyph', 'i')
      else if (inventory[i].glyph = chr(232)) then
        AddElement(DataNode, 'glyph', '0')
      else if (inventory[i].glyph = chr(194)) then
        AddElement(DataNode, 'glyph', 'A')
      else
        AddElement(DataNode, 'glyph', inventory[i].glyph);

      AddElement(DataNode, 'glyphColour', inventory[i].glyphColour);
      AddElement(DataNode, 'numUses', IntToStr(inventory[i].numUses));
      AddElement(DataNode, 'val', IntToStr(inventory[i].value));
      AddElement(DataNode, 'throwable', BoolToStr(inventory[i].throwable));
      AddElement(DataNode, 'throwDamage', IntToStr(inventory[i].throwDamage));
      AddElement(DataNode, 'dice', IntToStr(inventory[i].dice));
      AddElement(DataNode, 'adds', IntToStr(inventory[i].adds));
      AddElement(DataNode, 'inInventory', BoolToStr(inventory[i].inInventory));
    end;

    (* Merchant inventory *)
    for i := 0 to 9 do
    begin
      DataNode := AddChild(RootNode, 'VMI');
      TDOMElement(dataNode).SetAttribute('id', UTF8Decode(IntToStr(i)));
      AddElement(DataNode, 'nm', merchant_inventory.villageInv[i].Name);
      AddElement(DataNode, 'dsc', merchant_inventory.villageInv[i].description);
      AddElement(DataNode, 'art', merchant_inventory.villageInv[i].article);
      WriteStr(Value, merchant_inventory.villageInv[i].itemType);
      AddElement(DataNode, 'typ', Value);
      WriteStr(Value, merchant_inventory.villageInv[i].itemMaterial);
      AddElement(DataNode, 'mat', Value);
      AddElement(DataNode, 'uid', IntToStr(merchant_inventory.villageInv[i].useID));

      { Convert extended ASCII to plain text }
      if (merchant_inventory.villageInv[i].glyph = chr(24)) then
        AddElement(DataNode, 'gly', 'T')
      else if (merchant_inventory.villageInv[i].glyph = chr(186)) then
        AddElement(DataNode, 'gly', '=')
      else if (merchant_inventory.villageInv[i].glyph = chr(7)) then
        AddElement(DataNode, 'gly', '*')
      else if (merchant_inventory.villageInv[i].glyph = chr(173)) then
        AddElement(DataNode, 'gly', 'i')
      else if (merchant_inventory.villageInv[i].glyph = chr(232)) then
        AddElement(DataNode, 'gly', '0')
      else if (merchant_inventory.villageInv[i].glyph = chr(194)) then
        AddElement(DataNode, 'gly', 'A')
      else
        AddElement(DataNode, 'gly', merchant_inventory.villageInv[i].glyph);

      AddElement(DataNode, 'col', merchant_inventory.villageInv[i].glyphColour);
      AddElement(DataNode, 'use', IntToStr(merchant_inventory.villageInv[i].numUses));
      AddElement(DataNode, 'val', IntToStr(merchant_inventory.villageInv[i].value));
      AddElement(DataNode, 'thr', BoolToStr(merchant_inventory.villageInv[i].throwable));
      AddElement(DataNode, 'dam', IntToStr(merchant_inventory.villageInv[i].throwDamage));
      AddElement(DataNode, 'dce', IntToStr(merchant_inventory.villageInv[i].dice));
      AddElement(DataNode, 'add', IntToStr(merchant_inventory.villageInv[i].adds));
    end;

    (* Save XML *)
    WriteXMLFile(Doc, dfileName);
  finally
    { Free memory }
    Doc.Free;
  end;
end;

function terrainLookup(inputTerrain: overworldTerrain):char;
begin
  Result := '0';
  case inputTerrain of
    tSea: Result := '0';
    tForest: Result:= '1';
    tPlains: Result:= '2'
  else { tLocation }
    Result:= '3';
  end;
end;

function terrainReverseLookup(inputTerrain: char):overworldTerrain;
begin
  Result := tPlains;
  case inputTerrain of
    '0': Result := tSea;
    '1': Result := tForest;
    '2': Result := tPlains
  else
    Result := tLocation;
  end;
end;

function colourLookup(inputColour: shortstring):shortstring;
begin
  Result := '0';
  case inputColour of
    'lightBlue': Result := '0';
    'black': Result := '1';
    'blue': Result := '2';
    'green': Result := '3';
    'lightGreen': Result := '4';
    'cyan': Result := '5';
    'red': Result := '6';
    'pink': Result := '7';
    'magenta': Result := '8';
    'lightMagenta': Result := '9';
    'brown': Result := '10';
    'grey': Result := '11';
    'darkGrey': Result := '12';
    'brownBlock': Result := '13';
    'lightCyan': Result := '14';
    'yellow': Result := '15';
    'lightGrey': Result := '16';
    'white': Result := '17';
    'DgreyBGblack': Result := '18';
    'LgreyBGblack': Result := '19';
    'blackBGbrown': Result := '20';
    'greenBlink': Result := '21';
    'pinkBlink': Result := '22';
    'cyanBGblackTXT': Result := '23'
  else
    Result := '5';
  end;
end;

function colourReverseLookup(inputColour: shortstring):shortstring;
begin
  Result := 'cyan';
  case inputColour of
    '0': Result := 'lightBlue';
    '1': Result := 'black';
    '2': Result := 'blue';
    '3': Result := 'green';
    '4': Result := 'lightGreen';
    '5': Result := 'cyan';
    '6': Result := 'red';
    '7': Result := 'pink';
    '8': Result := 'magenta';
    '9': Result := 'lightMagenta';
    '10': Result := 'brown';
    '11': Result := 'grey';
    '12': Result := 'darkGrey';
    '13': Result := 'brownBlock';
    '14': Result := 'lightCyan';
    '15': Result := 'yellow';
    '16': Result := 'lightGrey';
    '17': Result := 'white';
    '18': Result := 'DgreyBGblack';
    '19': Result := 'LgreyBGblack';
    '20': Result := 'blackBGbrown';
    '21': Result := 'greenBlink';
    '22': Result := 'pinkBlink';
    '23': Result := 'cyanBGblackTXT'
  else
    Result := 'cyan';
  end;
end;

function materialLookup(inputMaterial: tMaterial):shortstring;
begin
  Result := '0';
  case inputMaterial of
    matSteel: Result := '0';
    matIron: Result := '1';
    matWood: Result := '2';
    matLeather: Result := '3';
    matWool: Result := '4';
    matPaper: Result := '5';
    matFlammable: Result := '6';
    matStone: Result := '7';
    matGlass: Result := '8';
    matBone: Result := '9';
    matGold: Result := '10'
  else { matEmpty }
    Result := '11';
  end;
end;

function materialReverseLookup(inputMaterial: shortstring):tMaterial;
begin
  Result := matEmpty;
  case inputMaterial of
    '0': Result := matSteel;
    '1': Result := matIron;
    '2': Result:= matWood;
    '3': Result := matLeather;
    '4': Result := matWool;
    '5': Result := matPaper;
    '6': Result := matFlammable;
    '7': Result := matStone;
    '8': Result := matGlass;
    '9': Result := matBone;
    '10': Result := matGold
  else { matEmpty }
    Result := matEmpty;
  end;
end;

end.
