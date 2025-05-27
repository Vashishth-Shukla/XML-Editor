unit IXmlDocument;

interface

uses
  IXmlNode, IXmlDocumentObserver, System.Generics.Collections;

type
  IXmlDocument = interface
    ['{9BD31B18-F796-44A2-BC14-00C75BBD8E7B}']

    function GetRootNode: IXmlNode;

    procedure AddObserver(const AObserver: IXmlDocumentObserver);
    procedure RemoveObserver(const AObserver: IXmlDocumentObserver);
    procedure NotifyObservers;

    procedure CreateRoot(const AName: string);

    property RootNode: IXmlNode read GetRootNode;
  end;

implementation

end.


