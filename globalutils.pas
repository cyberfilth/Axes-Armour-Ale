(* Common functions / utilities *)

unit globalutils;

{$mode objfpc}{$H+}

interface

uses
  Graphics, SysUtils, DOM, XMLWrite, XMLRead;

type
  coordinates = record
    x, y: smallint;
  end;

const
  (* Version info - a = Alpha, d = Debug, r = Release *)
  VERSION = '18a';
  (* Save game file *)
  {$IFDEF Linux}
  saveFile = '.axes.data';
  {$ENDIF}
  {$IFDEF Windows}
  saveFile = 'axes.data';
  {$ENDIF}
  (* Columns of the game map *)
  MAXCOLUMNS = 67;
  (* Rows of the game map *)
  MAXROWS = 38;
  (* Colours *)
  BACKGROUNDCOLOUR = TColor($131A00);
  UICOLOUR = TColor($808000);
  UITEXTCOLOUR = TColor($F5F58C);
  MESSAGEFADE1 = TColor($A0A033);
  MESSAGEFADE2 = TColor($969613);
  MESSAGEFADE3 = TColor($808000);
  MESSAGEFADE4 = TColor($686800);
  MESSAGEFADE5 = TColor($4F4F00);
  MESSAGEFADE6 = TColor($2E2E00);

var
  dungeonArray: array[1..MAXROWS, 1..MAXCOLUMNS] of char;
  (* Number of rooms in the current dungeon *)
  currentDgnTotalRooms: smallint;
  (* list of coordinates of centre of each room *)
  currentDgncentreList: array of coordinates;

(* Select random number from a range *)
function randomRange(fromNumber, toNumber: smallint): smallint;
(* Draw image to temporary screen buffer *)
procedure drawToBuffer(x, y: smallint; image: TBitmap);
(* Write text to temporary screen buffer *)
procedure writeToBuffer(x, y: smallint; messageColour: TColor; message: string);
(* Draw an NPC to temporary screen buffer *)
procedure drawNPCtoBuffer(x, y: smallint; glyphTextColour: TColor; glyphCharacter: char);
(* Save game state to XML file *)
procedure saveGame;
(* Load saved game *)
procedure loadGame;

implementation

uses
  main, map, entities, player;

// Random(Range End - Range Start) + Range Start
function randomRange(fromNumber, toNumber: smallint): smallint;
var
  p: smallint;
begin
  p := toNumber - fromNumber;
  Result := random(p + 1) + fromNumber;
end;

procedure drawToBuffer(x, y: smallint; image: TBitmap);
begin
  main.tempScreen.Canvas.Draw(x, y, image);
end;

procedure writeToBuffer(x, y: smallint; messageColour: TColor; message: string);
begin
  main.tempScreen.Canvas.Font.Color := messageColour;
  main.tempScreen.Canvas.TextOut(x, y, message);
end;

procedure drawNPCtoBuffer(x, y: smallint; glyphTextColour: TColor; glyphCharacter: char);
begin
  main.tempScreen.Canvas.Brush.Style := bsClear;
  main.tempScreen.Canvas.Font.Color := glyphTextColour;
  main.tempScreen.Canvas.TextOut(map.mapToScreen(x), (map.mapToScreen(y) + 1) -
    (tileSize div 2), glyphCharacter);
  (* Add a duplicate glyph, slightly offset, to make the glyph bold *)
  main.tempScreen.Canvas.TextOut(map.mapToScreen(x) + 1, (map.mapToScreen(y) + 1) -
    (tileSize div 2), glyphCharacter);
end;

