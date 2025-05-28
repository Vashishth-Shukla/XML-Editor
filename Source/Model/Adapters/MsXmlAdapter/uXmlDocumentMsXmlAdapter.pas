unit uXmlDocumentMsXmlAdapter;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Rtti,
  Winapi.Windows,
  // --- End of core system units ---
  MSXML,
  uIXmlDocument,
  uIXmlNode,
  uIXmlAttribute,
  uXmlNodeMsXmlAdapter,
  uXmlAttributeMsXmlAdapter;

type
  TXmlDocumentMsXmlAdapter = class(TInterfacedObject, IXmlDocument)
  private
    FMsXmlDocument: IXMLDOMDocument; // The actual underlying MSXML document object
    FRootNode: IXmlNode;             // Cache for the wrapped root node

    // IXmlDocument interface implementation methods
    function LoadFromFile(const AFilePath: string): Boolean;
    function LoadFromString(const AXmlString: string): Boolean;
    function SaveToFile(const AFilePath: string): Boolean;
    function SaveToString: string;
    function CreateNew(const ARootElementName: string): IXmlNode;
    function GetRoot: IXmlNode;
    function CreateNode(const AName: string; ANodeType: TXmlNodeType = xntElement): IXmlNode; overload;
    function CreateNode(const AName: string; const AValue: string; ANodeType: TXmlNodeType = xntElement): IXmlNode; overload;
    function CreateAttribute(const AName: string; const AValue: string): IXmlAttribute;

  public
    // Constructor to create the adapter, initializing the MSXML document
    constructor Create;
    destructor Destroy; override;

    // Optional: Expose the raw MSXML document if direct access is ever needed (usually avoided for abstraction)
    function GetMSXMLDocument: IXMLDOMDocument;
  end;

implementation

{ TXmlDocumentMsXmlAdapter }

function TXmlDocumentMsXmlAdapter.CreateAttribute(const AName: string; const AValue: string): IXmlAttribute;
var
  MsXmlAttribute: IXMLDOMAttribute;
begin
  if not Assigned(FMsXmlDocument) then
    raise Exception.Create('MSXML document not initialized.');

  // Create the attribute node using the MSXML document's factory method
  MsXmlAttribute := FMsXmlDocument.createAttribute(AName);
  MsXmlAttribute.nodeValue := AValue;

  // Wrap the MSXML attribute with our adapter
  Result := TXmlAttributeMsXmlAdapter.Create(MsXmlAttribute);
end;

function TXmlDocumentMsXmlAdapter.CreateNew(const ARootElementName: string): IXmlNode;
var
  MsXmlRootElement: IXMLDOMElement;
  MsXmlDeclaration: IXMLDOMProcessingInstruction;
begin
  // Clear any existing document
  FMsXmlDocument := nil;
  FRootNode := nil;

  // Create a new MSXMLDOMDocument object
  FMsXmlDocument := CoDOMDocument60.Create; // Use CoDOMDocument60.Create for MSXML 6.0
  FMsXmlDocument.async := False; // Ensure synchronous loading/saving

  // Add the XML Declaration (e.g., <?xml version="1.0"?>)
  // This is a processing instruction with a specific target and data
  // Note: While we don't expose xntDeclaration in our TXmlNodeType,
  // MSXML still allows us to create and manage the declaration node directly.
  MsXmlDeclaration := FMsXmlDocument.createProcessingInstruction('xml', 'version="1.0"'); // 'xml' is the target, 'version="1.0"' is the data
  FMsXmlDocument.appendChild(MsXmlDeclaration);

  // Create and append the root element
  MsXmlRootElement := FMsXmlDocument.createElement(ARootElementName);
  FMsXmlDocument.appendChild(MsXmlRootElement);

  // Wrap the root element with our adapter and cache it
  FRootNode := TXmlNodeMsXmlAdapter.Create(MsXmlRootElement);
  Result := FRootNode;
end;

function TXmlDocumentMsXmlAdapter.CreateNode(const AName: string; ANodeType: TXmlNodeType): IXmlNode;
var
  MsXmlNode: IXMLDOMNode;
  NodeKind: DOMNodeType;
