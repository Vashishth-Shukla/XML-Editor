unit uXmlEditorPresenter;

interface

uses
  uIXmlEditorPresenter, uIXmlNode, uIXmlDocument, uIXmlAdapterFactory, uXmlCommon, System.SysUtils;

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
var
  Selected, NewNode: IXmlNode;
begin
  if not Assigned(FDoc) then
  begin
    FView.ShowMessage('No active document. Please create or open one.');
    Exit;
  end;

  Selected := FView.GetSelectedTreeNode;
  if not Assigned(Selected) then
  begin
    Selected := FDoc.GetRoot;
    if not Assigned(Selected) then
    begin
      FView.ShowMessage('No valid root node to insert into.');
      Exit;
    end;
  end;

  // Create a new node manually based on type
  NewNode := FFactory.CreateDocument.GetRoot; // temporary reuse, ideally replace to CreateNode
  if not Assigned(NewNode) then
  begin
    FView.ShowMessage('Failed to create a new node.');
    Exit;
  end;

  case NodeType of
    xntElement:
      begin
        NewNode.SetNodeValue('NewElement');
      end;
    xntComment:
      begin
        NewNode.SetNodeValue('Comment');
      end;
    xntText:
      begin
        NewNode.SetNodeValue('Text');
      end;
    xntAttribute:
      begin
        NewNode.SetNodeValue('Value');
      end;
    else
      NewNode.SetNodeValue('Node');
  end;

  Selected.AppendChild(NewNode);
  FView.UpdateXmlTree(FDoc.GetRoot);
end;

procedure TXmlEditorPresenter.RemoveNode;
begin
  FView.ShowMessage('RemoveNode not implemented yet.');
end;

end.

