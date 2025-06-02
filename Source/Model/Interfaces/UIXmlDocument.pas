unit uIXmlDocument;

interface

uses
  uIXmlNode;

type
  IXmlDocument = interface
    ['{39B9F3E0-9246-4E14-B52D-CC98382CD1CB}']

    function LoadFromFile(const AFileName: string): Boolean;
    function GetRoot: IXmlNode;
    function AsText: string;

    procedure SaveToFile(const AFileName: string);
    function SaveToString: string;

    procedure CreateEmpty(const ARootName: string = 'root');
  end;

implementation

end.

