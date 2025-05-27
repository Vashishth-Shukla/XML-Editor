unit IXmlNode;

interface

type
  IXmlNode = interface
    ['{7A99E6F4-B3C0-4A6C-B22C-0F6A0A64E63F}']
    function GetName: string;
    function GetValue: string;
    procedure SetValue(const AValue: string);
    function GetChildNodes: TArray<IXmlNode>;
    function AddChild(const AName: string): IXmlNode;
    procedure RemoveChild(const AName: string);
    property Name: string read GetName;
    property Value: string read GetValue write SetValue;
  end;

implementation

end.

