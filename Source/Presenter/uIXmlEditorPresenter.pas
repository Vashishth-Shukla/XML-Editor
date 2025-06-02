unit uIXmlEditorPresenter;

interface

uses
  uIXmlNode, uIXmlDocument, uXmlCommon;

type
  IMainFormView = interface
    ['{5D34C159-A6FB-4D86-93C5-66D70A4A5FA6}']
    procedure ShowMessage(const AMessage: string);
    procedure UpdateXmlTree(const AXmlRootNode: IXmlNode);
    function OpenFileDialog(const AFilter: string): string;
    function SaveFileDialog(const AFilter: string): string;
    function ShowConfirmationDialog(const AMessage, ACaption: string): Boolean;
    function GetSelectedTreeNode: IXmlNode;
  end;

  IXmlEditorPresenter = interface
    ['{8C58F0E3-0D72-4E0A-8E31-CA108A74A126}']
    procedure SetView(const AView: IMainFormView);
    procedure NewXml;
    procedure OpenXml;
    procedure SaveXml;
    procedure SaveAsXml;
    procedure ExitApp;
    procedure AddNode(NodeType: TXmlNodeType = xntElement);
    procedure RemoveNode;
  end;

implementation

end.

