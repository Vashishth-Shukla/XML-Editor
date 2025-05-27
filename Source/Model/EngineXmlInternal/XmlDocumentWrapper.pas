unit XmlDocumentWrapper;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLDoc, Xml.XMLIntf,
  IXmlDocument, IXmlNode, IXmlDocumentObserver,
  System.Generics.Collections;

type
  TXmlDocumentWrapper = class(TInterfacedObject, IXmlDocument)
  private
    FDoc: IXMLDocument;
    FObservers: TList<IXmlDocumentObserver>;
    FRootNode: IXmlNode;
    procedure NotifyObservers;
  public
    constructor Create;
    destructor Destroy; override;

    function GetRootNode: IXmlNode;

    procedure AddObserver(const AObserver: IXmlDocumentObserver);
    procedure RemoveObserver(const AObserver: IXmlDocumentObserver);

    procedure CreateRoot(const AName: string);
  end;

implementation

{ TXmlDocumentWrapper }

constructor TXmlDocumentWrapper.Create;
begin
  inherited Create;
  FDoc := TXMLDocument.Create(nil);
  FDoc.Active := True;
  FObservers := TList<IXmlDocumentObserver>.Create;
end;

destructor TXmlDocumentWrapper.Destroy;
begin
  FObservers.Free;
  inherited;
end;

function TXmlDocumentWrapper.GetRootNode: IXmlNode;
begin
  Result := FRootNode;
end;

procedure TXmlDocumentWrapper.AddObserver(const AObserver: IXmlDocumentObserver);
begin
  if FObservers.IndexOf(AObserver) = -1 then
    FObservers.Add(AObserver);
end;

procedure TXmlDocumentWrapper.RemoveObserver(const AObserver: IXmlDocumentObserver);
begin
  FObservers.Remove(AObserver);
end;

procedure TXmlDocumentWrapper.NotifyObservers;
var
  Obs: IXmlDocumentObserver;
begin
  for Obs in FObservers do
    Obs.DocumentChanged;
end;

procedure TXmlDocumentWrapper.CreateRoot(const AName: string);
begin
  FDoc.DocumentElement := FDoc.CreateElement(AName, '');
  FRootNode := TXmlNodeWrapper.Create(FDoc.DocumentElement);
  NotifyObservers;
end;

end.

