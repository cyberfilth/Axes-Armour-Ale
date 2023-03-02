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
function terrainLookup(inputTerrain: overworldTerrain):shortstring;
function terrainReverseLookup(inputTerrain: shortstring):overworldTerrain;
function colourLookup(inputColour: shortstring):shortstring;
function colourReverseLookup(inputColour: shortstring):shortstring;
function materialLookup(inputMaterial: tMaterial):shortstring;
function materialReverseLookup(inputMaterial: shortstring):tMaterial;
function itemTypeLookup(inputType: tItem):shortstring; 
function itemTypeReverseLookup(inputType: shortstring):tItem;
function factionLookup(inputFaction: Tfactions):shortstring;
function factionReverseLookup(factionType: shortstring):Tfactions;
function attitudeLookup(inputState: Tattitudes):shortstring;
function attitudeReverseLookup(inputState: shortstring):Tattitudes;

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

        AddElement(datanode, 'Blk', BoolToStr(island.overworldMap[r][c].Blocks));
        AddElement(datanode, 'Occ', BoolToStr(island.overworldMap[r][c].Occupied));
        AddElement(datanode, 'Dsc', BoolToStr(island.overworldMap[r][c].Discovered));
        AddElement(datanode, 'Terrain', terrainLookup(island.overworldMap[r][c].TerrainType));
        { Translate the Glyph to ASCII }
        if (island.overworldMap[r][c].Glyph = chr(6)) and
          (island.overworldMap[r][c].GlyphColour = colourLookup('green')) then
          Gplaceholder := 'A'
        else if (island.overworldMap[r][c].Glyph = chr(6)) and
          (island.overworldMap[r][c].GlyphColour = colourLookup('lightGreen')) then
          Gplaceholder := 'B'
        else if (island.overworldMap[r][c].Glyph = chr(5)) then
          Gplaceholder := 'C'
        else if (island.overworldMap[r][c].Glyph = '"') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('green')) then
          Gplaceholder := 'D'
        else if (island.overworldMap[r][c].Glyph = '''') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('green')) then
          Gplaceholder := 'E'
        else if (island.overworldMap[r][c].Glyph = '"') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('lightGreen')) then
          Gplaceholder := 'F'
        else if (island.overworldMap[r][c].Glyph = '''') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('lightGreen')) then
          Gplaceholder := 'G'
        else if (island.overworldMap[r][c].Glyph = '.') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('brown')) then
          Gplaceholder := 'H'
        else if (island.overworldMap[r][c].Glyph = ',') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('brown')) then
          Gplaceholder := 'I'
        else if (island.overworldMap[r][c].Glyph = '.') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('yellow')) then
          Gplaceholder := 'J'
        else if (island.overworldMap[r][c].Glyph = chr(94)) then
          Gplaceholder := 'K'
        else if (island.overworldMap[r][c].Glyph = ':') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('brown')) then
          Gplaceholder := 'L'
        else if (island.overworldMap[r][c].Glyph = ';') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('brown')) then
          Gplaceholder := 'M'
        else if (island.overworldMap[r][c].Glyph = ':') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('yellow')) then
          Gplaceholder := 'N'
        else if (island.overworldMap[r][c].Glyph = '~') and
          (island.overworldMap[r][c].GlyphColour = colourLookup('lightBlue')) then
          Gplaceholder := '-'
        else if (island.overworldMap[r][c].Glyph = chr(247)) and
          (island.overworldMap[r][c].GlyphColour = colourLookup('blue')) then
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
        island.overworldMap[r][c].TerrainType := terrainReverseLookup(UTF8Encode(TerrainType.TextContent));
        Glyph := TerrainType.NextSibling;
        if (UTF8Encode(Glyph.TextContent[1]) = 'A') then
        begin
          island.overworldMap[r][c].Glyph := chr(6);
          island.overworldMap[r][c].GlyphColour := colourLookup('green');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'B') then
        begin
          island.overworldMap[r][c].Glyph := chr(6);
          island.overworldMap[r][c].GlyphColour := colourLookup('lightGreen');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'C') then
        begin
          island.overworldMap[r][c].Glyph := chr(5);
          island.overworldMap[r][c].GlyphColour := colourLookup('green');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'D') then
        begin
          island.overworldMap[r][c].Glyph := '"';
          island.overworldMap[r][c].GlyphColour := colourLookup('green');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'E') then
        begin
          island.overworldMap[r][c].Glyph := '''';
          island.overworldMap[r][c].GlyphColour := colourLookup('green');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'F') then
        begin
          island.overworldMap[r][c].Glyph := '"';
          island.overworldMap[r][c].GlyphColour := colourLookup('lightGreen');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'G') then
        begin
          island.overworldMap[r][c].Glyph := '''';
          island.overworldMap[r][c].GlyphColour := colourLookup('lightGreen');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'H') then
        begin
          island.overworldMap[r][c].Glyph := '.';
          island.overworldMap[r][c].GlyphColour := colourLookup('brown');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'I') then
        begin
          island.overworldMap[r][c].Glyph := ',';
          island.overworldMap[r][c].GlyphColour := colourLookup('brown');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'J') then
        begin
          island.overworldMap[r][c].Glyph := '.';
          island.overworldMap[r][c].GlyphColour := colourLookup('yellow');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'K') then
        begin
          island.overworldMap[r][c].Glyph := chr(94);
          island.overworldMap[r][c].GlyphColour := colourLookup('brown');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'L') then
        begin
          island.overworldMap[r][c].Glyph := ':';
          island.overworldMap[r][c].GlyphColour := colourLookup('brown');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'M') then
        begin
          island.overworldMap[r][c].Glyph := ';';
          island.overworldMap[r][c].GlyphColour := colourLookup('brown');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = 'N') then
        begin
          island.overworldMap[r][c].Glyph := ':';
          island.overworldMap[r][c].GlyphColour := colourLookup('yellow');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = '>') then
        begin
          island.overworldMap[r][c].Glyph := '>';
          island.overworldMap[r][c].GlyphColour := colourLookup('white');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = '~') then
        begin
          island.overworldMap[r][c].Glyph := chr(247);
          island.overworldMap[r][c].GlyphColour := colourLookup('blue');
        end
        else if (UTF8Encode(Glyph.TextContent[1]) = '-') then
        begin
          island.overworldMap[r][c].Glyph := '~';
          island.overworldMap[r][c].GlyphColour := colourLookup('lightBlue');
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
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(True)))
          else
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(False)));
        end
        { if dungeon type is a dungeon }
        else if (dType = tDungeon) then
        begin
          if (smallGrid.processed_dungeon[r][c] = '.') or (smallGrid.processed_dungeon[r][c] = 'X') or
            (smallGrid.processed_dungeon[r][c] = '>') or (smallGrid.processed_dungeon[r][c] = '<') then
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(True)));
        end
        { if location is a village }
        else if (dType = tVillage) then
        begin
          if (village.dungeonArray[r][c] = '.') or (village.dungeonArray[r][c] = '<') or
            (village.dungeonArray[r][c] = '"') then
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(True)));
        end
        { if dungeon type is a crypt }
        else if (dType = tCrypt) then
        begin
          if (crypt.dungeonArray[r][c] = '.') or (crypt.dungeonArray[r][c] = 'X') or
            (crypt.dungeonArray[r][c] = '>') or (crypt.dungeonArray[r][c] = '<') then
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(True)));
        end
        { if dungeon type is a stone cavern }
        else if (dType = tStoneCavern) then
        begin
          if (stone_cavern.terrainArray[r][c] = '.') or (stone_cavern.terrainArray[r][c] = 'X') or
            (stone_cavern.terrainArray[r][c] = '>') or (stone_cavern.terrainArray[r][c] = '<') then
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(False)))
          else
            AddElement(datanode, 'blk', UTF8Decode(BoolToStr(True)));
        end;
        AddElement(datanode, 'vis', UTF8Decode(BoolToStr(False)));
        AddElement(datanode, 'occ', UTF8Decode(BoolToStr(False)));
        AddElement(datanode, 'dis', UTF8Decode(BoolToStr(False)));
        { if dungeon type is a cave }
        if (dType = tCave) then
        begin
          AddElement(datanode, 'g', UTF8Decode(cave.terrainArray[r][c]));
        end
        { if dungeon type is a dungeon }
        else if (dType = tDungeon) then
        begin
          AddElement(datanode, 'g', UTF8Decode(smallGrid.processed_dungeon[r][c]));
        end
        { if location is a village }
        else if (dType = tVillage) then
        begin
          AddElement(datanode, 'g', UTF8Decode(village.dungeonArray[r][c]));
        end
        { if dungeon type is a crypt }
        else if (dType = tCrypt) then
        begin
          AddElement(datanode, 'g', UTF8Decode(crypt.dungeonArray[r][c]));
        end
        { if dungeon type is a stone crypt }
        else if (dType = tStoneCavern) then
        begin
          AddElement(datanode, 'g', UTF8Decode(stone_cavern.terrainArray[r][c]));
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
  dfileName: shortstring;

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
        AddElement(datanode, 'blk', BoolToStr(map.maparea[r][c].Blocks));
        AddElement(datanode, 'vis', BoolToStr(map.maparea[r][c].Visible));
        AddElement(datanode, 'occ', BoolToStr(map.maparea[r][c].Occupied));
        AddElement(datanode, 'dis', BoolToStr(map.maparea[r][c].Discovered));
        AddElement(datanode, 'g', map.maparea[r][c].Glyph);
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
          AddElement(DataNode, 'dsc', itemList[i].itemDescription);
          AddElement(DataNode, 'art', itemList[i].itemArticle);
          AddElement(DataNode, 'itemType', itemTypeLookup(itemList[i].itemType));
          AddElement(DataNode, 'itemMaterial', materialLookup(itemList[i].itemMaterial));
          AddElement(DataNode, 'useID', IntToStr(itemList[i].useID));

          { Convert extended ASCII to plain text }
          if (itemList[i].glyph = chr(24)) then
            AddElement(DataNode, 'g', 'T')
          else if (itemList[i].glyph = chr(186)) then
            AddElement(DataNode, 'g', '=')
          else if (itemList[i].glyph = chr(7)) then
            AddElement(DataNode, 'g', '*')
          else if (itemList[i].glyph = chr(173)) then
            AddElement(DataNode, 'g', 'i')
          else if (itemList[i].glyph = chr(232)) then
            AddElement(DataNode, 'g', '0')
          else if (itemList[i].glyph = chr(194)) then
            AddElement(DataNode, 'g', 'A')
          else
            AddElement(DataNode, 'g', itemList[i].glyph);

          AddElement(DataNode, 'gc', colourLookup(itemList[i].glyphColour));
          AddElement(DataNode, 'inv', BoolToStr(itemList[i].inView));
          AddElement(DataNode, 'posX', IntToStr(itemList[i].posX));
          AddElement(DataNode, 'posY', IntToStr(itemList[i].posY));
          AddElement(DataNode, 'numUses', IntToStr(itemList[i].NumberOfUses));
          AddElement(DataNode, 'val', IntToStr(itemList[i].value));
          AddElement(DataNode, 'onMap', BoolToStr(itemList[i].onMap));
          AddElement(DataNode, 'throwable', BoolToStr(itemList[i].throwable));
          AddElement(DataNode, 'throwDamage', IntToStr(itemList[i].throwDamage));
          AddElement(DataNode, 'dice', IntToStr(itemList[i].dice));
          AddElement(DataNode, 'adds', IntToStr(itemList[i].adds));
          AddElement(DataNode, 'dis', BoolToStr(itemList[i].discovered));
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
          AddElement(DataNode, 'rce', entities.entityList[i].race);
          AddElement(DataNode, 'int', entities.entityList[i].intName);
          AddElement(DataNode, 'art', BoolToStr(entities.entityList[i].article));
          AddElement(DataNode, 'dsc', entities.entityList[i].description);

          { Convert extended ASCII to plain text }
          if (entities.entityList[i].glyph = chr(1)) then
            AddElement(DataNode, 'g', '=') { Hob }
          else if (entities.entityList[i].glyph = chr(2)) then
            AddElement(DataNode, 'g', '#') { Trog }
          else if (entities.entityList[i].glyph = chr(157)) then
            AddElement(DataNode, 'g', '!') { Hornet }
          else
            AddElement(DataNode, 'g', entities.entityList[i].glyph);

          AddElement(DataNode, 'gc', colourLookup(entities.entityList[i].glyphColour));
          AddElement(DataNode, 'mhp', IntToStr(entities.entityList[i].maxHP));
          AddElement(DataNode, 'chp', IntToStr(entities.entityList[i].currentHP));
          AddElement(DataNode, 'att', IntToStr(entities.entityList[i].attack));
          AddElement(DataNode, 'def', IntToStr(entities.entityList[i].defence));
          AddElement(DataNode, 'wd', IntToStr(entities.entityList[i].weaponDice));
          AddElement(DataNode, 'wa', IntToStr(entities.entityList[i].weaponAdds));
          AddElement(DataNode, 'xpr', IntToStr(entities.entityList[i].xpReward));
          AddElement(DataNode, 'vr', IntToStr(entities.entityList[i].visionRange));
          AddElement(DataNode, 'mc', IntToStr(entities.entityList[i].moveCount));
          AddElement(DataNode, 'tx', IntToStr(entities.entityList[i].targetX));
          AddElement(DataNode, 'ty', IntToStr(entities.entityList[i].targetY));
          AddElement(DataNode, 'inv', BoolToStr(entities.entityList[i].inView));
          AddElement(DataNode, 'blk', BoolToStr(entities.entityList[i].blocks));
          AddElement(DataNode, 'fac', factionLookup(entities.entityList[i].faction));
          AddElement(DataNode, 'ste', attitudeLookup(entities.entityList[i].state));
          AddElement(DataNode, 'dis', BoolToStr(entities.entityList[i].discovered));
          AddElement(DataNode, 'weq', BoolToStr(entities.entityList[i].weaponEquipped));
          AddElement(DataNode, 'aeq', BoolToStr(entities.entityList[i].armourEquipped));
          AddElement(DataNode, 'stsd', BoolToStr(entities.entityList[i].stsDrunk));
          AddElement(DataNode, 'stsp', BoolToStr(entities.entityList[i].stsPoison));
          AddElement(DataNode, 'stsb', BoolToStr(entities.entityList[i].stsBewild));
          AddElement(DataNode, 'stsf', BoolToStr(entities.entityList[i].stsFrozen));
          AddElement(DataNode, 'tmrd', IntToStr(entities.entityList[i].tmrDrunk));
          AddElement(DataNode, 'tmrp', IntToStr(entities.entityList[i].tmrPoison));
          AddElement(DataNode, 'tmrb', IntToStr(entities.entityList[i].tmrBewild));
          AddElement(DataNode, 'tmrf', IntToStr(entities.entityList[i].tmrFrozen));
          AddElement(DataNode, 'hasp', BoolToStr(entities.entityList[i].hasPath));
          AddElement(DataNode, 'desr', BoolToStr(entities.entityList[i].destinationReached));
          (* Save path coordinates *)
          for coords := 1 to 30 do
          begin
            AddElement(DataNode, 'cdx' + IntToStr(coords), IntToStr(entities.entityList[i].smellPath[coords].X));
            AddElement(DataNode, 'cdy' + IntToStr(coords), IntToStr(entities.entityList[i].smellPath[coords].Y));
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
        items.itemList[i].itemDescription := UTF8Encode(ItemsNode.FindNode('dsc').TextContent);
        items.itemList[i].itemArticle := UTF8Encode(ItemsNode.FindNode('art').TextContent);
        items.itemList[i].itemType := itemTypeReverseLookup(UTF8Encode(ItemsNode.FindNode('itemType').TextContent));
        items.itemList[i].itemMaterial := materialReverseLookup(UTF8Encode(ItemsNode.FindNode('itemMaterial').TextContent));
        items.itemList[i].useID := StrToInt(UTF8Encode(ItemsNode.FindNode('useID').TextContent));

        { Convert plain text to extended ASCII }
        if (ItemsNode.FindNode('g').TextContent[1] = 'T') then { club / dagger }
          items.itemList[i].glyph := chr(24)
        else if (ItemsNode.FindNode('g').TextContent[1] = '=') then
          { Magickal staff }
          items.itemList[i].glyph := chr(186)
        else if (ItemsNode.FindNode('g').TextContent[1] = '*') then { rock }
          items.itemList[i].glyph := chr(7)
        else if (ItemsNode.FindNode('g').TextContent[1] = 'i') then { pointy stick }
          items.itemList[i].glyph := chr(173)
        else if (ItemsNode.FindNode('g').TextContent[1] = '0') then
          { Pixie in a jar }
          items.itemList[i].glyph := chr(232)
        else if (ItemsNode.FindNode('g').TextContent[1] = 'A') then { axe }
          items.itemList[i].glyph := chr(194)
        else
          items.itemList[i].glyph := char(widechar(ItemsNode.FindNode('g').TextContent[1]));

        items.itemList[i].glyphColour := colourReverseLookup(UTF8Encode(ItemsNode.FindNode('gc').TextContent));
        items.itemList[i].inView := StrToBool(UTF8Encode(ItemsNode.FindNode('inv').TextContent));
        items.itemList[i].posX := StrToInt(UTF8Encode(ItemsNode.FindNode('posX').TextContent));
        items.itemList[i].posY := StrToInt(UTF8Encode(ItemsNode.FindNode('posY').TextContent));
        items.itemList[i].NumberOfUses := StrToInt(UTF8Encode(ItemsNode.FindNode('numUses').TextContent));
        items.itemList[i].value := StrToInt(UTF8Encode(ItemsNode.FindNode('val').TextContent));
        items.itemList[i].onMap := StrToBool(UTF8Encode(ItemsNode.FindNode('onMap').TextContent));
        items.itemList[i].throwable := StrToBool(UTF8Encode(ItemsNode.FindNode('throwable').TextContent));
        items.itemList[i].throwDamage := StrToInt(UTF8Encode(ItemsNode.FindNode('throwDamage').TextContent));
        items.itemList[i].dice := StrToInt(UTF8Encode(ItemsNode.FindNode('dice').TextContent));
        items.itemList[i].adds := StrToInt(UTF8Encode(ItemsNode.FindNode('adds').TextContent));
        items.itemList[i].discovered := StrToBool(UTF8Encode(ItemsNode.FindNode('dis').TextContent));
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
        entities.entityList[i].race := UTF8Encode(NPCnode.FindNode('rce').TextContent);
        entities.entityList[i].intName := UTF8Encode(NPCnode.FindNode('int').TextContent);
        entities.entityList[i].article := StrToBool(UTF8Encode(NPCnode.FindNode('art').TextContent));
        entities.entityList[i].description := UTF8Encode(NPCnode.FindNode('dsc').TextContent);

        { Convert plain text to extended ASCII }
        if (NPCnode.FindNode('g').TextContent[1] = '=') then
          entities.entityList[i].glyph := chr(1)
        else if (NPCnode.FindNode('g').TextContent[1] = '#') then
          entities.entityList[i].glyph := chr(2)
        else if (NPCnode.FindNode('g').TextContent[1] = '!') then
          entities.entityList[i].glyph := chr(157)
        else
          entities.entityList[i].glyph := UTF8Encode(char(widechar(NPCnode.FindNode('g').TextContent[1])));

        entities.entityList[i].glyphColour := colourReverseLookup(UTF8Encode(NPCnode.FindNode('gc').TextContent));
        entities.entityList[i].maxHP := StrToInt(UTF8Encode(NPCnode.FindNode('mhp').TextContent));
        entities.entityList[i].currentHP := StrToInt(UTF8Encode(NPCnode.FindNode('chp').TextContent));
        entities.entityList[i].attack := StrToInt(UTF8Encode(NPCnode.FindNode('att').TextContent));
        entities.entityList[i].defence := StrToInt(UTF8Encode(NPCnode.FindNode('def').TextContent));
        entities.entityList[i].weaponDice := StrToInt(UTF8Encode(NPCnode.FindNode('wd').TextContent));
        entities.entityList[i].weaponAdds := StrToInt(UTF8Encode(NPCnode.FindNode('wa').TextContent));
        entities.entityList[i].xpReward := StrToInt(UTF8Encode(NPCnode.FindNode('xpr').TextContent));
        entities.entityList[i].visionRange := StrToInt(UTF8Encode(NPCnode.FindNode('vr').TextContent));
        entities.entityList[i].moveCount := StrToInt(UTF8Encode(NPCnode.FindNode('mc').TextContent));
        entities.entityList[i].targetX := StrToInt(UTF8Encode(NPCnode.FindNode('tx').TextContent));
        entities.entityList[i].targetY := StrToInt(UTF8Encode(NPCnode.FindNode('ty').TextContent));
        entities.entityList[i].inView := StrToBool(UTF8Encode(NPCnode.FindNode('inv').TextContent));
        entities.entityList[i].blocks := StrToBool(UTF8Encode(NPCnode.FindNode('blk').TextContent));
        entities.entityList[i].faction := factionReverseLookup(UTF8Encode(NPCnode.FindNode('fac').TextContent));
        entities.entityList[i].state := attitudeReverseLookup(UTF8Encode(NPCnode.FindNode('ste').TextContent));
        entities.entityList[i].discovered := StrToBool(UTF8Encode(NPCnode.FindNode('dis').TextContent));
        entities.entityList[i].weaponEquipped := StrToBool(UTF8Encode(NPCnode.FindNode('weq').TextContent));
        entities.entityList[i].armourEquipped := StrToBool(UTF8Encode(NPCnode.FindNode('aeq').TextContent));
        entities.entityList[i].isDead := False;
        entities.entityList[i].stsDrunk := StrToBool(UTF8Encode(NPCnode.FindNode('stsd').TextContent));
        entities.entityList[i].stsPoison := StrToBool(UTF8Encode(NPCnode.FindNode('stsp').TextContent));
        entities.entityList[i].stsBewild := StrToBool(UTF8Encode(NPCnode.FindNode('stsb').TextContent));
        entities.entityList[i].tmrDrunk := StrToInt(UTF8Encode(NPCnode.FindNode('tmrd').TextContent));
        entities.entityList[i].tmrPoison := StrToInt(UTF8Encode(NPCnode.FindNode('tmrp').TextContent));
        entities.entityList[i].tmrBewild := StrToInt(UTF8Encode(NPCnode.FindNode('tmrb').TextContent));
        entities.entityList[i].hasPath := StrToBool(UTF8Encode(NPCnode.FindNode('hasp').TextContent));
        entities.entityList[i].destinationReached := StrToBool(UTF8Encode(NPCnode.FindNode('desr').TextContent));
        for coords := 1 to 30 do
        begin
          entities.entityList[i].smellPath[coords].X := StrToInt(UTF8Encode(NPCnode.FindNode(UTF8Decode('cdx' + IntToStr(coords))).TextContent));
          entities.entityList[i].smellPath[coords].Y := StrToInt(UTF8Encode(NPCnode.FindNode(UTF8Decode('cdy' + IntToStr(coords))).TextContent));
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
    entities.entityList[0].race := UTF8Encode(PlayerDataNode.FindNode('rce').TextContent);
    entities.entityList[0].description := UTF8Encode(PlayerDataNode.FindNode('dsc').TextContent);
    entities.entityList[0].glyph := UTF8Encode(char(widechar(PlayerDataNode.FindNode('g').TextContent[1])));
    entities.entityList[0].glyphColour := colourReverseLookup(UTF8Encode(PlayerDataNode.FindNode('gc').TextContent));
    entities.entityList[0].maxHP := StrToInt(UTF8Encode(PlayerDataNode.FindNode('mhp').TextContent));
    entities.entityList[0].currentHP := StrToInt(UTF8Encode(PlayerDataNode.FindNode('chp').TextContent));
    entities.entityList[0].attack := StrToInt(UTF8Encode(PlayerDataNode.FindNode('att').TextContent));
    entities.entityList[0].defence := StrToInt(UTF8Encode(PlayerDataNode.FindNode('def').TextContent));
    entities.entityList[0].weaponDice := StrToInt(UTF8Encode(PlayerDataNode.FindNode('wd').TextContent));
    entities.entityList[0].weaponAdds := StrToInt(UTF8Encode(PlayerDataNode.FindNode('wa').TextContent));
    entities.entityList[0].xpReward := StrToInt(UTF8Encode(PlayerDataNode.FindNode('xpr').TextContent));
    entities.entityList[0].visionRange := StrToInt(UTF8Encode(PlayerDataNode.FindNode('vr').TextContent));
    entities.entityList[0].moveCount := StrToInt(UTF8Encode(PlayerDataNode.FindNode('mc').TextContent));
    entities.entityList[0].targetX := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tx').TextContent));
    entities.entityList[0].targetY := StrToInt(UTF8Encode(PlayerDataNode.FindNode('ty').TextContent));
    entities.entityList[0].inView := True;
    entities.entityList[0].blocks := False;
    entities.entityList[0].discovered := True;
    entities.entityList[0].weaponEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('weq').TextContent));
    entities.entityList[0].armourEquipped := StrToBool(UTF8Encode(PlayerDataNode.FindNode('aeq').TextContent));
    entities.entityList[0].isDead := False;
    entities.entityList[0].stsDrunk := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsd').TextContent));
    entities.entityList[0].stsPoison := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsp').TextContent));
    entities.entityList[0].stsBewild := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsb').TextContent));
    entities.entityList[0].stsFrozen := StrToBool(UTF8Encode(PlayerDataNode.FindNode('stsf').TextContent));
    entities.entityList[0].tmrDrunk := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrd').TextContent));
    entities.entityList[0].tmrPoison := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrp').TextContent));
    entities.entityList[0].tmrBewild := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrb').TextContent));
    entities.entityList[0].tmrFrozen := StrToInt(UTF8Encode(PlayerDataNode.FindNode('tmrf').TextContent));
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
      player_inventory.inventory[i].description := UTF8Encode(InventoryNode.FindNode('dsc').TextContent);
      player_inventory.inventory[i].article := UTF8Encode(InventoryNode.FindNode('art').TextContent);
      player_inventory.inventory[i].itemType := itemTypeReverseLookup(UTF8Encode(InventoryNode.FindNode('itemType').TextContent));
      player_inventory.inventory[i].itemMaterial := materialReverseLookup(UTF8Encode(InventoryNode.FindNode('itemMaterial').TextContent));
      player_inventory.inventory[i].useID := StrToInt(UTF8Encode(InventoryNode.FindNode('useID').TextContent));

      { Convert plain text to extended ASCII }
      if (InventoryNode.FindNode('g').TextContent[1] = 'T') then
        player_inventory.inventory[i].glyph := chr(24)
      else if (InventoryNode.FindNode('g').TextContent[1] = '=') then
        player_inventory.inventory[i].glyph := chr(186)
      else if (InventoryNode.FindNode('g').TextContent[1] = '*') then
        player_inventory.inventory[i].glyph := chr(7)
      else if (InventoryNode.FindNode('g').TextContent[1] = 'i') then
        player_inventory.inventory[i].glyph := chr(173)
      else if (InventoryNode.FindNode('g').TextContent[1] = '0') then
        player_inventory.inventory[i].glyph := chr(232)
      else if (InventoryNode.FindNode('g').TextContent[1] = 'A') then
        player_inventory.inventory[i].glyph := chr(194)
      else
        player_inventory.inventory[i].glyph := char(widechar(InventoryNode.FindNode('g').TextContent[1]));

      player_inventory.inventory[i].glyphColour := colourReverseLookup(UTF8Encode(InventoryNode.FindNode('gc').TextContent));
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

      merchant_inventory.villageInv[i].glyphColour := colourReverseLookup(UTF8Encode(InventoryNode.FindNode('col').TextContent));
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
    AddElement(DataNode, 'rce', entities.entityList[0].race);
    AddElement(DataNode, 'dsc', entities.entityList[0].description);
    AddElement(DataNode, 'g', entities.entityList[0].glyph);
    AddElement(DataNode, 'gc', colourLookup(entities.entityList[0].glyphColour));
    AddElement(DataNode, 'mhp', IntToStr(entities.entityList[0].maxHP));
    AddElement(DataNode, 'chp', IntToStr(entities.entityList[0].currentHP));
    AddElement(DataNode, 'att', IntToStr(entities.entityList[0].attack));
    AddElement(DataNode, 'def', IntToStr(entities.entityList[0].defence));
    AddElement(DataNode, 'wd', IntToStr(entities.entityList[0].weaponDice));
    AddElement(DataNode, 'wa', IntToStr(entities.entityList[0].weaponAdds));
    AddElement(DataNode, 'xpr', IntToStr(entities.entityList[0].xpReward));
    AddElement(DataNode, 'vr', IntToStr(entities.entityList[0].visionRange));
    AddElement(DataNode, 'mc', IntToStr(entities.entityList[0].moveCount));
    AddElement(DataNode, 'tx', IntToStr(entities.entityList[0].targetX));
    AddElement(DataNode, 'ty', IntToStr(entities.entityList[0].targetY));
    AddElement(DataNode, 'weq', BoolToStr(entities.entityList[0].weaponEquipped));
    AddElement(DataNode, 'aeq', BoolToStr(entities.entityList[0].armourEquipped));
    AddElement(DataNode, 'stsd', BoolToStr(entities.entityList[0].stsDrunk));
    AddElement(DataNode, 'stsp', BoolToStr(entities.entityList[0].stsPoison));
    AddElement(DataNode, 'stsb', BoolToStr(entities.entityList[0].stsBewild));
    AddElement(DataNode, 'stsf', BoolToStr(entities.entityList[0].stsFrozen));
    AddElement(DataNode, 'tmrd', IntToStr(entities.entityList[0].tmrDrunk));
    AddElement(DataNode, 'tmrp', IntToStr(entities.entityList[0].tmrPoison));
    AddElement(DataNode, 'tmrb', IntToStr(entities.entityList[0].tmrBewild));
    AddElement(DataNode, 'tmrf', IntToStr(entities.entityList[0].tmrFrozen));
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
      AddElement(DataNode, 'dsc', inventory[i].description);
      AddElement(DataNode, 'art', inventory[i].article);
      AddElement(DataNode, 'itemType', itemTypeLookup(inventory[i].itemType));
      AddElement(DataNode, 'itemMaterial', materialLookup(inventory[i].itemMaterial));
      AddElement(DataNode, 'useID', IntToStr(inventory[i].useID));

      { Convert extended ASCII to plain text }
      if (inventory[i].glyph = chr(24)) then
        AddElement(DataNode, 'g', 'T')
      else if (inventory[i].glyph = chr(186)) then
        AddElement(DataNode, 'g', '=')
      else if (inventory[i].glyph = chr(7)) then
        AddElement(DataNode, 'g', '*')
      else if (inventory[i].glyph = chr(173)) then
        AddElement(DataNode, 'g', 'i')
      else if (inventory[i].glyph = chr(232)) then
        AddElement(DataNode, 'g', '0')
      else if (inventory[i].glyph = chr(194)) then
        AddElement(DataNode, 'g', 'A')
      else
        AddElement(DataNode, 'g', inventory[i].glyph);

      AddElement(DataNode, 'gc', colourLookup(inventory[i].glyphColour));
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

      AddElement(DataNode, 'col', colourLookup(merchant_inventory.villageInv[i].glyphColour));
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

