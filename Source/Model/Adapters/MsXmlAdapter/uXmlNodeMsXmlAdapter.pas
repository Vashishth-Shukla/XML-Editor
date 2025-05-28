unit uXmlNodeMsXmlAdapter;

interface

uses
  System.SysUtils, System.Generics.Collections, // Provides TList<T> and basic utilities
  MSXML,                       // Provides IXMLDOMNode, IXMLDOMElement, DOMNodeType and related constants (NODE_ELEMENT, NODE_CDATA_SECTION etc.)
  Xml.XMLDoc,                  // Provides TXMLDocument (though we're wrapping MSXML directly, sometimes needed for context)
  Xml.Win.MSXMLDOM,            // Provides specific MSXML DOM helpers (less frequently used directly in adapters here)
  uIXmlNode, uIXmlAttribute,   // Our custom interfaces for nodes and attributes (TXmlNodeType defined in uIXmlNode)
  uXmlAttributeMsXmlAdapter;   // Our concrete adapter for attributes (needed for unwrapping IXmlAttribute)

type
  TXmlNodeMsXmlAdapter = class(TInterfacedObject, IXmlNode)
  private
    FMsXmlNode: IXMLDOMNode;                 // The actual MSXML COM object for the node
    FChildNodesCache: TList<IXmlNode>;       // Cache for wrapped child nodes
    FAttributesCache: TList<IXmlAttribute>;  // Cache for wrapped attributes
    FParentNode: IXmlNode;                   // Manages parent reference for our interface layer

    // Helper methods for internal wrapping and type conversion
    function WrapChildNode(const AXMLDOMNode: IXMLDOMNode): IXmlNode;
    function WrapAttribute(const AXMLDOMAttribute: IXMLDOMAttribute): IXmlAttribute;
    function ConvertMsXmlNodeType(const ANodeType: DOMNodeType): TXmlNodeType;

    // IXmlNode interface implementation methods
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

  public
    // Constructor to create the adapter from an MSXML node
    constructor Create(const AMSXMLNode: IXMLDOMNode);
    // Destructor to free resources and COM references
    destructor Destroy; override;
    // Exposes the underlying MSXML node for document-level operations
    function GetMSXMLNode: IXMLDOMNode;

    // Properties as defined by IXmlNode interface
    property Name: string read GetNodeName;
    property Value: string read GetNodeValue write SetNodeValue;
    property NodeType: TXmlNodeType read GetNodeType;
    property ChildNodes: TList<IXmlNode> read GetChildNodes;
    property Attributes: TList<IXmlAttribute> read GetAttributes;
    property Parent: IXmlNode read GetParentNode write SetParentNode;
  end;

implementation

{ TXmlNodeMsXmlAdapter }

function TXmlNodeMsXmlAdapter.AddAttribute(const AAttribute: IXmlAttribute): IXmlAttribute;
var
  MsXmlAttr: IXMLDOMAttribute;
  AdapterAttr: TXmlAttributeMsXmlAdapter;
begin
  Result := nil;
  // Check if the current node is an element. Only elements can have attributes.
  if not Assigned(FMsXmlNode) or not (FMsXmlNode.nodeType = NODE_ELEMENT) then Exit;

  // Safely unwrap the IXmlAttribute interface to its concrete adapter class.
  // This assumes AAttribute is indeed an instance of TXmlAttributeMsXmlAdapter,
  // which should be true if we create all attributes using our factories.
  try
    AdapterAttr := AAttribute as TXmlAttributeMsXmlAdapter;
  except
    on E: EInvalidCast do // Handle if the cast fails (e.g., AAttribute is not our adapter)
    begin
      Exit; // Exit if the provided attribute is not of our expected adapter type
    end;
  end;

  MsXmlAttr := AdapterAttr.GetMSXMLAttribute; // Get the raw MSXML attribute
  (FMsXmlNode as IXMLDOMElement).setAttributeNode(MsXmlAttr); // Add it to the MSXML element

  // Clear the attributes cache to ensure it's rebuilt on next access
  if Assigned(FAttributesCache) then
    FAttributesCache.Clear;
  Result := AAttribute; // Return the same interface that was passed in
