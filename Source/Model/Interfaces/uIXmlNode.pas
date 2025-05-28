unit uIXmlNode;

interface

uses
  System.Generics.Collections, // For TList<T>
  System.Rtti,                 // For RTTI on interfaces
  uIXmlAttribute;              // Depends on our IXmlAttribute interface

type
  // Define XML Node Types as an enum
  TXmlNodeType = (
    xntUnknown,                 // Unknown or unhandled node type
    xntElement,                 // An XML element (e.g., <tag>)
    xntAttribute,               // An attribute of an element (e.g., name="value")
    xntText,                    // Text content within an element
    xntCData,                   // CDATA section (e.g., <![CDATA[...]]>)
    xntComment,                 // XML comment (e.g., )
    xntProcessingInstruction    // Processing instruction (e.g., <?xml-stylesheet ...?>)
    // xntDeclaration           // XML declaration (e.g., <?xml version="1.0" encoding="UTF-8"?>) // not available in msxml 6.0
  );

  [ComponentPlatform(TRESTCategory.All)] // In case REST components
  IXmlNode = interface
    ['{53B6A86F-1D32-4165-B906-FBA80C602A5F}']
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
    function GetParentNode: IXmlNode; // Crucial for tree traversal (can be nil for root)
    procedure SetParentNode(const ANode: IXmlNode); // For internal model consistency

    // Properties for easier access
    property Name: string read GetNodeName;
    property Value: string read GetNodeValue write SetNodeValue;
    property NodeType: TXmlNodeType read GetNodeType;
    property ChildNodes: TList<IXmlNode> read GetChildNodes;
    property Attributes: TList<IXmlAttribute> read GetAttributes;
    property Parent: IXmlNode read GetParentNode write SetParentNode;

    // Future-methods for XML operations
    // function FindChild(const AName: string): IXmlNode;
    // function FindAttribute(const AName: string): IXmlAttribute;
    // function CreateElement(const AName: string): IXmlNode; // Could be on node too
    // function CreateAttribute(const AName, AValue: string): IXmlAttribute;
  end;

implementation

end.
