unit uXmlDocumentMsXmlAdapter;

interface

uses
  System.SysUtils,
  System.Variants,       // Provides the VarToBoolean function for converting OleVariant results
  System.Rtti,           // Provides GetEnumName for getting string names of enum values (e.g., for error messages)
  Winapi.Windows,        // Provides OutputDebugString for debugging output
  MSXML,                 // The primary unit for MSXML COM interfaces like IXMLDOMDocument
  uIXmlDocument,         // Our custom interface for XML documents
  uIXmlNode,             // Our custom interface for XML nodes
  uIXmlAttribute,        // Our custom interface for XML attributes
  uXmlNodeMsXmlAdapter,  // Concrete adapter for MSXML nodes
  uXmlAttributeMsXmlAdapter, // Concrete adapter for MSXML attributes
  TypInfo;

type
  TXmlDocumentMsXmlAdapter = class(TInterfacedObject, IXmlDocument)
  private
    FMsXmlDocument: IXMLDOMDocument; // The actual underlying MSXML document object
    FRootNode: IXmlNode;             // Cache for the wrapped root node for quick access

    // IXmlDocument interface implementation methods
    function LoadFromFile(const AFilePath: string): Boolean;
    function LoadFromString(const AXmlString: string): Boolean;
    function SaveToFile(const AFilePath: string): Boolean;
    function SaveToString: string;
    function CreateNew(const ARootElementName: string): IXmlNode; // Creates a new XML document with a root element
    function GetRoot: IXmlNode; // Retrieves the root element of the document
    function CreateNode(const AName: string; ANodeType: TXmlNodeType = xntElement): IXmlNode; overload; // Factory method for creating new nodes
    function CreateNode(const AName: string; const AValue: string; ANodeType: TXmlNodeType = xntElement): IXmlNode; overload; // Overloaded factory for nodes with initial values
    function CreateAttribute(const AName: string; const AValue: string): IXmlAttribute; // Factory method for creating new attributes

  public
    // Constructor to initialize the adapter (the MSXML document object is created on demand)
    constructor Create;
    // Destructor to ensure COM objects are released
    destructor Destroy; override;

    // Optional: Expose the raw MSXML document if direct access is ever needed,
    // though generally avoided for maintaining abstraction.
    function GetMSXMLDocument: IXMLDOMDocument;
  end;

implementation

{ TXmlDocumentMsXmlAdapter }

function TXmlDocumentMsXmlAdapter.CreateAttribute(const AName: string; const AValue: string): IXmlAttribute;
var
  MsXmlAttribute: IXMLDOMAttribute;
begin
  if not Assigned(FMsXmlDocument) then
    raise Exception.Create('MSXML document not initialized. Call CreateNew or Load methods first.');

  // Create the attribute using the MSXML document's factory method
  MsXmlAttribute := FMsXmlDocument.createAttribute(AName);
  MsXmlAttribute.nodeValue := AValue;

  // Wrap the MSXML attribute with our adapter to return our generic interface
  Result := TXmlAttributeMsXmlAdapter.Create(MsXmlAttribute);
end;

function TXmlDocumentMsXmlAdapter.CreateNew(const ARootElementName: string): IXmlNode;
var
  MsXmlRootElement: IXMLDOMElement;
  MsXmlDeclaration: IXMLDOMProcessingInstruction;
begin
  // Clear any existing document and cached root node
  FMsXmlDocument := nil;
  FRootNode := nil;

  // Create a new MSXMLDOMDocument object (using MSXML 6.0 which is standard on modern Windows)
  FMsXmlDocument := CoDOMDocument60.Create;
  FMsXmlDocument.async := False; // Ensure synchronous loading/saving operations

  // Add the XML Declaration (e.g., <?xml version="1.0"?>)
  // This is handled as a processing instruction by MSXML.
  MsXmlDeclaration := FMsXmlDocument.createProcessingInstruction('xml', 'version="1.0"');
  FMsXmlDocument.appendChild(MsXmlDeclaration);

  // Create and append the specified root element
  MsXmlRootElement := FMsXmlDocument.createElement(ARootElementName);
  FMsXmlDocument.appendChild(MsXmlRootElement);

  // Wrap the newly created MSXML root element with our generic adapter and cache it
  FRootNode := TXmlNodeMsXmlAdapter.Create(MsXmlRootElement);
  Result := FRootNode;