end;

function TXmlNodeMsXmlAdapter.AddChild(const ANode: IXmlNode): IXmlNode;
var
  MsXmlChild: IXMLDOMNode;
  AdapterNode: TXmlNodeMsXmlAdapter;
begin
  Result := nil;
  if not Assigned(FMsXmlNode) then Exit; // Ensure we have a valid node to add to

  // Safely unwrap the IXmlNode interface to its concrete adapter class.
  try
    AdapterNode := ANode as TXmlNodeMsXmlAdapter;
  except
    on E: EInvalidCast do
    begin
      Exit; // Exit if the provided node is not of our expected adapter type
    end;
  end;

  MsXmlChild := AdapterNode.GetMSXMLNode; // Get the raw MSXML node
  FMsXmlNode.appendChild(MsXmlChild);     // Add it as a child in the MSXML DOM

  // Clear the child nodes cache
  if Assigned(FChildNodesCache) then
    FChildNodesCache.Clear;
  // Update the parent reference of the child adapter for internal model consistency
  AdapterNode.SetParentNode(Self);
  Result := ANode; // Return the same interface that was passed in
end;

function TXmlNodeMsXmlAdapter.ConvertMsXmlNodeType(const ANodeType: DOMNodeType): TXmlNodeType;
begin
  // Maps MSXML's DOMNodeType constants (from MSXML unit) to our custom TXmlNodeType enum (from uIXmlNode unit).
  case ANodeType of
    NODE_ELEMENT: Result := xntElement;
    NODE_ATTRIBUTE: Result := xntAttribute;
    NODE_TEXT: Result := xntText;
    NODE_CDATA_SECTION: Result := xntCData;
    NODE_COMMENT: Result := xntComment;
    NODE_PROCESSING_INSTRUCTION: Result := xntProcessingInstruction;
    // NODE_XML_DECLARATION := xntDeclaration Declaration node is not mapped in MSXML or even OXML
    // If explicit handling is needed later, this case can be re-enabled.
    else Result := xntUnknown;
  end;
end;

constructor TXmlNodeMsXmlAdapter.Create(const AMSXMLNode: IXMLDOMNode);
begin
  inherited Create;
  FMsXmlNode := AMSXMLNode;
end;

destructor TXmlNodeMsXmlAdapter.Destroy;
begin
  // Free owned generic lists
  FChildNodesCache.Free;
  FAttributesCache.Free;
  // Release COM interface references
  FMsXmlNode := nil;
  FParentNode := nil;
  inherited Destroy;
end;

function TXmlNodeMsXmlAdapter.GetAttributes: TList<IXmlAttribute>;
var
  AttrList: IXMLDOMNamedNodeMap;
  I: Integer;
  MsXmlAttr: IXMLDOMAttribute;
begin
  // Initialize cache if it's not already
  if not Assigned(FAttributesCache) then
    FAttributesCache := TList<IXmlAttribute>.Create;

  // Populate cache only if it's empty (lazy loading)
  if FAttributesCache.Count = 0 then
  begin
    // Check if the node is an element and has attributes
    if Assigned(FMsXmlNode) and (FMsXmlNode.nodeType = NODE_ELEMENT) then
    begin
      AttrList := (FMsXmlNode as IXMLDOMElement).attributes; // Cast to IXMLDOMElement to access its .attributes
      if Assigned(AttrList) then // Check if attributes collection exists
      begin
        for I := 0 to AttrList.length - 1 do
        begin
          // Ensure the item retrieved from the map is indeed an attribute
          if AttrList.item[I].nodeType = NODE_ATTRIBUTE then
          begin
            MsXmlAttr := AttrList.item[I] as IXMLDOMAttribute; // Cast to IXMLDOMAttribute for specific interface methods
            FAttributesCache.Add(WrapAttribute(MsXmlAttr)); // Wrap and add to cache
          end;
        end;
      end;
    end;
  end;
  Result := FAttributesCache;
