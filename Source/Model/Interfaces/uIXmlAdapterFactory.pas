unit uIXmlAdapterFactory;

interface

uses
  System.Rtti, // For [ComponentPlatform(TRESTCategory.All)] if you're using it
  uIXmlDocument; // The factory will create instances of IXmlDocument

type
  // Interface for an abstract XML adapter factory
  // This factory is responsible for creating instances of IXmlDocument.
  // Nodes and attributes are typically created via the IXmlDocument or IXmlNode interface itself.
  [ComponentPlatform(TRESTCategory.All)] // Optional: Keep if you are using REST components and this directive is common in your interfaces
  IXmlAdapterFactory = interface
    ['{39DFFFB5-9FF0-4608-9DCF-C6395A19A044}']
    function CreateDocument: IXmlDocument;
  end;

implementation

end.