end;

function TXmlDocumentMsXmlAdapter.CreateNode(const AName: string; ANodeType: TXmlNodeType): IXmlNode;
var
  MsXmlNode: IXMLDOMNode;
  NodeKind: DOMNodeType;
begin
  if not Assigned(FMsXmlDocument) then
    raise Exception.Create('MSXML document not initialized. Call CreateNew or Load methods first.');

  // Convert our custom TXmlNodeType enum to MSXML's specific DOMNodeType
  case ANodeType of
    xntElement: NodeKind := NODE_ELEMENT;
    xntText: NodeKind := NODE_TEXT;
    xntCData: NodeKind := NODE_CDATA_SECTION;
    xntComment: NodeKind := NODE_COMMENT;
    xntProcessingInstruction: NodeKind := NODE_PROCESSING_INSTRUCTION;
    // xntAttribute is handled by CreateAttribute.
    // xntDeclaration is intentionally excluded from our TXmlNodeType for simplification.
    else
      // Use GetEnumName for a descriptive error message if an unsupported type is passed
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
  // Create the node, then set its value using the IXmlNode interface
  NewNode := CreateNode(AName, ANodeType);
  if Assigned(NewNode) then
    NewNode.Value := AValue;
  Result := NewNode;
end;

constructor TXmlDocumentMsXmlAdapter.Create;
begin
  inherited Create;
  // FMsXmlDocument is initialized in CreateNew or Load methods, not here.
end;

destructor TXmlDocumentMsXmlAdapter.Destroy;
begin
  // Release COM object and cached root node to prevent memory leaks
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
  // If the root node hasn't been cached yet, attempt to get and wrap it from the MSXML document
  if not Assigned(FRootNode) and Assigned(FMsXmlDocument) then
  begin
    // The documentElement property holds the single root element of the XML document
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
  FMsXmlDocument := CoDOMDocument60.Create;
  FMsXmlDocument.async := False; // Ensure synchronous loading

  // Load the XML from the specified file path
  LoadResult := FMsXmlDocument.load(AFilePath);
  // Convert the OleVariant result to a Delphi Boolean using VarToBoolean
  Result := VarAsType(LoadResult, varBoolean);

  // If successfully loaded, clear any old cached root node to ensure it's rebuilt from the new document
  FRootNode := nil;
end;

function TXmlDocumentMsXmlAdapter.LoadFromString(const AXmlString: string): Boolean;
var
  LoadResult: OleVariant;
begin
  // Create a new MSXMLDOMDocument object for each load operation
  FMsXmlDocument := CoDOMDocument60.Create;
  FMsXmlDocument.async := False; // Ensure synchronous loading

  // Load the XML from the provided string
  LoadResult := FMsXmlDocument.loadXML(AXmlString);
  // Convert the OleVariant result to a Delphi Boolean using VarToBoolean
  Result := VarAsType(LoadResult, varBoolean);

  // If successfully loaded, clear any old cached root node to ensure it's rebuilt from the new document
  FRootNode := nil;
end;

function TXmlDocumentMsXmlAdapter.SaveToFile(const AFilePath: string): Boolean;
begin
  Result := False;
  if Assigned(FMsXmlDocument) then
  try
    // Save the XML document to the specified file path
    FMsXmlDocument.save(AFilePath);
    Result := True;
  except
    on E: Exception do
      // Log any errors during saving for debugging purposes
      OutputDebugString(PChar('Error saving XML to file: ' + E.Message));
  end;
end;

function TXmlDocumentMsXmlAdapter.SaveToString: string;
begin
  if Assigned(FMsXmlDocument) then
    // Return the XML content as a string
    Result := FMsXmlDocument.xml
  else
    Result := '';
end;

end.
