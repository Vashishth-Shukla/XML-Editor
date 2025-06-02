unit uXmlEditorPresenter;

interface

uses
  uIXmlEditorPresenter, uIXmlNode, uIXmlDocument,
  uIXmlAdapterFactory, uXmlCommon, System.SysUtils;

type
  TXmlEditorPresenter = class(TInterfacedObject, IXmlEditorPresenter)
  private
    FView: IMainFormView;
    FDoc: IXmlDocument;
    FFactory: IXmlAdapterFactory;
    FCurrentFileName: string;
  public
    constructor Create(const AFactory: IXmlAdapterFactory);
    procedure SetView(const AView: IMainFormView);

    procedure NewXml;
    procedure OpenXml;
    procedure SaveXml;
    procedure SaveAsXml;
    procedure ExitApp;

    procedure AddNode(NodeType: TXmlNodeType = xntElement);
    procedure AddNodeBefore(NodeType: TXmlNodeType);
    procedure AddNodeAfter(NodeType: TXmlNodeType);
    procedure AddNodeChild(NodeType: TXmlNodeType);
    procedure RemoveNode;
  end;

implementation

uses
  System.Classes;

constructor TXmlEditorPresenter.Create(const AFactory: IXmlAdapterFactory);
begin
  inherited Create;
  FFactory := AFactory;
end;

procedure TXmlEditorPresenter.SetView(const AView: IMainFormView);
begin
  FView := AView;
end;

procedure TXmlEditorPresenter.NewXml;
begin
  FDoc := FFactory.CreateDocument;
  FDoc.CreateEmpty('root');
  FCurrentFileName := '';
  FView.UpdateXmlTree(FDoc.GetRoot);
end;

procedure TXmlEditorPresenter.OpenXml;
var
  FileName: string;
begin
  FileName := FView.OpenFileDialog('XML Files|*.xml');
  if FileName <> '' then
  begin
    FDoc := FFactory.CreateDocument;
    if FDoc.LoadFromFile(FileName) then
    begin
      FCurrentFileName := FileName;
      FView.UpdateXmlTree(FDoc.GetRoot);
    end
    else
      FView.ShowMessage('Failed to load XML file.');
  end;
end;

procedure TXmlEditorPresenter.SaveXml;
begin
  if Assigned(FDoc) then
  begin
    if FCurrentFileName = '' then
      SaveAsXml
    else
      FDoc.SaveToFile(FCurrentFileName);
  end;
end;

procedure TXmlEditorPresenter.SaveAsXml;
var
  FileName: string;
begin
  if Assigned(FDoc) then
  begin
    FileName := FView.SaveFileDialog('XML Files|*.xml');
    if FileName <> '' then
    begin
      FDoc.SaveToFile(FileName);
      FCurrentFileName := FileName;
    end;
  end;
end;

procedure TXmlEditorPresenter.ExitApp;
begin
  Halt;
end;

procedure TXmlEditorPresenter.AddNode(NodeType: TXmlNodeType);
begin
  AddNodeChild(NodeType);
end;

procedure TXmlEditorPresenter.AddNodeChild(NodeType: TXmlNodeType);
var
  ParentNode, NewNode: IXmlNode;
begin
  if not Assigned(FDoc) then Exit;

  ParentNode := FView.GetSelectedTreeNode;
  if not Assigned(ParentNode) then
    ParentNode := FDoc.GetRoot;

  if not Assigned(ParentNode) then Exit;

  NewNode := ParentNode.CreateChild(NodeType, 'new', '');
  if Assigned(NewNode) then
    ParentNode.AppendChild(NewNode);

  FView.UpdateXmlTree(FDoc.GetRoot);
end;

procedure TXmlEditorPresenter.AddNodeBefore(NodeType: TXmlNodeType);
var
  RefNode, NewNode, ParentNode: IXmlNode;
begin
  if not Assigned(FDoc) then Exit;

  RefNode := FView.GetSelectedTreeNode;
  if not Assigned(RefNode) then Exit;

  ParentNode := RefNode.ParentNode;
  if not Assigned(ParentNode) then Exit;

  NewNode := ParentNode.CreateChild(NodeType, 'before', '');
  if Assigned(NewNode) then
    ParentNode.InsertBefore(NewNode, RefNode);

  FView.UpdateXmlTree(FDoc.GetRoot);
end;

procedure TXmlEditorPresenter.AddNodeAfter(NodeType: TXmlNodeType);
var
  RefNode, NewNode, ParentNode: IXmlNode;
begin
  if not Assigned(FDoc) then Exit;

  RefNode := FView.GetSelectedTreeNode;
  if not Assigned(RefNode) then Exit;

  ParentNode := RefNode.ParentNode;
  if not Assigned(ParentNode) then Exit;

  NewNode := ParentNode.CreateChild(NodeType, 'after', '');
  if Assigned(NewNode) then
    ParentNode.InsertAfter(NewNode, RefNode);

  FView.UpdateXmlTree(FDoc.GetRoot);
end;

procedure TXmlEditorPresenter.RemoveNode;
var
  Node: IXmlNode;
begin
  if not Assigned(FDoc) then Exit;

  Node := FView.GetSelectedTreeNode;
  if Assigned(Node) and (Node <> FDoc.GetRoot) then
  begin
    Node.Remove;
    FView.UpdateXmlTree(FDoc.GetRoot);
  end
  else
    FView.ShowMessage('Cannot remove the root node.');
end;

end.

