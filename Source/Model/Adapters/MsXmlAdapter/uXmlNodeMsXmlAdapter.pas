unit uXmlNodeMsXmlAdapter;

interface

uses
  MSXML, uIXmlNode, uXmlCommon, System.SysUtils, System.Variants;

type
  TXmlNodeMsXmlAdapter = class(TInterfacedObject, IXmlNode)
  private
    FDomNode: IXMLDOMNode;
  public
    constructor Create(ADomNode: IXMLDOMNode);

    function NodeName: string;
    function NodeValue: string;
    procedure SetNodeValue(const Value: string);
    function NodeType: TXmlNodeType;

    function HasChildNodes: Boolean;
    function ChildNodeCount: Integer;
    function ChildNodes(Index: Integer): IXmlNode;

    function HasAttributes: Boolean;
    function AttributeCount: Integer;
    function Attributes(Index: Integer): IXmlNode;

    function AsText: string;
    procedure AppendChild(const ANode: IXmlNode);

    procedure InsertBefore(const ANode: IXmlNode); overload;
    procedure InsertAfter(const ANode: IXmlNode); overload;
    procedure InsertBefore(const NewChild, RefChild: IXmlNode); overload;
    procedure InsertAfter(const NewChild, RefChild: IXmlNode); overload;

    procedure Remove;
    function ParentNode: IXmlNode;
    function CreateChild(NodeType: TXmlNodeType; const Name, Value: string): IXmlNode;
  end;

implementation

constructor TXmlNodeMsXmlAdapter.Create(ADomNode: IXMLDOMNode);
begin
  inherited Create;
  FDomNode := ADomNode;
end;

function TXmlNodeMsXmlAdapter.NodeName: string;
begin
  if Assigned(FDomNode) then
    Result := FDomNode.nodeName
  else
    Result := '';
end;

function TXmlNodeMsXmlAdapter.NodeValue: string;
begin
  if Assigned(FDomNode) and not VarIsClear(FDomNode.nodeValue) and not VarIsNull(FDomNode.nodeValue) then
    Result := VarToStr(FDomNode.nodeValue)
  else
    Result := '';
end;

procedure TXmlNodeMsXmlAdapter.SetNodeValue(const Value: string);
begin
  if Assigned(FDomNode) then
    FDomNode.nodeValue := Value;
end;

function TXmlNodeMsXmlAdapter.NodeType: TXmlNodeType;
begin
  if not Assigned(FDomNode) then
    Exit(xntUnknown);

  case FDomNode.nodeType of
    NODE_ELEMENT: Result := xntElement;
    NODE_ATTRIBUTE: Result := xntAttribute;
    NODE_TEXT: Result := xntText;
    NODE_CDATA_SECTION: Result := xntCData;
    NODE_COMMENT: Result := xntComment;
    NODE_PROCESSING_INSTRUCTION: Result := xntProcessingInstruction;
    NODE_DOCUMENT: Result := xntDocument;
    NODE_DOCUMENT_TYPE: Result := xntDocumentType;
    NODE_ENTITY_REFERENCE: Result := xntEntityRef;
    NODE_NOTATION: Result := xntNotation;
  else
    Result := xntUnknown;
  end;
end;

function TXmlNodeMsXmlAdapter.HasChildNodes: Boolean;
begin
  Result := Assigned(FDomNode) and FDomNode.hasChildNodes;
end;

function TXmlNodeMsXmlAdapter.ChildNodeCount: Integer;
begin
  if Assigned(FDomNode) and Assigned(FDomNode.childNodes) then
    Result := FDomNode.childNodes.length
  else
    Result := 0;
end;

function TXmlNodeMsXmlAdapter.ChildNodes(Index: Integer): IXmlNode;
begin
  Result := nil;
  if Assigned(FDomNode) and (Index >= 0) and (Index < ChildNodeCount) then
    Result := TXmlNodeMsXmlAdapter.Create(FDomNode.childNodes.item[Index]);
end;

function TXmlNodeMsXmlAdapter.HasAttributes: Boolean;
begin
  Result := Assigned(FDomNode) and Assigned(FDomNode.attributes) and (FDomNode.attributes.length > 0);
end;

function TXmlNodeMsXmlAdapter.AttributeCount: Integer;
begin
  if Assigned(FDomNode) and Assigned(FDomNode.attributes) then
    Result := FDomNode.attributes.length
  else
    Result := 0;
end;

function TXmlNodeMsXmlAdapter.Attributes(Index: Integer): IXmlNode;
var
  AttrNode: IXMLDOMNode;
begin
  Result := nil;
  if Assigned(FDomNode) and Assigned(FDomNode.attributes) then
  begin
    AttrNode := FDomNode.attributes.item[Index];
    if Assigned(AttrNode) then
      Result := TXmlNodeMsXmlAdapter.Create(AttrNode);
  end;
end;

function TXmlNodeMsXmlAdapter.AsText: string;
begin
  if Assigned(FDomNode) then
    Result := FDomNode.xml
  else
    Result := '';
end;

procedure TXmlNodeMsXmlAdapter.AppendChild(const ANode: IXmlNode);
var
  SourceAdapter: TXmlNodeMsXmlAdapter;
  NewDom: IXMLDOMNode;
