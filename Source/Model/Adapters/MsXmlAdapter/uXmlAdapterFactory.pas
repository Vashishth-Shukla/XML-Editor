unit uXmlAdapterFactory; // Note: Unit name is uXmlAdapterFactory, not uXmlMsXmlAdapterFactory as it's the specific impl.

interface

uses
  uIXmlAdapterFactory,   // The interface we are implementing
  uIXmlDocument;         // The interface whose objects we will create

type
  // Concrete factory for creating XML document adapters using MSXML.
  TXmlAdapterFactory = class(TInterfacedObject, IXmlAdapterFactory)
  public
    // IXmlAdapterFactory implementation
    function CreateDocument: IXmlDocument;
  end;

implementation

uses
  uXmlDocumentMsXmlAdapter; // We need to 'use' the specific MSXML adapter to create it

{ TXmlAdapterFactory }

function TXmlAdapterFactory.CreateDocument: IXmlDocument;
begin
  // Create and return an instance of our MSXML document adapter,
  // cast to the IXmlDocument interface.
  // The adapter's constructor will internally create the underlying MSXMLDOMDocument.
  Result := TXmlDocumentMsXmlAdapter.Create as IXmlDocument;
end;

end.
