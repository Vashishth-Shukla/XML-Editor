unit uXmlAttributeMsXmlAdapter;

interface

uses
  System.SysUtils,
  MSXML,                       // Defines IXMLDOMAttribute and other core MSXML interfaces
  Xml.XMLDoc,                  // Provides TXMLDocument
  Xml.Win.MSXMLDOM,            // Provides more advanced MSXML interaction classes and types
  uIXmlAttribute;              // Our custom attribute interface

type
  // Adapter class to wrap an MSXML IXMLDOMAttribute and expose it as our IXmlAttribute interface.
  // TInterfacedObject handles the reference counting for the interface automatically.
  TXmlAttributeMsXmlAdapter = class(TInterfacedObject, IXmlAttribute)
  private
    FMsXmlAttribute: IXMLDOMAttribute; // The actual MSXML COM object for the attribute

    // IXmlAttribute interface implementation methods
    function GetName: string;
    function GetValue: string;
    procedure SetValue(const AValue: string);
  public
    // Constructor takes the underlying MSXML attribute
    constructor Create(const AMSXMLAttribute: IXMLDOMAttribute);
    // Destructor ensures COM interface is released
    destructor Destroy; override;
    // Exposes the raw MSXML attribute for internal use by parent adapters (e.g., TXmlNodeMsXmlAdapter)
    function GetMSXMLAttribute: IXMLDOMAttribute;
    // Properties for easier access as defined by IXmlAttribute
    property Name: string read GetName;
    property Value: string read GetValue write SetValue;
  end;

implementation

{ TXmlAttributeMsXmlAdapter }

constructor TXmlAttributeMsXmlAdapter.Create(const AMSXMLAttribute: IXMLDOMAttribute);
begin
  inherited Create; // Initialize TInterfacedObject
  FMsXmlAttribute := AMSXMLAttribute; // Store the MSXML attribute reference
end;

destructor TXmlAttributeMsXmlAdapter.Destroy;
begin
  FMsXmlAttribute := nil; // Release the COM interface reference to avoid memory leaks
  inherited Destroy;
end;

function TXmlAttributeMsXmlAdapter.GetName: string;
begin
  // Return the name of the underlying MSXML attribute
  Result := FMsXmlAttribute.nodeName;
end;

function TXmlAttributeMsXmlAdapter.GetMSXMLAttribute: IXMLDOMAttribute;
begin
  // Return the raw MSXML attribute for internal use by other adapters
  Result := FMsXmlAttribute;
end;

function TXmlAttributeMsXmlAdapter.GetValue: string;
begin
  // Return the value of the underlying MSXML attribute
  Result := FMsXmlAttribute.nodeValue;
end;

procedure TXmlAttributeMsXmlAdapter.SetValue(const AValue: string);
begin
  // Set the value of the underlying MSXML attribute
  FMsXmlAttribute.nodeValue := AValue;
end;

end.
