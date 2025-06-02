unit fMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms,
  Vcl.Controls, Vcl.Menus, Vcl.ComCtrls, VirtualTrees, VirtualTrees.Types, Vcl.Graphics,
  uIXmlEditorPresenter, uIXmlNode, uXmlCommon, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL;

type
  TfrmMain = class(TForm, IMainFormView)
    mmMain: TMainMenu;
    mmFile: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSave: TMenuItem;
    miFileSaveAs: TMenuItem;
    miFileExit: TMenuItem;
    sbStatus: TStatusBar;
    vstContent: TVirtualStringTree;
    popOpt: TPopupMenu;
    miOptAdElem: TMenuItem;
    miOptAdAttri: TMenuItem;
    miOptAdTxt: TMenuItem;
    miOptAdCmt: TMenuItem;
    miOptAdCDT: TMenuItem;
    miOptAdProIns: TMenuItem;
    miOptDlt: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstContentGetTextColor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var Color: TColor);
    procedure miOptAdElemClick(Sender: TObject);
    procedure miOptAdAttriClick(Sender: TObject);
    procedure miOptAdTxtClick(Sender: TObject);
    procedure miOptAdCmtClick(Sender: TObject);
    procedure miOptAdCDTClick(Sender: TObject);
    procedure miOptAdProInsClick(Sender: TObject);

    procedure miFileOpenClick(Sender: TObject);
    procedure miFileSaveClick(Sender: TObject);
    procedure miFileSaveAsClick(Sender: TObject);
    procedure miFileExitClick(Sender: TObject);
    procedure miOptDltClick(Sender: TObject);

  private
    FPresenter: IXmlEditorPresenter;
    procedure InitializeTree;
    function GetXmlNodeFrom(Node: PVirtualNode): IXmlNode;
  public
    procedure SetPresenter(const APresenter: IXmlEditorPresenter);
    procedure ShowMessage(const AMessage: string);
    procedure UpdateXmlTree(const AXmlRootNode: IXmlNode);
    function OpenFileDialog(const AFilter: string): string;
    function SaveFileDialog(const AFilter: string): string;
    function ShowConfirmationDialog(const AMessage, ACaption: string): Boolean;
    function GetSelectedTreeNode: IXmlNode;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    Xml: IXmlNode;
  end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  InitializeTree;
  vstContent.PopupMenu := popOpt;
  miFileOpen.OnClick := miFileOpenClick;
  miFileSave.OnClick := miFileSaveClick;
  miFileSaveAs.OnClick := miFileSaveAsClick;
  miFileExit.OnClick := miFileExitClick;
  vstContent.PopupMenu := popOpt;
end;

procedure TfrmMain.InitializeTree;
begin
  vstContent.NodeDataSize := SizeOf(TNodeData);
  vstContent.Header.Options := [hoVisible];
  vstContent.TreeOptions.PaintOptions := [toShowHorzGridLines, toShowVertGridLines];
  vstContent.TreeOptions.MiscOptions := [toEditable];
  vstContent.Header.Columns.Clear;
  with vstContent.Header.Columns.Add do
  begin
    Text := 'Name';
    Width := 200;
  end;
  with vstContent.Header.Columns.Add do
  begin
    Text := 'Value';
    Width := 300;
  end;
  vstContent.OnGetText := vstContentGetText;
  //vstContent.OnGetTextColor := vstContentGetTextColor;
end;

function TfrmMain.GetXmlNodeFrom(Node: PVirtualNode): IXmlNode;
var
  Data: PNodeData;
begin
  Result := nil;
  if Assigned(Node) then
  begin
    Data := vstContent.GetNodeData(Node);
    if Assigned(Data) then
      Result := Data.Xml;
  end;
end;

procedure TfrmMain.SetPresenter(const APresenter: IXmlEditorPresenter);
begin
  FPresenter := APresenter;
end;

procedure TfrmMain.ShowMessage(const AMessage: string);
begin
  sbStatus.SimpleText := AMessage;
end;

procedure TfrmMain.UpdateXmlTree(const AXmlRootNode: IXmlNode);
  procedure AddTreeNode(XmlNode: IXmlNode; Parent: PVirtualNode);
  var
    Node: PVirtualNode;
    Data: PNodeData;
    i: Integer;
  begin
    Node := vstContent.AddChild(Parent);
    Data := vstContent.GetNodeData(Node);
    Data^.Xml := XmlNode;
    for i := 0 to XmlNode.AttributeCount - 1 do
      AddTreeNode(XmlNode.Attributes(i), Node);
    for i := 0 to XmlNode.ChildNodeCount - 1 do
      AddTreeNode(XmlNode.ChildNodes(i), Node);
  end;
begin
  vstContent.Clear;
  if Assigned(AXmlRootNode) then
    AddTreeNode(AXmlRootNode, nil);
  vstContent.FullExpand;
end;

function TfrmMain.OpenFileDialog(const AFilter: string): string;
var
  Dlg: TOpenDialog;
begin
  Result := '';
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Filter := AFilter;
    if Dlg.Execute then
      Result := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

function TfrmMain.SaveFileDialog(const AFilter: string): string;
var
  Dlg: TSaveDialog;
begin
  Result := '';
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Filter := AFilter;
    if Dlg.Execute then
      Result := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

function TfrmMain.ShowConfirmationDialog(const AMessage, ACaption: string): Boolean;
begin
  Result := MessageDlg(AMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function TfrmMain.GetSelectedTreeNode: IXmlNode;
begin
  Result := GetXmlNodeFrom(vstContent.FocusedNode);
end;

procedure TfrmMain.vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Data: PNodeData;
  Xml: IXmlNode;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Xml := Data.Xml;
    case Column of
      0:
        case Xml.NodeType of
          xntElement: CellText := Xml.NodeName;
          xntAttribute: CellText := '@' + Xml.NodeName;
          xntComment: CellText := '#comment';
          xntText: CellText := '#text';
          xntCData: CellText := '#cdata';
        else
          CellText := Xml.NodeName;
        end;
      1: CellText := Xml.NodeValue;
    end;
  end;
end;

procedure TfrmMain.vstContentGetTextColor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var Color: TColor);
var
  Data: PNodeData;
  Xml: IXmlNode;
begin
  if Column <> 0 then Exit;
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Xml := Data.Xml;
    case Xml.NodeType of
      xntElement: Color := clNavy;
      xntAttribute: Color := clGreen;
      xntComment: Color := clGray;
      xntText, xntCData: Color := clBlack;
    else
      Color := clWindowText;
    end;
  end;
end;

procedure TfrmMain.miOptAdElemClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.AddNode(xntElement);
end;

procedure TfrmMain.miOptAdAttriClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.AddNode(xntAttribute);
end;

procedure TfrmMain.miOptAdTxtClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.AddNode(xntText);
end;

procedure TfrmMain.miOptDltClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.RemoveNode;
end;

procedure TfrmMain.miOptAdCmtClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.AddNode(xntComment);
end;

procedure TfrmMain.miOptAdCDTClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.AddNode(xntCData);
end;

procedure TfrmMain.miOptAdProInsClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.AddNode(xntProcessingInstruction);
end;


procedure TfrmMain.miFileOpenClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OpenXml;
end;

procedure TfrmMain.miFileSaveClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.SaveXml;
end;

procedure TfrmMain.miFileSaveAsClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.SaveAsXml;
end;

procedure TfrmMain.miFileExitClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.ExitApp;
end;

end.

