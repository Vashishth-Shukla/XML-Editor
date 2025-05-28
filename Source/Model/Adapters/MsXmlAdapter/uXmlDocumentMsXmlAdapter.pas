unit uXmlDocumentMsXmlAdapter;

interface

uses
  MSXML,                   // For IXMLDOMDocument and related interfaces
  System.Classes,          // For TStream, TMemoryStream
  Winapi.ActiveX,          // For TStreamAdapter and IStream (for stream operations)
  ComObj,                  // For CoDOMDocument (creating the MSXML object)
  System.Generics.Collections, // For TList<T>
  System.SysUtils,         // For general utilities and exceptions
  System.Rtti,             // For GetEnumName function (used in CreateNode for debug/error info)
  uIXmlDocument,           // Our IXmlDocument interface definition
  uIXmlNode,               // Our IXmlNode interface definition
  uIXmlAttribute,          // Our IXmlAttribute interface definition
  uXmlCommon,              // Common types like TXmlNodeType and EXmlAdapterException
  uXmlNodeMsXmlAdapter,    // Adapter for IXmlNode (for unwrapping/wrapping IXmlNode)
  uXmlAttributeMsXmlAdapter, // Adapter for IXmlAttribute (for unwrapping/wrapping IXmlAttribute)
  TypInfo;                 // For GetEnumName

type
  // Adapter class to wrap an MSXML IXMLDOMDocument and expose it as our IXmlDocument interface.
  TXmlDocumentMsXmlAdapter = class(TInterfacedObject, IXmlDocument)
  private
    FDoc: IXMLDOMDocument; // The underlying MSXML DOM Document object

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

    // Helper to initialize FDoc (common to constructors and load methods if FDoc is nil)
    procedure EnsureDocumentCreated;

    // Helper to map our TXmlNodeType to MSXML's DOMNodeType
    function ConvertToMsXmlNodeType(const ANodeType: TXmlNodeType): LongWord;
  public
    // Constructor to create the adapter from an existing MSXML document (e.g., from another source)
    constructor Create(const ADoc: IXMLDOMDocument = nil); overload;
    // Destructor to free resources and COM references
    destructor Destroy; override;

    // Property for easier access to the Root as defined by IXmlDocument
    property Root: IXmlNode read GetRoot;
  end;

implementation

{ TXmlDocumentMsXmlAdapter }

procedure TXmlDocumentMsXmlAdapter.EnsureDocumentCreated;
begin
  if not Assigned(FDoc) then
  begin
    FDoc := CoDOMDocument.Create; // Create a new MSXML DOM Document instance
    // Set properties for reliable parsing/loading
    FDoc.async := False;          // Ensure synchronous loading for immediate error checking
    FDoc.preserveWhiteSpace := True; // Maintain whitespace nodes (important for text content)
  end;
end;

function TXmlDocumentMsXmlAdapter.ConvertToMsXmlNodeType(const ANodeType: TXmlNodeType): LongWord;
begin
  // Maps our TXmlNodeType enum to MSXML's DOMNodeType constants
  case ANodeType of
    xntElement: Result := NODE_ELEMENT;
    xntAttribute: Result := NODE_ATTRIBUTE;
    xntText: Result := NODE_TEXT;
    xntCData: Result := NODE_CDATA_SECTION;
    xntEntityRef: Result := NODE_ENTITY_REFERENCE;
    xntEntity: Result := NODE_ENTITY;
    xntProcessingInstruction: Result := NODE_PROCESSING_INSTRUCTION;
    xntComment: Result := NODE_COMMENT;
    xntDocument: Result := NODE_DOCUMENT;
    xntDocumentType: Result := NODE_DOCUMENT_TYPE;
    xntDocumentFragment: Result := NODE_DOCUMENT_FRAGMENT;
    xntNotation: Result := NODE_NOTATION;
  else
    // Default to unknown if type is not recognized (though our enum should cover all)
    Result := 0; // Or raise an exception for unhandled types
  end;
end;

constructor TXmlDocumentMsXmlAdapter.Create(const ADoc: IXMLDOMDocument);
begin
  inherited Create; // Initialize TInterfacedObject
  if Assigned(ADoc) then
    FDoc := ADoc
  else
    EnsureDocumentCreated; // Create a new document if none provided
end;

destructor TXmlDocumentMsXmlAdapter.Destroy;
begin
  FDoc := nil; // Release the COM interface reference
  inherited Destroy;
end;

function TXmlDocumentMsXmlAdapter.CreateAttribute(const AName: string; const AValue: string): IXmlAttribute;
var
  NewDOMAttr: IXMLDOMAttribute;
begin
  Result := nil;
  EnsureDocumentCreated; // Ensure FDoc exists before creating an attribute

  try
    // Create a new attribute node using the document's createAttribute method
    NewDOMAttr := FDoc.createAttribute(AName);
    NewDOMAttr.nodeValue := AValue; // Set the attribute's value
    Result := TXmlAttributeMsXmlAdapter.Create(NewDOMAttr) as IXmlAttribute;
  except
    on E: Exception do
      raise EXmlAdapterException.CreateFmt('Failed to create XML attribute "%s": %s', [AName, E.Message]);
  end;
end;

function TXmlDocumentMsXmlAdapter.CreateNew(const ARootElementName: string): IXmlNode;
var
  RootElement: IXMLDOMElement;