begin
  if not Assigned(FDomNode) then Exit;

  if ANode is TXmlNodeMsXmlAdapter then
  begin
    SourceAdapter := TXmlNodeMsXmlAdapter(ANode);
    NewDom := SourceAdapter.FDomNode.cloneNode(True);
    if NewDom.nodeType = NODE_ATTRIBUTE then
    begin
      if (FDomNode.nodeType = NODE_ELEMENT) then
        (FDomNode as IXMLDOMElement).setAttribute(NewDom.nodeName, NewDom.nodeValue);
    end
    else
    begin
      FDomNode.appendChild(NewDom);
    end;

  end;
end;

procedure TXmlNodeMsXmlAdapter.InsertBefore(const ANode: IXmlNode);
var
  ParentNode: IXMLDOMNode;
  CloneDom: IXMLDOMNode;
  SourceAdapter: TXmlNodeMsXmlAdapter;
begin
  if not Assigned(FDomNode) then Exit;

  ParentNode := FDomNode.parentNode;
  if Assigned(ParentNode) and (ANode is TXmlNodeMsXmlAdapter) then
  begin
    SourceAdapter := TXmlNodeMsXmlAdapter(ANode);
    CloneDom := SourceAdapter.FDomNode.cloneNode(True);
    ParentNode.insertBefore(CloneDom, FDomNode);
  end;
end;

procedure TXmlNodeMsXmlAdapter.InsertAfter(const ANode: IXmlNode);
var
  ParentNode, SiblingNode, CloneDom: IXMLDOMNode;
  SourceAdapter: TXmlNodeMsXmlAdapter;
begin
  if not Assigned(FDomNode) then Exit;

  ParentNode := FDomNode.parentNode;
  if Assigned(ParentNode) and (ANode is TXmlNodeMsXmlAdapter) then
  begin
    SourceAdapter := TXmlNodeMsXmlAdapter(ANode);
    CloneDom := SourceAdapter.FDomNode.cloneNode(True);
    SiblingNode := FDomNode.nextSibling;
    if Assigned(SiblingNode) then
      ParentNode.insertBefore(CloneDom, SiblingNode)
    else
      ParentNode.appendChild(CloneDom);
  end;
end;

procedure TXmlNodeMsXmlAdapter.InsertBefore(const NewChild, RefChild: IXmlNode);
var
  Parent, RefDom, NewDom: IXMLDOMNode;
  SrcNew, SrcRef: TXmlNodeMsXmlAdapter;
begin
  if (NewChild is TXmlNodeMsXmlAdapter) and (RefChild is TXmlNodeMsXmlAdapter) then
  begin
    SrcNew := TXmlNodeMsXmlAdapter(NewChild);
    SrcRef := TXmlNodeMsXmlAdapter(RefChild);
    RefDom := SrcRef.FDomNode;
    NewDom := SrcNew.FDomNode.cloneNode(True);

    Parent := RefDom.parentNode;
    if Assigned(Parent) then
      Parent.insertBefore(NewDom, RefDom);
  end;
end;

procedure TXmlNodeMsXmlAdapter.InsertAfter(const NewChild, RefChild: IXmlNode);
var
  Parent, RefDom, Sibling, NewDom: IXMLDOMNode;
  SrcNew, SrcRef: TXmlNodeMsXmlAdapter;
begin
  if (NewChild is TXmlNodeMsXmlAdapter) and (RefChild is TXmlNodeMsXmlAdapter) then
  begin
    SrcNew := TXmlNodeMsXmlAdapter(NewChild);
    SrcRef := TXmlNodeMsXmlAdapter(RefChild);
    RefDom := SrcRef.FDomNode;
    NewDom := SrcNew.FDomNode.cloneNode(True);

    Parent := RefDom.parentNode;
    if Assigned(Parent) then
    begin
      Sibling := RefDom.nextSibling;
      if Assigned(Sibling) then
        Parent.insertBefore(NewDom, Sibling)
      else
        Parent.appendChild(NewDom);
    end;
  end;
end;

procedure TXmlNodeMsXmlAdapter.Remove;
var
  Parent: IXMLDOMNode;
begin
  if Assigned(FDomNode) and Assigned(FDomNode.parentNode) then
  begin
    Parent := FDomNode.parentNode;
    Parent.removeChild(FDomNode);
  end;
end;

function TXmlNodeMsXmlAdapter.ParentNode: IXmlNode;
begin
  Result := nil;
  if Assigned(FDomNode) and Assigned(FDomNode.parentNode) then
    Result := TXmlNodeMsXmlAdapter.Create(FDomNode.parentNode);
end;

function TXmlNodeMsXmlAdapter.CreateChild(NodeType: TXmlNodeType; const Name, Value: string): IXmlNode;
var
  Doc: IXMLDOMDocument;
  NewNode: IXMLDOMNode;
begin
  Result := nil;
  if not Assigned(FDomNode) then Exit;

  Doc := FDomNode.ownerDocument;
  if not Assigned(Doc) then Exit;

  case NodeType of
    xntElement: NewNode := Doc.createElement(Name);
    xntText: NewNode := Doc.createTextNode(Value);
    xntCData: NewNode := Doc.createCDATASection(Value);
    xntComment: NewNode := Doc.createComment(Value);
    xntProcessingInstruction: NewNode := Doc.createProcessingInstruction(Name, Value);
    xntAttribute: NewNode := Doc.createAttribute(Name);
  else
    Exit;
  end;

  if Assigned(NewNode) then
  begin
    if NodeType in [xntElement, xntAttribute] then
      NewNode.nodeValue := Value;
    Result := TXmlNodeMsXmlAdapter.Create(NewNode);
  end;
end;

end.

