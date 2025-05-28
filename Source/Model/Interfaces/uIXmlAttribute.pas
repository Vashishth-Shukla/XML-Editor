unit uIXmlAttribute;

interface

uses
  System.Rtti;

type
  [ComponentPlatform(TRESTCategory.All)] // In case REST components
  IXmlAttribute = interface
    ['{F5A1E3AD-FC12-4032-BF31-95718D0F88A6}']
    function GetName: string;
    function GetValue: string;
    procedure SetValue(const AValue: string);
    property Name: string read GetName;
    property Value: string read GetValue write SetValue;
  end;

implementation

end.