begin
  EnsureDocumentCreated; // Ensure FDoc exists for creating a new document structure

  // Clear any existing content
  if Assigned(FDoc.documentElement) then
    FDoc.removeChild(FDoc.documentElement);

  // Create the root element for the new document
  RootElement := FDoc.createElement(ARootElementName);
  FDoc.appendChild(RootElement); // Append it to the document

  Result := TXmlNodeMsXmlAdapter.Create(RootElement) as IXmlNode;
end;

function TXmlDocumentMsXmlAdapter.CreateNode(const AName: string; ANodeType: TXmlNodeType): IXmlNode;
var
  NewDOMNode: IXMLDOMNode;
  MSXMLNodeType: LongWord;
begin
  Result := nil;
  EnsureDocumentCreated; // Ensure FDoc exists

  MSXMLNodeType := ConvertToMsXmlNodeType(ANodeType);

  // For nodes like Text, Comment, CDATA, Name and NamespaceURI are often empty or ignored
  // MSXML's createNode signature varies slightly based on type and version.
  // We'll use the most generic one and handle specific needs afterwards.
  try
    case ANodeType of
      xntElement: NewDOMNode := FDoc.createNode(MSXMLNodeType, AName, '');
      xntText: NewDOMNode := FDoc.createTextNode(''); // Text nodes don't use 'name' in createNode
      xntComment: NewDOMNode := FDoc.createComment(''); // Comments don't use 'name'
      xntCData: NewDOMNode := FDoc.createCDATASection(''); // CDATA don't use 'name'
      xntProcessingInstruction: NewDOMNode := FDoc.createProcessingInstruction(AName, ''); // Name is target for PI
      // For other types, createNode signature might vary or they might not be directly creatable this way
      else
        raise EXmlAdapterException.CreateFmt('Unsupported XML Node Type for direct creation: %s', [GetEnumName(TypeInfo(TXmlNodeType), Ord(ANodeType))]);
    end;

    if Assigned(NewDOMNode) then
      Result := TXmlNodeMsXmlAdapter.Create(NewDOMNode) as IXmlNode;
  except
    on E: Exception do
      raise EXmlAdapterException.CreateFmt('Failed to create XML node "%s" (Type: %s): %s', [AName, GetEnumName(TypeInfo(TXmlNodeType), Ord(ANodeType)), E.Message]);
  end;
end;

function TXmlDocumentMsXmlAdapter.CreateNode(const AName: string; const AValue: string; ANodeType: TXmlNodeType): IXmlNode;
begin
  // This overload delegates to the primary CreateNode and then sets the value.
  Result := CreateNode(AName, ANodeType);
  if Assigned(Result) then
    Result.Value := AValue; // Use the IXmlNode.Value setter to apply the value
end;

function TXmlDocumentMsXmlAdapter.GetRoot: IXmlNode;
begin
  Result := nil;
  // The root node is the document element (the top-level XML tag)
  if Assigned(FDoc) and Assigned(FDoc.documentElement) then
    Result := TXmlNodeMsXmlAdapter.Create(FDoc.documentElement) as IXmlNode;
end;

function TXmlDocumentMsXmlAdapter.LoadFromFile(const AFilePath: string): Boolean;
var
  LoadResult: WordBool;
begin
  EnsureDocumentCreated; // Ensure FDoc exists

  // Load the XML from a file. MSXML returns True on success, False on error.
  LoadResult := FDoc.load(AFilePath);
  Result := LoadResult; // Set the boolean result

  // Check for parsing errors after loading
  if not LoadResult and (FDoc.parseError.errorCode <> 0) then
    raise EXmlAdapterException.Create(Format('XML parsing error loading from file "%s": %s (Line: %d, Position: %d)',
      [AFilePath, FDoc.parseError.reason, FDoc.parseError.line, FDoc.parseError.linepos]));
end;

function TXmlDocumentMsXmlAdapter.LoadFromString(const AXmlString: string): Boolean;
var
  LoadResult: WordBool;
begin
  EnsureDocumentCreated; // Ensure FDoc exists

  // Load the XML string. MSXML returns True on success, False on error.
  LoadResult := FDoc.loadXML(AXmlString);
  Result := LoadResult; // Set the boolean result

  // Check for parsing errors
  if not LoadResult and (FDoc.parseError.errorCode <> 0) then
    raise EXmlAdapterException.Create(Format('XML parsing error loading from string: %s (Line: %d, Position: %d)',
      [FDoc.parseError.reason, FDoc.parseError.line, FDoc.parseError.linepos]));
end;

function TXmlDocumentMsXmlAdapter.SaveToFile(const AFilePath: string): Boolean;
begin
  Result := False; // Default to false
  if not Assigned(FDoc) then Exit; // Nothing to save if the document object is not initialized

  try
    FDoc.save(AFilePath); // Save the XML content to a file
    Result := True; // Indicate success
  except
    on E: Exception do
      raise EXmlAdapterException.CreateFmt('Failed to save XML to file "%s": %s', [AFilePath, E.Message]);
  end;
end;

function TXmlDocumentMsXmlAdapter.SaveToString: string;
begin
  Result := '';
  if not Assigned(FDoc) then Exit; // Nothing to save if the document object is not initialized

  try
    Result := FDoc.xml; // Get the XML content as a string
  except
    on E: Exception do
      raise EXmlAdapterException.CreateFmt('Failed to convert XML to string: %s', [E.Message]);
  end;
end;

end.
