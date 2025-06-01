unit fMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL,
  VirtualTrees,
  Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  // --- Our custom units (needed for interface section declarations) ---
  uIXmlNode,             // Still needed because TfrmMain methods (like GetSelectedTreeNode, UpdateXmlTree) use IXmlNode
  uIXmlAttribute,        // Still needed for casting in UpdateXmlTree's helper
  uIXmlEditorPresenter,  // The interface for our Presenter
  uXmlCommon,            // For TXmlNodeType enum (used in VST GetText declarations)
  uIMainForm;            // IMPORTANT: Now uses the separate interface unit (uIMainForm.pas)

type
  TfrmMain = class(TForm, IMainFormView)
    mmMain: TMainMenu;
    mmFile: TMenuItem;
    miFileNew: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSave: TMenuItem;
    miFileSaveAs: TMenuItem;
    miFileExit: TMenuItem;
    N1: TMenuItem;
    sbStatus: TStatusBar;
    pnlRawView: TPanel;
    vstRawXmlStructure: TVirtualStringTree;
    memRawXml: TMemo;
    splRawView: TSplitter;
    pnlVstView: TPanel;
    vstContent: TVirtualStringTree;
    mmView: TMenuItem;
    miViewToggle: TMenuItem;
    popOpt: TPopupMenu;
    miOptAdElem: TMenuItem;
    miOptAdAttri: TMenuItem;
    miOptAdTxt: TMenuItem;
    miOptAdCmt: TMenuItem;
    miOptAdCDT: TMenuItem;
    miOptAdProIns: TMenuItem;
    miOptExp: TMenuItem;
    miOptClps: TMenuItem;
    N2: TMenuItem;
    miOptDlt: TMenuItem;
    N3: TMenuItem;
    miOptAdElmBfr: TMenuItem;
    miOptAdElmAft: TMenuItem;
    miOptAdElmCld: TMenuItem;

    procedure FormCreate(Sender: TObject);
    // Main Menu Event Handlers
    procedure miFileNewClick(Sender: TObject);
    procedure miFileOpenClick(Sender: TObject);
    procedure miFileSaveClick(Sender: TObject);
    procedure miFileSaveAsClick(Sender: TObject);
    procedure miFileExitClick(Sender: TObject);
    procedure miViewToggleClick(Sender: TObject); // Added Toggle View handler

    // Context Menu Event Handlers (Initially just delegating, logic in Presenter)
    procedure miOptAdElemClick(Sender: TObject);
    procedure miOptAdAttriClick(Sender: TObject);
    procedure miOptAdTxtClick(Sender: TObject);
    procedure miOptAdCmtClick(Sender: TObject);
    procedure miOptAdCDTClick(Sender: TObject);
    procedure miOptAdProInsClick(Sender: TObject);
    procedure miOptDltClick(Sender: TObject);
    procedure miOptExpClick(Sender: TObject);
    procedure miOptClpsClick(Sender: TObject);
    procedure miOptAdElmBfrClick(Sender: TObject); // Specific add element options
    procedure miOptAdElmAftClick(Sender: TObject);
    procedure miOptAdElmCldClick(Sender: TObject);

    // --- TVirtualStringTree Event Handler Declarations ---
    procedure vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstContentFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);

    procedure vstRawXmlStructureGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstRawXmlStructureFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    // --- End TVirtualStringTree ---

  private
    FPresenter: IXmlEditorPresenter; // Use the interface for the presenter
    { Private declarations }

    // Helper function for TVirtualStringTree - now a method of the form
    function GetXmlNodeFromVSTNode(Tree: TBaseVirtualTree; Node: PVirtualNode): IXmlNode;

  public
    // Setter for the Presenter (called by the application's entry point)
    procedure SetPresenter(const APresenter: IXmlEditorPresenter);

    // IMainFormView implementation (REMOVED 'override' keyword - these are interface implementations)
    procedure ShowMessage(const AMessage: string);
    procedure UpdateXmlTree(const AXmlRootNode: IXmlNode);
    procedure UpdateRawXml(const AXmlString: string);
    function GetRawXmlString: string;
    function OpenFileDialog(const AFilter: string): string;
    function SaveFileDialog(const AFilter: string): string;
    function ShowConfirmationDialog(const AMessage, ACaption: string): Boolean;
    function GetSelectedTreeNode: IXmlNode;
    procedure SetRawViewPanelVisibility(AVisible: Boolean);
    procedure SetVSTViewPanelVisibility(AVisible: Boolean);
    function IsRawViewPanelVisible: Boolean;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm} // Links the DFM file for the form design

