unit uXmlDocumentMsXmlAdapter;

interface

uses
  MSXML, uIXmlNode, uXmlCommon, uIXmlDocument, System.SysUtils;

type
  TXmlDocumentMsXmlAdapter = class(TInterfacedObject, IXmlDocument)
  private
    FDomDocument: IXMLDOMDocument;
  public
    constructor Create;
    function LoadFromFile(const AFileName: string): Boolean;
    function GetRoot: IXmlNode;
    function AsText: string;

    procedure SaveToFile(const AFileName: string);
    function SaveToString: string;

    procedure CreateEmpty(const ARootName: string = 'root');
  end;

implementation

uses
  uXmlNodeMsXmlAdapter;

constructor TXmlDocumentMsXmlAdapter.Create;
begin
  inherited Create;
  FDomDocument := CoDOMDocument.Create;
  FDomDocument.async := False;
  FDomDocument.validateOnParse := False;
  FDomDocument.resolveExternals := False;
end;

function TXmlDocumentMsXmlAdapter.LoadFromFile(const AFileName: string): Boolean;
begin
  if not FileExists(AFileName) then
    Exit(False);

  Result := FDomDocument.load(AFileName);
  if not Result then
    raise Exception.CreateFmt('Error loading XML file: %s', [AFileName]);
end;

function TXmlDocumentMsXmlAdapter.GetRoot: IXmlNode;
begin
  Result := nil;
  if Assigned(FDomDocument) and Assigned(FDomDocument.documentElement) then
    Result := TXmlNodeMsXmlAdapter.Create(FDomDocument.documentElement);
end;

function TXmlDocumentMsXmlAdapter.AsText: string;
begin
  Result := FDomDocument.xml;
end;

procedure TXmlDocumentMsXmlAdapter.SaveToFile(const AFileName: string);
begin
  if Assigned(FDomDocument) then
    FDomDocument.save(AFileName);
end;

function TXmlDocumentMsXmlAdapter.SaveToString: string;
begin
  Result := FDomDocument.xml;
end;

procedure TXmlDocumentMsXmlAdapter.CreateEmpty(const ARootName: string);
var
  Root: IXMLDOMElement;
begin
  FDomDocument.loadXML('<?xml version="1.0"?><' + ARootName + '/>');
  Root := FDomDocument.documentElement;
  if not Assigned(Root) then
    raise Exception.Create('Failed to create root element.');
end;

end.

