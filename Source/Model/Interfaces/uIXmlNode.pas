unit uIXmlNode;

interface

uses
  System.Generics.Collections, // For TList<T>
  System.Rtti,                 // For RTTI on interfaces
  uIXmlAttribute,              // Depends on our IXmlAttribute interface
  uXmlCommon;                  // Common types like TXmlNodeType and EXmlAdapterException

type
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