function terrainLookup(inputTerrain: overworldTerrain):shortstring;
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

function terrainReverseLookup(inputTerrain: shortstring):overworldTerrain;
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
  Result := '5';
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
  Result := 'b';
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
    matGold: Result := 'a'
  else { matEmpty }
    Result := 'b';
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
    'b': Result := matGold
  else { matEmpty }
    Result := matEmpty;
  end;
end;

function itemTypeLookup(inputType: tItem):shortstring; 
begin
  Result := 'a';
  case inputType of
    itmDrink: Result := '0';
    itmWeapon: Result := '1';
    itmArmour: Result := '2';
    itmQuest: Result := '3';
    itmProjectile: Result := '4';
    itmProjectileWeapon: Result := '5';
    itmAmmo: Result := '6';
    itmLightSource: Result := '7';
    itmTrap: Result := '8';
    itmTreasure: Result := '9'
  else { itmEmptySlot }
    Result := 'a';
  end;
end;

function itemTypeReverseLookup(inputType: shortstring):tItem;
begin
  Result := itmEmptySlot;
  case inputType of
    '0': Result := itmDrink;
    '1': Result := itmWeapon;
    '2': Result := itmArmour;
    '3': Result := itmQuest;
    '4': Result := itmProjectile;
    '5': Result := itmProjectileWeapon;
    '6': Result := itmAmmo;
    '7': Result := itmLightSource;
    '8': Result := itmTrap;
    '9': Result := itmTreasure
  else { itmEmptySlot }
    Result := itmEmptySlot;
  end;
