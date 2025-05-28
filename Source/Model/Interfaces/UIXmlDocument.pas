unit uIXmlDocument;

interface

uses
  uIXmlNode,        // Our custom interface for XML nodes
  uIXmlAttribute,   // Depends on our IXmlAttribute interface
  System.SysUtils;  // For string types

type
  // Interface for an abstracted XML Document
  IXmlDocument = interface
    ['{C0B1A2D3-E4F5-6789-ABCD-EF0123456789}'] // REPLACE with YOUR OWN GUID (Ctrl+Shift+G)
    function LoadFromFile(const AFilePath: string): Boolean;
    function LoadFromString(const AXmlString: string): Boolean;
    function SaveToFile(const AFilePath: string): Boolean;
    function SaveToString: string;
    function CreateNew(const ARootElementName: string): IXmlNode; // Returns the root element of the new document
    function GetRoot: IXmlNode;
    function CreateNode(const AName: string; ANodeType: TXmlNodeType = xntElement): IXmlNode; overload;
    function CreateNode(const AName: string; const AValue: string; ANodeType: TXmlNodeType = xntElement): IXmlNode; overload;
    function CreateAttribute(const AName: string; const AValue: string): IXmlAttribute;

    // Properties for easier access
    property Root: IXmlNode read GetRoot;
  end;

implementation

end.
