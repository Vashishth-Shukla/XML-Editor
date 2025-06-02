unit uIXmlAdapterFactory;

interface

uses
  uIXmlDocument;

type
  IXmlAdapterFactory = interface
    ['{7AB67323-FA5A-4A4C-A17D-FE7F7EECF545}']
    function CreateDocument: IXmlDocument;
  end;

implementation

end.