uses
  System.IOUtils,            // For TPath functions in dialogs if you need to extract path/name
  // --- Concrete Presenter (needed only in implementation for FPresenter assignment) ---
  uXmlEditorPresenter;       // The concrete Presenter class (used for FPresenter assignment)

// --- Helper function for TVirtualStringTree ---
function TfrmMain.GetXmlNodeFromVSTNode(Tree: TBaseVirtualTree; Node: PVirtualNode): IXmlNode;
var
  Data: Pointer;
begin
  Result := nil; // Initialize Result
  Data := Tree.GetNodeData(Node);
  if Assigned(Data) then
    Result := IXmlNode(Data); // Cast the pointer back to IXmlNode
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Set initial view state: prioritize VST view
  SetRawViewPanelVisibility(False); // Hide raw view initially
  SetVSTViewPanelVisibility(True);  // Show VST view initially

  // --- TVirtualStringTree Event Assignments (for both VSTs) ---
  // Ensure these are assigned, or the VST won't know how to render nodes
  vstContent.OnGetText := vstContentGetText;
  vstContent.OnFreeNode := vstContentFreeNode;

  vstRawXmlStructure.OnGetText := vstRawXmlStructureGetText;
  vstRawXmlStructure.OnFreeNode := vstRawXmlStructureFreeNode;
  // --- End TVirtualStringTree Event Assignments ---
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
// Helper procedure to recursively add nodes to the VST
procedure AddNodesToTree(Tree: TBaseVirtualTree; ParentNode: PVirtualNode; XmlNode: IXmlNode);
var
  VSTNode: PVirtualNode;
  ChildXmlNode: IXmlNode;
  AttributeXmlNode: IXmlAttribute;
begin
  if not Assigned(XmlNode) then Exit;

  // Create a new VST node and associate it with the IXmlNode
  VSTNode := Tree.AddChild(ParentNode, nil); // Data will be set below
  Tree.SetNodeData(VSTNode, Pointer(XmlNode)); // Store the IXmlNode directly

  // Add attributes as children under element nodes
  if XmlNode.NodeType = xntElement then
  begin
    for AttributeXmlNode in XmlNode.Attributes do
    begin
      // Add attribute as child of element in VST
      VSTNode := Tree.AddChild(VSTNode, nil);
      // Store the IXmlAttribute (which now also implements IXmlNode)
      Tree.SetNodeData(VSTNode, Pointer(AttributeXmlNode as IXmlNode));
    end;
  end;

  // Recursively add child XML nodes
  for ChildXmlNode in XmlNode.ChildNodes do
  begin
    // Skip empty text nodes for a cleaner tree display (optional, based on preference)
    if (ChildXmlNode.NodeType = xntText) and (Trim(ChildXmlNode.Value) = '') then
      Continue;

    AddNodesToTree(Tree, VSTNode, ChildXmlNode); // Recursive call
  end;
end;