end;

function TXmlNodeMsXmlAdapter.GetChildNodes: TList<IXmlNode>;
var
  ChildNodeList: IXMLDOMNodeList;
  I: Integer;
  MsXmlChildNode: IXMLDOMNode;
  WrappedNode: IXmlNode;
begin
  // Initialize cache if it's not already
  if not Assigned(FChildNodesCache) then
    FChildNodesCache := TList<IXmlNode>.Create;

  // Populate cache only if it's empty (lazy loading)
  if FChildNodesCache.Count = 0 then
  begin
    if Assigned(FMsXmlNode) and Assigned(FMsXmlNode.childNodes) then
    begin
      ChildNodeList := FMsXmlNode.childNodes;
      for I := 0 to ChildNodeList.length - 1 do
      begin
        MsXmlChildNode := ChildNodeList.item[I];
        // Only wrap nodes that we want to expose in our abstraction.
        // The XML Declaration node (DOMNodeType 13) will now be wrapped as xntUnknown,
        // so it will still be in the ChildNodes list, but its type will be xntUnknown.
        // If we wanted to completely hide it, we'd add a check here to skip it.
        WrappedNode := WrapChildNode(MsXmlChildNode);
        FChildNodesCache.Add(WrappedNode);
        (WrappedNode as TXmlNodeMsXmlAdapter).SetParentNode(Self); // Set parent for consistency in our model
      end;
    end;
  end;
  Result := FChildNodesCache;
end;

function TXmlNodeMsXmlAdapter.GetMSXMLNode: IXMLDOMNode;
begin
  Result := FMsXmlNode;
end;

function TXmlNodeMsXmlAdapter.GetNodeName: string;
begin
  if not Assigned(FMsXmlNode) then
  begin
    Result := '';
    Exit;
  end;

  // Determine the display name based on the node type
  case ConvertMsXmlNodeType(FMsXmlNode.nodeType) of
    xntElement: Result := FMsXmlNode.nodeName;
    xntAttribute: Result := FMsXmlNode.nodeName;
    xntText: Result := '#text';       // Standard representation for text nodes
    xntComment: Result := '#comment'; // Standard representation for comment nodes
    xntCData: Result := '#cdata';     // Standard representation for CDATA nodes
    xntProcessingInstruction: Result := '?' + FMsXmlNode.nodeName; // e.g., <?xml-stylesheet?>
    // Since xntDeclaration is removed, a DOMNodeType 17 node will fall into xntUnknown.
    // We can provide a generic fallback for unknown types or specific names if needed.
    xntUnknown:
      begin
        // If it's the XML Declaration node (which we're now mapping to xntUnknown),
        // we can still give it a recognizable name based on its actual type.
        // This is a pragmatic choice to maintain some clarity even if its enum type is unknown.
        if FMsXmlNode.nodeType = 17 then // Check for the raw DOMNodeType value if known
          Result := '#xmldeclaration (unknown type)'
        else
          Result := FMsXmlNode.nodeName; // Default to nodeName for other unknown types
      end;
    else Result := FMsXmlNode.nodeName; // Fallback for any other unhandled specific type
  end;
end;

function TXmlNodeMsXmlAdapter.GetNodeValue: string;
begin
  if not Assigned(FMsXmlNode) then
  begin
    Result := '';
    Exit;
  end;

  Result := FMsXmlNode.nodeValue;
  // For element nodes, if nodeValue is empty, the 'text' property often contains
  // the concatenated text content of all descendant text nodes.
  if (ConvertMsXmlNodeType(FMsXmlNode.nodeType) = xntElement) and (Result = '') then
    Result := FMsXmlNode.text;
end;

