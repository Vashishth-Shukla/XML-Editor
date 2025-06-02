unit uIXmlNode;

interface

uses
  uXmlCommon;

type
  IXmlNode = interface
    ['{CEF51CFD-45CE-479A-B29C-52CA19147746}']
    function NodeName: string;
    function NodeValue: string;
    procedure SetNodeValue(const Value: string);
    function NodeType: TXmlNodeType;

    function HasChildNodes: Boolean;
    function ChildNodeCount: Integer;
    function ChildNodes(Index: Integer): IXmlNode;

    function HasAttributes: Boolean;
    function AttributeCount: Integer;
    function Attributes(Index: Integer): IXmlNode;

    function AsText: string;
    procedure AppendChild(const ANode: IXmlNode);
    procedure InsertBefore(const ANode: IXmlNode);
    procedure InsertAfter(const ANode: IXmlNode);
  end;

implementation

end.