begin
  // Clear both trees before populating to ensure a fresh display
  vstContent.Clear;
  vstRawXmlStructure.Clear;

  if Assigned(AXmlRootNode) then
  begin
    // Add the root node to vstContent
    AddNodesToTree(vstContent, nil, AXmlRootNode); // nil for ParentNode means it's a root VST node
    vstContent.FullExpand; // Optional: expands the tree fully on load, showing all nodes

    // Add the root node to vstRawXmlStructure (if it's meant to show the same tree structure)
    // For now, we populate it similarly to vstContent.
    AddNodesToTree(vstRawXmlStructure, nil, AXmlRootNode);
    vstRawXmlStructure.FullExpand; // Optional: expands the tree fully on load

    ShowMessage('XML tree structure updated with ' + AXmlRootNode.Name + ' as root.');
  end
  else
  begin
    ShowMessage('XML tree structure cleared (no root node).');
  end;
end;

procedure TfrmMain.UpdateRawXml(const AXmlString: string);
begin
  memRawXml.Text := AXmlString;
  ShowMessage('Raw XML view updated.');
end;

function TfrmMain.GetRawXmlString: string;
begin
  Result := memRawXml.Text;
end;

function TfrmMain.OpenFileDialog(const AFilter: string): string;
var
  OpenDialog: TOpenDialog;
begin
  Result := '';
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := AFilter;
    if OpenDialog.Execute then
      Result := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;
end;

function TfrmMain.SaveFileDialog(const AFilter: string): string;
var
  SaveDialog: TSaveDialog;
begin
  Result := '';
  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.Filter := AFilter;
    if SaveDialog.Execute then
      Result := SaveDialog.FileName;
  finally
    SaveDialog.Free;
  end;
end;

function TfrmMain.ShowConfirmationDialog(const AMessage, ACaption: string): Boolean;
begin
  Result := MessageDlg(AMessage, mtConfirmation, mbYesNo, 0) = mrYes;
end;

function TfrmMain.GetSelectedTreeNode: IXmlNode;
begin
  Result := nil;
  // Get the selected node from the currently visible VST
  if pnlVstView.Visible and Assigned(vstContent.FocusedNode) then
    Result := GetXmlNodeFromVSTNode(vstContent, vstContent.FocusedNode)
  else if pnlRawView.Visible and Assigned(vstRawXmlStructure.FocusedNode) then
    Result := GetXmlNodeFromVSTNode(vstRawXmlStructure, vstRawXmlStructure.FocusedNode);
end;

procedure TfrmMain.SetRawViewPanelVisibility(AVisible: Boolean);
begin
  pnlRawView.Visible := AVisible;
  splRawView.Visible := AVisible; // Show splitter when raw view is visible
end;

procedure TfrmMain.SetVSTViewPanelVisibility(AVisible: Boolean);
begin
  pnlVstView.Visible := AVisible;
end;

function TfrmMain.IsRawViewPanelVisible: Boolean;
begin
  Result := pnlRawView.Visible;
end;

// --- Main Menu Event Handlers (Delegate to Presenter) ---

procedure TfrmMain.miFileNewClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.NewXml;
end;

procedure TfrmMain.miFileOpenClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.OpenXml;
end;

procedure TfrmMain.miFileSaveClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.SaveXml;
end;

procedure TfrmMain.miFileSaveAsClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.SaveAsXml;
end;

procedure TfrmMain.miFileExitClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.ExitApp;
end;

procedure TfrmMain.miViewToggleClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.ToggleView;
end;

// --- Context Menu Event Handlers (Delegate to Presenter) ---
// These are currently simple delegations. More detailed context passing will be needed later.

procedure TfrmMain.miOptAdElemClick(Sender: TObject);
begin
  // This top-level item typically acts as a parent for sub-menus.
  // If it could be clicked directly and you want an action, add FPresenter.AddNode here
end;

procedure TfrmMain.miOptAdAttriClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Attribute' type
end;

procedure TfrmMain.miOptAdTxtClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Text' type
end;

procedure TfrmMain.miOptAdCmtClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Comment' type
end;

procedure TfrmMain.miOptAdCDTClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'CDATA' type
end;

procedure TfrmMain.miOptAdProInsClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Processing Instruction' type
end;

procedure TfrmMain.miOptDltClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.RemoveNode;
end;

