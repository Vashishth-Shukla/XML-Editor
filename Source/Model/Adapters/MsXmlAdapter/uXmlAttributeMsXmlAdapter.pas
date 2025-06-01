unit uXmlAttributeMsXmlAdapter;

interface

uses
  System.Generics.Collections, // For TList<>
  System.SysUtils,
  MSXML,                     // Defines IXMLDOMAttribute and other core MSXML interfaces
  Xml.XMLDoc,                // Provides TXMLDocument
  Xml.Win.MSXMLDOM,          // Provides more advanced MSXML interaction classes and types
  uIXmlAttribute,            // Our custom attribute interface
  uIXmlNode,                 // <--- IMPORTANT: Add our IXmlNode interface here
  uXmlCommon;                // <--- IMPORTANT: Add uXmlCommon for TXmlNodeType and EXmlAdapterException

type
  // Adapter class to wrap an MSXML IXMLDOMAttribute and expose it as our IXmlAttribute interface.
  // Now also implements IXmlNode to allow generic handling in TVirtualStringTree.
  TXmlAttributeMsXmlAdapter = class(TInterfacedObject, IXmlAttribute, IXmlNode) // <--- ADD IXmlNode here
  private
    FMsXmlAttribute: IXMLDOMAttribute; // The actual MSXML COM object for the attribute

    // IXmlAttribute interface implementation methods (already existing)
    function GetName: string;
    function GetValue: string;
    procedure SetValue(const AValue: string);

    // --- NEW: IXmlNode interface implementation methods for attributes ---
    function GetNodeName: string;
    function GetNodeValue: string;
    procedure SetNodeValue(const AValue: string);
    function GetNodeType: TXmlNodeType;
    function GetChildNodes: TList<IXmlNode>;
    function GetAttributes: TList<IXmlAttribute>;
    function AddChild(const ANode: IXmlNode): IXmlNode;
    function AddAttribute(const AAttribute: IXmlAttribute): IXmlAttribute;
    procedure RemoveChild(const ANode: IXmlNode);
    procedure RemoveAttribute(const AAttribute: IXmlAttribute);
    function GetParentNode: IXmlNode;
    procedure SetParentNode(const ANode: IXmlNode);
    // --- END NEW IXmlNode methods ---
  public
    // Constructor takes the underlying MSXML attribute
    constructor Create(const AMSXMLAttribute: IXMLDOMAttribute);
    // Destructor ensures COM interface is released
    destructor Destroy; override;
    // Exposes the raw MSXML attribute for internal use by parent adapters (e.g., TXmlNodeMsXmlAdapter)
    function GetMSXMLAttribute: IXMLDOMAttribute;
    // Properties for easier access as defined by IXmlAttribute (already existing)
    property Name: string read GetName;
    property Value: string read GetValue write SetValue;

    // --- NEW: IXmlNode properties for attributes ---
    property NodeType: TXmlNodeType read GetNodeType;
    property ChildNodes: TList<IXmlNode> read GetChildNodes;
    property Attributes: TList<IXmlAttribute> read GetAttributes;
    property Parent: IXmlNode read GetParentNode write SetParentNode;
    // --- END NEW IXmlNode properties ---
  end;

implementation

{ TXmlAttributeMsXmlAdapter }

constructor TXmlAttributeMsXmlAdapter.Create(const AMSXMLAttribute: IXMLDOMAttribute);
begin
  inherited Create;
  FMsXmlAttribute := AMSXMLAttribute;
end;

destructor TXmlAttributeMsXmlAdapter.Destroy;
begin
  FMsXmlAttribute := nil;
  inherited Destroy;
end;

function TXmlAttributeMsXmlAdapter.GetName: string;
begin
  Result := FMsXmlAttribute.nodeName;
end;

function TXmlAttributeMsXmlAdapter.GetMSXMLAttribute: IXMLDOMAttribute;
begin
  Result := FMsXmlAttribute;
end;

function TXmlAttributeMsXmlAdapter.GetValue: string;
begin
  Result := FMsXmlAttribute.nodeValue;
end;

procedure TXmlAttributeMsXmlAdapter.SetValue(const AValue: string);
begin
  FMsXmlAttribute.nodeValue := AValue;
end;

// --- NEW: IXmlNode method implementations for TXmlAttributeMsXmlAdapter ---

function TXmlAttributeMsXmlAdapter.GetNodeName: string;
begin
  // Delegate to the existing GetName from IXmlAttribute
  Result := GetName;
end;

function TXmlAttributeMsXmlAdapter.GetNodeValue: string;
begin
  // Delegate to the existing GetValue from IXmlAttribute
  Result := GetValue;
end;

procedure TXmlAttributeMsXmlAdapter.SetNodeValue(const AValue: string);
begin
  // Delegate to the existing SetValue from IXmlAttribute
  SetValue(AValue);
end;

function TXmlAttributeMsXmlAdapter.GetNodeType: TXmlNodeType;
begin
  // An attribute adapter always represents an attribute node type
  Result := xntAttribute;
end;

function TXmlAttributeMsXmlAdapter.GetChildNodes: TList<IXmlNode>;
begin
  // Attributes do not have child nodes in the XML DOM structure
  Result := TList<IXmlNode>.Create; // Return an empty list
end;

function TXmlAttributeMsXmlAdapter.GetAttributes: TList<IXmlAttribute>;
begin
  // Attributes do not have attributes themselves
  Result := TList<IXmlAttribute>.Create; // Return an empty list
end;

function TXmlAttributeMsXmlAdapter.AddChild(const ANode: IXmlNode): IXmlNode;
begin
  // This operation is not valid for an XML attribute
  raise EXmlAdapterException.Create('Cannot add child to an XML attribute.');
end;

function TXmlAttributeMsXmlAdapter.AddAttribute(const AAttribute: IXmlAttribute): IXmlAttribute;
begin
  // This operation is not valid for an XML attribute
  raise EXmlAdapterException.Create('Cannot add attribute to an XML attribute.');
end;

procedure TXmlAttributeMsXmlAdapter.RemoveChild(const ANode: IXmlNode);
begin
  // This operation is not valid for an XML attribute
  raise EXmlAdapterException.Create('Cannot remove child from an XML attribute.');
end;

procedure TXmlAttributeMsXmlAdapter.RemoveAttribute(const AAttribute: IXmlAttribute);
begin
  // This operation is not valid for an XML attribute
  raise EXmlAdapterException.Create('Cannot remove attribute from an XML attribute.');
end;

function TXmlAttributeMsXmlAdapter.GetParentNode: IXmlNode;
begin
  // The parent of an attribute is the element it belongs to.
  // MSXML attributes don't directly expose their parent *element* as an IXMLDOMNode.
  // This connection is typically managed by the element adapter (TXmlNodeMsXmlAdapter).
  // For simplicity and to avoid circular dependencies/complex lookup here, we can return nil.
  // The TVirtualStringTree typically builds children from the parent, so this might not be critical for display.
  Result := nil;
end;

procedure TXmlAttributeMsXmlAdapter.SetParentNode(const ANode: IXmlNode);
begin
  // Parent relationship for attributes is managed by the element, not set on the attribute itself.
end;

// --- END NEW IXmlNode methods ---

end.