function TXmlNodeMsXmlAdapter.GetNodeType: TXmlNodeType;
begin
  if not Assigned(FMsXmlNode) then
  begin
    Result := xntUnknown; // Return unknown if the underlying MSXML node is not assigned
    Exit;
  end;
  Result := ConvertMsXmlNodeType(FMsXmlNode.nodeType);
end;

function TXmlNodeMsXmlAdapter.GetParentNode: IXmlNode;
begin
  Result := FParentNode; // Return the parent node as managed by our adapter
end;

procedure TXmlNodeMsXmlAdapter.RemoveAttribute(const AAttribute: IXmlAttribute);
var
  MsXmlAttr: IXMLDOMAttribute;
  AdapterAttr: TXmlAttributeMsXmlAdapter;
begin
  // Only elements can have attributes removed
  if not Assigned(FMsXmlNode) or not (FMsXmlNode.nodeType = NODE_ELEMENT) then Exit;

  // Safely unwrap the IXmlAttribute interface to get the underlying MSXML attribute
  try
    AdapterAttr := AAttribute as TXmlAttributeMsXmlAdapter;
  except
    on E: EInvalidCast do
    begin
      Exit;
    end;
  end;

  MsXmlAttr := AdapterAttr.GetMSXMLAttribute;
  (FMsXmlNode as IXMLDOMElement).removeAttributeNode(MsXmlAttr); // Remove from MSXML DOM
  // Remove from our cache if it exists
  if Assigned(FAttributesCache) then
    FAttributesCache.Remove(AAttribute);
end;

procedure TXmlNodeMsXmlAdapter.RemoveChild(const ANode: IXmlNode);
var
  MsXmlChild: IXMLDOMNode;
  AdapterNode: TXmlNodeMsXmlAdapter;
begin
  if not Assigned(FMsXmlNode) then Exit; // Ensure we have a valid node to remove from

  // Safely unwrap the IXmlNode interface to get the underlying MSXML node
  try
    AdapterNode := ANode as TXmlNodeMsXmlAdapter;
  except
    on E: EInvalidCast do
    begin
      Exit;
    end;
  end;

  MsXmlChild := AdapterNode.GetMSXMLNode;
  FMsXmlNode.removeChild(MsXmlChild); // Remove from MSXML DOM
  // Remove from our cache if it exists
  if Assigned(FChildNodesCache) then
    FChildNodesCache.Remove(ANode);
  AdapterNode.SetParentNode(nil); // Detach the child from its parent reference
end;

procedure TXmlNodeMsXmlAdapter.SetNodeValue(const AValue: string);
begin
  if not Assigned(FMsXmlNode) then Exit;

  // Setting the node value depends on the node type
  case ConvertMsXmlNodeType(FMsXmlNode.nodeType) of
    xntElement: FMsXmlNode.text := AValue; // For elements, setting 'text' modifies concatenated content
    xntAttribute, xntText, xntComment, xntCData, xntProcessingInstruction:
      FMsXmlNode.nodeValue := AValue; // For these types, 'nodeValue' is directly modified
    else; // Do nothing for other node types like Document, DocumentFragment etc.
  end;
end;

procedure TXmlNodeMsXmlAdapter.SetParentNode(const ANode: IXmlNode);
begin
  FParentNode := ANode; // Update our internal parent reference for this node
end;

function TXmlNodeMsXmlAdapter.WrapAttribute(const AXMLDOMAttribute: IXMLDOMAttribute): IXmlAttribute;
begin
  // Factory method to create a new IXmlAttribute adapter from an MSXML attribute
  Result := TXmlAttributeMsXmlAdapter.Create(AXMLDOMAttribute);
end;

function TXmlNodeMsXmlAdapter.WrapChildNode(const AXMLDOMNode: IXMLDOMNode): IXmlNode;
begin
  // Factory method to create a new IXmlNode adapter from an MSXML node
  Result := TXmlNodeMsXmlAdapter.Create(AXMLDOMNode);
end;

end.