procedure TfrmMain.miOptExpClick(Sender: TObject);
begin
  // This will expand the current tree based on which VST is visible and has focus.
  // FullExpand has an overload that takes a node, which is what we want here.
  if vstContent.Visible and Assigned(vstContent.FocusedNode) then
    vstContent.FullExpand(vstContent.FocusedNode) // Expand node and its children
  else if vstRawXmlStructure.Visible and Assigned(vstRawXmlStructure.FocusedNode) then
    vstRawXmlStructure.FullExpand(vstRawXmlStructure.FocusedNode);
end;

procedure CollapseFromNode(VST: TVirtualStringTree; Node: PVirtualNode);
begin
  while Assigned(Node) do
  begin
    VST.Expanded[Node] := False; // Collapse the current node
    if Assigned(Node.FirstChild) then
      CollapseFromNode(VST, Node.FirstChild); // Recursively call for its first child
    Node := Node.NextSibling; // Move to the next sibling
  end;
end;

procedure TfrmMain.miOptClpsClick(Sender: TObject);
begin
  if vstContent.Visible and Assigned(vstContent.FocusedNode) then
    CollapseFromNode(vstContent, vstContent.FocusedNode)
  else if vstRawXmlStructure.Visible and Assigned(vstRawXmlStructure.FocusedNode) then
    CollapseFromNode(vstRawXmlStructure, vstRawXmlStructure.FocusedNode);
end;

procedure TfrmMain.miOptAdElmBfrClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Element Before'
end;

procedure TfrmMain.miOptAdElmAftClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Element After'
end;

procedure TfrmMain.miOptAdElmCldClick(Sender: TObject);
begin
  if Assigned(FPresenter) then
    FPresenter.AddNode; // Presenter will need context for 'Element Child'
end;

// --- TVirtualStringTree Event Implementations ---

procedure TfrmMain.vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  XmlNode: IXmlNode;
begin
  XmlNode := GetXmlNodeFromVSTNode(Sender, Node);
  if Assigned(XmlNode) then
  begin
    case Column of
      0: // First column: Node Name/Type
        begin
          case XmlNode.NodeType of
            xntElement: CellText := XmlNode.Name;
            xntAttribute: CellText := '@' + XmlNode.Name; // Prefix for attributes
            xntText: CellText := '#text';
            xntCData: CellText := '#cdata';
            xntComment: CellText := '#comment'; // Display as comment type
            xntProcessingInstruction: CellText := '<?' + XmlNode.Name + '?>';
            xntDocument: CellText := '#document'; // For the root document node
            xntDocumentType: CellText := '#doctype';
            xntEntityRef: CellText := '&' + XmlNode.Name + ';';
            xntNotation: CellText := '#notation';
            else CellText := XmlNode.Name; // Fallback for unknown/unhandled types
          end;
        end;
      1: // Second column: Node Value (if applicable)
        begin
          if (XmlNode.NodeType = xntElement) and (XmlNode.Value <> '') then
            CellText := XmlNode.Value // Display element text value if it has one
          else if (XmlNode.NodeType in [xntText, xntCData, xntComment, xntProcessingInstruction, xntAttribute]) then
            CellText := XmlNode.Value; // Display value for other types that have values
        end;
    end;
  end;
end;

procedure TfrmMain.vstContentFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  XmlNode: IXmlNode;
begin
  // Crucial for releasing the interface reference and avoiding memory leaks.
  XmlNode := GetXmlNodeFromVSTNode(Sender, Node);
  if Assigned(XmlNode) then
    XmlNode := nil; // Decrement reference count; object will be freed when count reaches zero.
end;

// Event handlers for vstRawXmlStructure (copied from vstContent for now)
procedure TfrmMain.vstRawXmlStructureGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
begin
  vstContentGetText(Sender, Node, Column, TextType, CellText);
end;

procedure TfrmMain.vstRawXmlStructureFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  vstContentFreeNode(Sender, Node);
end;

end.