end;

function factionLookup(inputFaction: Tfactions):shortstring;
begin
  Result := '2';
  case inputFaction of
    redcapFaction: Result := '0';
    bugFaction: Result := '1';
    animalFaction: Result := '2';
    fungusFaction: Result := '3';
    undeadFaction: Result := '4';
    trapFaction: Result := '5'
  else { npcFaction }
    Result := '6';
  end;
end;

function factionReverseLookup(factionType: shortstring):Tfactions;
begin
  Result := animalFaction;
  case factionType of
    '0': Result := redcapFaction;
    '1': Result := bugFaction;
    '2': Result := animalFaction;
    '3': Result := fungusFaction;
    '4': Result := undeadFaction;
    '5': Result := trapFaction
  else { npcFaction }
    Result := npcFaction;
  end;
end;

function attitudeLookup(inputState: Tattitudes):shortstring;
begin
  Result := '0';
  case inputState of
    stateNeutral: Result := '0';
    stateHostile: Result := '1'
  else { stateEscape }
    Result := '2';
  end;
end;

function attitudeReverseLookup(inputState: shortstring):Tattitudes;
begin
  Result := stateNeutral;
  case inputState of
    '0': Result := stateNeutral;
    '1': Result := stateHostile
  else { 2 }
    Result := stateEscape;
  end;
end;

end.