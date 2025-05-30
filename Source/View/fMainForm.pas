unit fMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree, VirtualTrees.AncestorVCL,
  VirtualTrees, Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  uIXmlNode,             // Used for UpdateXmlTree
  uIXmlEditorPresenter;  // The interface for our Presenter

type
  // Interface for the Main Form (View)
  // The Presenter will interact with the form through this interface.
  IMainFormView = interface
    ['{C0A1B2C3-D4E5-6789-EF01-23456789ABCD}'] // YOUR OWN GUID (Ctrl+Shift+G)
    procedure ShowMessage(const AMessage: string);
    // Method to update the primary XML tree view (TVirtualStringTree)
    procedure UpdateXmlTree(const AXmlRootNode: IXmlNode);
    // Method to update the raw XML text view (TMemo)
    procedure UpdateRawXml(const AXmlString: string);
    // Method to retrieve the current text from the raw XML memo
    function GetRawXmlString: string;
    // Methods for file dialogs, making the Presenter UI-agnostic
    function OpenFileDialog(const AFilter: string): string;
    function SaveFileDialog(const AFilter: string): string;
    // Confirmation dialog for actions like New/Open/Exit with unsaved changes
    function ShowConfirmationDialog(const AMessage, ACaption: string): Boolean;
    // Add methods for getting selected node from tree, etc. as needed later
    function GetSelectedTreeNode: IXmlNode; // Assuming VirtualStringTree provides a way to get IXmlNode
    procedure SetRawViewPanelVisibility(AVisible: Boolean);
    procedure SetVSTViewPanelVisibility(AVisible: Boolean);
    function IsRawViewPanelVisible: Boolean;
  end;

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
    vstRawXmlStructure: TVirtualStringTree; // CORRECTED: Now TVirtualStringTree for raw view tree
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
  private
    FPresenter: IXmlEditorPresenter; // Use the interface for the presenter
    { Private declarations }
  public
    procedure SetPresenter(const APresenter: IXmlEditorPresenter); // Setter expects interface

    // IMainFormView implementation
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
  System.IOUtils;     // For TPath functions in dialogs if you need to extract path/name

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Set initial view state: prioritize VST view
  SetRawViewPanelVisibility(False); // Hide raw view initially
  SetVSTViewPanelVisibility(True);  // Show VST view initially
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
begin
  // This is where the TVirtualStringTree population logic will go.
  // For now, we'll just ensure VSTs are cleared or refreshed.
  // The actual population logic will come later, it will be shared for vstContent and vstRawXmlStructure.
  vstContent.Clear; // Example for main VST
  vstRawXmlStructure.Clear; // Example for raw view VST
  // If Assigned(AXmlRootNode) then
  //   You would start populating vstContent / vstRawXmlStructure here based on the root node
  ShowMessage('XML tree structure updated.');
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
  // This will be crucial for node manipulation.
  // When TVirtualStringTree is implemented, you'll get the IXmlNode
  // from the selected node's data. This will apply to whichever VST is active.
  // Example for VST:
  // if Assigned(vstContent.FocusedNode) then // Use FocusedNode or Selected[0]
  //   Result := (vstContent.GetNodeData(vstContent.FocusedNode) as IXmlNode);
end;

procedure TfrmMain.SetRawViewPanelVisibility(AVisible: Boolean);
begin
  pnlRawView.Visible := AVisible;
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
  // This will be handled by sub-menus (Before, After, Child)
  // For now, this is a placeholder if this top-level item could also be clicked.
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
  // This might be handled directly by VST or via a specific presenter method
  // if Assigned(vstContent.FocusedNode) then vstContent.ExpandNode(vstContent.FocusedNode);
end;

procedure TfrmMain.miOptClpsClick(Sender: TObject);
begin
  // This might be handled directly by VST or via a specific presenter method
  // if Assigned(vstContent.FocusedNode) then vstContent.CollapseNode(vstContent.FocusedNode);
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

end.
