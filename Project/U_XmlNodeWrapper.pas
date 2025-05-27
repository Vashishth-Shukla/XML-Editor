unit XmlNodeWrapper;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLDoc, Xml.XMLIntf, IXmlNode;

type
  TXmlNodeWrapper = class(TInterfacedObject, IXmlNode)
  private
    FNode: IXMLNode;
  public
    constructor Create(const ANode: IXMLNode);
    function GetName: string;
    function GetValue: string;
    procedure SetValue(const AValue: string);
    function GetChildNodes: TArray<IXmlNode>;
    function AddChild(const AName: string): IXmlNode;
    procedure RemoveChild(const AName: string);
  end;

implementation

{ TXmlNodeWrapper }

constructor TXmlNodeWrapper.Create(const ANode: IXMLNode);
begin
  inherited Create;
  FNode := ANode;
end;

function TXmlNodeWrapper.GetName: string;
begin
  Result := FNode.NodeName;
end;

function TXmlNodeWrapper.GetValue: string;
begin
  Result := FNode.Text;
end;

procedure TXmlNodeWrapper.SetValue(const AValue: string);
begin
  FNode.Text := AValue;
end;

function TXmlNodeWrapper.GetChildNodes: TArray<IXmlNode>;
var
  i: Integer;
  Children: TArray<IXmlNode>;
begin
  SetLength(Children, FNode.ChildNodes.Count);
  for i := 0 to FNode.ChildNodes.Count - 1 do
    Children[i] := TXmlNodeWrapper.Create(FNode.ChildNodes[i]);
  Result := Children;
end;

function TXmlNodeWrapper.AddChild(const AName: string): IXmlNode;
var
  NewNode: IXMLNode;
begin
  NewNode := FNode.AddChild(AName);
  Result := TXmlNodeWrapper.Create(NewNode);
end;

procedure TXmlNodeWrapper.RemoveChild(const AName: string);
var
  ChildNode: IXMLNode;
begin
  ChildNode := FNode.ChildNodes.FindNode(AName);
  if Assigned(ChildNode) then
    FNode.ChildNodes.Remove(ChildNode);
end;

end.