procedure saveGame;
var
  i, r, c: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;

  procedure AddElement(Node: TDOMNode; Name, Value: string);
  var
    NameNode, ValueNode: TDomNode;
  begin
    NameNode := Doc.CreateElement(Name);    // creates future Node/Name
    ValueNode := Doc.CreateTextNode(Value);  // creates future Node/Name/Value
    NameNode.Appendchild(ValueNode);         // place value in place
    Node.Appendchild(NameNode);              // place Name in place
  end;

  function AddChild(Node: TDOMNode; ChildName: string): TDomNode;
  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(ChildName);
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
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
    AddElement(datanode, 'npcAmount', IntToStr(entities.npcAmount));

    (* map tiles *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        DataNode := AddChild(RootNode, 'map_tiles');
        TDOMElement(dataNode).SetAttribute('id', IntToStr(maparea[r][c].id));
        AddElement(datanode, 'Blocks', BoolToStr(map.maparea[r][c].Blocks));
        AddElement(datanode, 'Visible', BoolToStr(map.maparea[r][c].Visible));
        AddElement(datanode, 'Occupied', BoolToStr(map.maparea[r][c].Occupied));
        AddElement(datanode, 'Discovered', BoolToStr(map.maparea[r][c].Discovered));
        AddElement(datanode, 'Glyph', map.maparea[r][c].Glyph);
      end;
    end;

    (* Player record *)
    DataNode := AddChild(RootNode, 'Player');
    AddElement(DataNode, 'currentHP', IntToStr(player.ThePlayer.currentHP));
    AddElement(DataNode, 'maxHP', IntToStr(player.ThePlayer.maxHP));
    AddElement(DataNode, 'attack', IntToStr(player.ThePlayer.attack));
    AddElement(DataNode, 'defense', IntToStr(player.ThePlayer.defense));
    AddElement(DataNode, 'posX', IntToStr(player.ThePlayer.posX));
    AddElement(DataNode, 'posY', IntToStr(player.ThePlayer.posY));
    AddElement(DataNode, 'visionRange', IntToStr(player.ThePlayer.visionRange));

    (* NPC records *)
    for i := 1 to entities.npcAmount do
    begin
      DataNode := AddChild(RootNode, 'NPC');
      TDOMElement(dataNode).SetAttribute('npcID', IntToStr(i));
      AddElement(DataNode, 'race', entities.entityList[i].race);
      AddElement(DataNode, 'description', entities.entityList[i].description);
      AddElement(DataNode, 'glyph', entities.entityList[i].glyph);
      AddElement(DataNode, 'glyphColour', IntToStr(entities.entityList[i].glyphColour));
      AddElement(DataNode, 'currentHP', IntToStr(entities.entityList[i].currentHP));
      AddElement(DataNode, 'maxHP', IntToStr(entities.entityList[i].maxHP));
      AddElement(DataNode, 'attack', IntToStr(entities.entityList[i].attack));
      AddElement(DataNode, 'defense', IntToStr(entities.entityList[i].defense));
      AddElement(DataNode, 'inView', BoolToStr(entities.entityList[i].inView));
      AddElement(DataNode, 'discovered', BoolToStr(entities.entityList[i].discovered));
      AddElement(DataNode, 'isDead', BoolToStr(entities.entityList[i].isDead));
      AddElement(DataNode, 'posX', IntToStr(entities.entityList[i].posX));
      AddElement(DataNode, 'posY', IntToStr(entities.entityList[i].posY));
    end;

    (* Save XML *)
    WriteXMLFile(Doc, GetUserDir+saveFile);
  finally
    Doc.Free;  // free memory
  end;
end;

procedure loadGame;
var
  RootNode, ParentNode, Tile, NextNode, Blocks, Visible, Occupied, Discovered, PlayerNode, NPCnode, GlyphNode: TDOMNode;
  Doc: TXMLDocument;
  r, c, i: integer;
begin
  try
    (* Read in xml file from disk *)
    ReadXMLFile(Doc, GetUserDir+saveFile);
    (* Retrieve the nodes *)
    RootNode := Doc.DocumentElement.FindNode('GameData');
    ParentNode := RootNode.FirstChild.NextSibling;
    (* NPC amount *)
    entities.npcAmount := StrToInt(ParentNode.TextContent);
    (* Map tile data *)
    Tile := RootNode.NextSibling;
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        map.maparea[r][c].id := StrToInt(Tile.Attributes.Item[0].NodeValue);
        Blocks := Tile.FirstChild;
        map.maparea[r][c].Blocks := StrToBool(Blocks.TextContent);
        Visible := Blocks.NextSibling;
        map.maparea[r][c].Visible := StrToBool(Visible.TextContent);
        Occupied := Visible.NextSibling;
        map.maparea[r][c].Occupied := StrToBool(Occupied.TextContent);
        Discovered := Occupied.NextSibling;
        map.maparea[r][c].Discovered := StrToBool(Occupied.TextContent);
        GlyphNode := Discovered.NextSibling;
        (* Convert String to Char *)
        map.maparea[r][c].Glyph := GlyphNode.TextContent[1];

        NextNode := Tile.NextSibling;
        Tile := NextNode;
      end;
    end;

    (* Player info *)
    PlayerNode := Doc.DocumentElement.FindNode('Player');
    player.ThePlayer.currentHP   := StrToInt(PlayerNode.FindNode('currentHP').TextContent);
    player.ThePlayer.posX        := StrToInt(PlayerNode.FindNode('posX').TextContent);
    player.ThePlayer.posY        := StrToInt(PlayerNode.FindNode('posY').TextContent);
    player.ThePlayer.maxHP       := StrToInt(PlayerNode.FindNode('maxHP').TextContent);
    player.ThePlayer.attack      := StrToInt(PlayerNode.FindNode('attack').TextContent);
    player.ThePlayer.defense     := StrToInt(PlayerNode.FindNode('defense').TextContent);
    player.ThePlayer.visionRange := StrToInt(PlayerNode.FindNode('visionRange').TextContent);

    (* NPC stats *)
    SetLength(entities.entityList, 1);
    NPCnode := Doc.DocumentElement.FindNode('NPC');
    for i := 1 to entities.npcAmount do
    begin
      entities.listLength := length(entities.entityList);
      SetLength(entities.entityList, entities.listLength + 1);
      entities.entityList[i].npcID :=
        StrToInt(NPCnode.Attributes.Item[0].NodeValue);
      entities.entityList[i].race        := NPCnode.FindNode('race').TextContent;
      entities.entityList[i].description := NPCnode.FindNode('description').TextContent;
      entities.entityList[i].glyph       := Char(WideChar(NPCnode.FindNode('glyph').TextContent[1]));
      entities.entityList[i].glyphColour := StrToInt(NPCnode.FindNode('glyphColour').TextContent);
      entities.entityList[i].currentHP   := StrToInt(NPCnode.FindNode('currentHP').TextContent);
      entities.entityList[i].attack      := StrToInt(NPCnode.FindNode('attack').TextContent);
      entities.entityList[i].defense     := StrToInt(NPCnode.FindNode('defense').TextContent);
      entities.entityList[i].inView      := StrToBool(NPCnode.FindNode('inView').TextContent);
      entities.entityList[i].discovered  := StrToBool(NPCnode.FindNode('discovered').TextContent);
      entities.entityList[i].isDead      := StrToBool(NPCnode.FindNode('isDead').TextContent);
      entities.entityList[i].posX        := StrToInt(NPCnode.FindNode('posX').TextContent);
      entities.entityList[i].posY        := StrToInt(NPCnode.FindNode('posY').TextContent);
      ParentNode := NPCnode.NextSibling;
      NPCnode := ParentNode;
    end;
  finally
    (* free memory *)
    Doc.Free;
  end;
end;

end.
