unit uXmlAdapterFactory;

interface

uses
  uIXmlAdapterFactory, uIXmlDocument;

type
  TXmlAdapterFactory = class(TInterfacedObject, IXmlAdapterFactory)
  public
    function CreateDocument: IXmlDocument;
  end;

implementation

uses
  uXmlDocumentMsXmlAdapter;

function TXmlAdapterFactory.CreateDocument: IXmlDocument;
begin
  Result := TXmlDocumentMsXmlAdapter.Create;
end;

end.