begin
  if not Assigned(FMsXmlDocument) then
    raise Exception.Create('MSXML document not initialized.');

  // Convert our custom TXmlNodeType to MSXML's DOMNodeType
  case ANodeType of
    xntElement: NodeKind := NODE_ELEMENT;
    xntText: NodeKind := NODE_TEXT;
    xntCData: NodeKind := NODE_CDATA_SECTION;
    xntComment: NodeKind := NODE_COMMENT;
    xntProcessingInstruction: NodeKind := NODE_PROCESSING_INSTRUCTION;
    // xntAttribute is handled by CreateAttribute.
    // xntDeclaration is no longer in our TXmlNodeType enum.
    else
      raise Exception.CreateFmt('Cannot create node of unsupported type: %s', [GetEnumName(TypeInfo(TXmlNodeType), Ord(ANodeType))]);
  end;

  // Create the node using the MSXML document's factory method
  MsXmlNode := FMsXmlDocument.createNode(NodeKind, AName, '');

  // Wrap the MSXML node with our adapter
  Result := TXmlNodeMsXmlAdapter.Create(MsXmlNode);
end;

function TXmlDocumentMsXmlAdapter.CreateNode(const AName: string; const AValue: string; ANodeType: TXmlNodeType): IXmlNode;
var
  NewNode: IXmlNode;
begin
  NewNode := CreateNode(AName, ANodeType);
  if Assigned(NewNode) then
    NewNode.Value := AValue;
  Result := NewNode;
end;

constructor TXmlDocumentMsXmlAdapter.Create;
begin
  inherited Create;
  // Initialize MSXMLDOMDocument here, but only really create it when
  // Load or CreateNew is called, as it needs to be recreated for each new document.
  // We can create a basic instance here to avoid nil checks in subsequent calls if preferred.
  // FMsXmlDocument := CoDOMDocument60.Create; // Can initialize here or inside Load/CreateNew
end;

destructor TXmlDocumentMsXmlAdapter.Destroy;
begin
  // Release COM object and cached root node
  FMsXmlDocument := nil;
  FRootNode := nil;
  inherited Destroy;
end;

function TXmlDocumentMsXmlAdapter.GetMSXMLDocument: IXMLDOMDocument;
begin
  Result := FMsXmlDocument;
end;

function TXmlDocumentMsXmlAdapter.GetRoot: IXmlNode;
begin
  // If the document is loaded/created, the root element should be wrapped.
  // MSXML's documentElement property gives the root element.
  if not Assigned(FRootNode) and Assigned(FMsXmlDocument) then
  begin
    if Assigned(FMsXmlDocument.documentElement) then
      FRootNode := TXmlNodeMsXmlAdapter.Create(FMsXmlDocument.documentElement);
  end;
  Result := FRootNode;
end;

function TXmlDocumentMsXmlAdapter.LoadFromFile(const AFilePath: string): Boolean;
var
  LoadResult: OleVariant;
begin
  // Create a new MSXMLDOMDocument object for each load operation
  FMsXmlDocument := CoDOMDocument60.Create; // Use MSXML 6.0
  FMsXmlDocument.async := False; // Ensure synchronous loading

  LoadResult := FMsXmlDocument.load(AFilePath);
  Result := VarToBoolean(LoadResult);

  // If successfully loaded, clear the cached root node to ensure it's rebuilt from the new document
  FRootNode := nil;
end;

function TXmlDocumentMsXmlAdapter.LoadFromString(const AXmlString: string): Boolean;
var
  LoadResult: OleVariant;
begin
  // Create a new MSXMLDOMDocument object for each load operation
  FMsXmlDocument := CoDOMDocument60.Create; // Use MSXML 6.0
  FMsXmlDocument.async := False; // Ensure synchronous loading

  LoadResult := FMsXmlDocument.loadXML(AXmlString);
  Result := VarToBoolean(LoadResult);

  // If successfully loaded, clear the cached root node to ensure it's rebuilt from the new document
  FRootNode := nil;
end;

function TXmlDocumentMsXmlAdapter.SaveToFile(const AFilePath: string): Boolean;
begin
  Result := False;
  if Assigned(FMsXmlDocument) then
  try
    FMsXmlDocument.save(AFilePath);
    Result := True;
  except
    on E: Exception do
      // Log error or handle gracefully
      OutputDebugString(PChar('Error saving XML to file: ' + E.Message));
  end;
end;

function TXmlDocumentMsXmlAdapter.SaveToString: string;
begin
  if Assigned(FMsXmlDocument) then
    Result := FMsXmlDocument.xml
  else
    Result := '';
end;

end.
