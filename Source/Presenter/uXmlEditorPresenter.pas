unit uXmlEditorPresenter;

interface

uses
  System.SysUtils,     // For general utilities and exceptions
  System.IOUtils,      // For TPath etc.
  uIXmlEditorPresenter,  // Our presenter interface
  uIXmlDocument,         // Our core XML document interface
  uIXmlAdapterFactory,   // Our factory for creating IXmlDocument
  fMainForm;             // The view interface (IMainFormView is defined within fMainForm)

type
  // The concrete implementation of the XML Editor Presenter.
  // It handles all application logic, interacting with the View and the Model.
  TXmlEditorPresenter = class(TInterfacedObject, IXmlEditorPresenter)
  private
    FView: IMainFormView;           // Reference to the UI (form) via its interface
    FFactory: IXmlAdapterFactory;   // Reference to the XML document factory
    FDocument: IXmlDocument;        // The currently loaded XML document
    FCurrentFilePath: string;       // Stores the path of the current file
    FIsDirty: Boolean;              // Tracks if the document has unsaved changes

    // Helper method to check for unsaved changes before performing an action
    function ConfirmDiscardChanges: Boolean;

    // Helper methods to update both UI views (raw XML and tree view)
    procedure UpdateUIFromModel;
    procedure UpdateRawXmlView;
    procedure UpdateTreeView;

  public
    // Constructor: Takes the View and the Factory as dependencies
    constructor Create(const AView: IMainFormView; const AFactory: IXmlAdapterFactory);

    // IXmlEditorPresenter implementation (from uIXmlEditorPresenter.pas)
    procedure NewXml;
    procedure OpenXml;
    procedure LoadXml; // This will read from memRawXml
    procedure SaveXml;
    procedure SaveAsXml;
    procedure ExitApp;
    procedure AddNode;
    procedure RemoveNode;
    procedure EditNode;
    procedure RefreshRawXml;
    procedure ToggleView;
  end;

implementation

uses
  System.UIConsts, // For sConfirmation, sYes, sNo
  Vcl.Forms;       // ADDED Vcl.Forms for Application object

{ TXmlEditorPresenter }

constructor TXmlEditorPresenter.Create(const AView: IMainFormView; const AFactory: IXmlAdapterFactory);
begin
  inherited Create;
  FView := AView;
  FFactory := AFactory;
  FDocument := FFactory.CreateDocument; // Create an initial empty document
  FIsDirty := False;
  FCurrentFilePath := '';
  FView.ShowMessage('Ready.');
  UpdateUIFromModel; // Initialize UI with empty document
end;

function TXmlEditorPresenter.ConfirmDiscardChanges: Boolean;
begin
  Result := True; // Assume user wants to proceed
  if FIsDirty then
  begin
    FView.ShowMessage('Document has unsaved changes. Confirm discard.');
    Result := FView.ShowConfirmationDialog(
      'Current XML has unsaved changes. Do you want to discard them?',
      'Unsaved Changes');
  end;
end;

procedure TXmlEditorPresenter.NewXml;
begin
  if not ConfirmDiscardChanges then Exit;

  FDocument := FFactory.CreateDocument; // Create a new empty document instance
  FDocument.CreateNew('root');         // Create a basic root element for the new document
  FIsDirty := True;                    // Mark as dirty
  FCurrentFilePath := '';
  FView.ShowMessage('New XML document created.');
  UpdateUIFromModel;                   // Update UI to reflect the new document
end;

procedure TXmlEditorPresenter.OpenXml;
var
  FilePath: string;
begin
  if not ConfirmDiscardChanges then Exit;

  FilePath := FView.OpenFileDialog('XML Files (*.xml)|*.xml|All Files (*.*)|*.*');
  if FilePath <> '' then
  begin
    try
      FDocument := FFactory.CreateDocument; // Create a fresh document for loading
      if FDocument.LoadFromFile(FilePath) then
      begin
        FCurrentFilePath := FilePath;
        FIsDirty := False;
        FView.ShowMessage(Format('XML loaded from "%s".', [FilePath]));
        UpdateUIFromModel;
      end
      // ***** THIS 'end' HAS NO SEMICOLON BEFORE 'else' *****
      // This line is where the semicolon was causing error E2153 at line 122:3
      else
      begin
        // FDocument.LoadFromFile already raises EXmlAdapterException for parsing errors
        FView.ShowMessage(Format('Failed to load XML from "%s". Check file format.', [FilePath]));
      end; // This semicolon is correct as it ends the if/else block
    except
      on E: Exception do
        FView.ShowMessage(Format('Error loading XML: %s', [E.Message]));
    end; // This semicolon is correct as it ends the try/except block
  end
  else
    FView.ShowMessage('Open operation cancelled.');
end;

procedure TXmlEditorPresenter.LoadXml; // This will load XML from the raw text memo
var
  XmlString: string;
begin
  // For now, this is assumed to be a "re-parse" of the text in the memo
  // In a real editor, this might be triggered by a "Parse" button next to the memo
  XmlString := FView.GetRawXmlString;
  if XmlString = '' then
  begin
    FView.ShowMessage('Raw XML memo is empty. Nothing to load.');
    Exit;
  end;

  try
    // Temporarily create a new document to load the string
    // If successful, replace the current FDocument
    var TempDoc := FFactory.CreateDocument;
    if TempDoc.LoadFromString(XmlString) then
    begin
      FDocument := TempDoc; // Replace the current document
      FIsDirty := True; // Assume any manual loading from memo makes it dirty
      FView.ShowMessage('XML loaded from raw text.');
      UpdateUIFromModel;
    end
    // ***** THIS 'end' HAS NO SEMICOLON BEFORE 'else' *****
    else
    begin
      // FDocument.LoadFromString already raises EXmlAdapterException for parsing errors
      FView.ShowMessage('Failed to load XML from raw text. Check XML format.');
    end; // This semicolon is correct as it ends the if/else block
  except
    on E: Exception do
      FView.ShowMessage(Format('Error parsing raw XML: %s', [E.Message]));
  end;
end;


procedure TXmlEditorPresenter.SaveXml;
begin
  if not Assigned(FDocument) or not Assigned(FDocument.Root) then
  begin
    FView.ShowMessage('No XML document to save.');
    Exit;
  end;

  if FCurrentFilePath = '' then
  begin
    SaveAsXml; // If no path, call SaveAs
  end
  else
  begin
    try
      // Ensure the raw XML memo's content is the source for saving if it's visible/active
      if FView.IsRawViewPanelVisible then
      begin
        FDocument.LoadFromString(FView.GetRawXmlString); // Re-parse raw text before saving
        FIsDirty := True; // Mark as dirty if re-parsed
      end;

      if FDocument.SaveToFile(FCurrentFilePath) then
      begin
        FIsDirty := False;
        FView.ShowMessage(Format('XML saved to "%s".', [FCurrentFilePath]));
      end
      else // No semicolon here
      begin
        FView.ShowMessage(Format('Failed to save XML to "%s".', [FCurrentFilePath]));
      end;
    except
      on E: Exception do
        FView.ShowMessage(Format('Error saving XML: %s', [E.Message]));
    end;
  end;
end;

procedure TXmlEditorPresenter.SaveAsXml;
var
  FilePath: string;
begin
  if not Assigned(FDocument) or not Assigned(FDocument.Root) then
  begin
    FView.ShowMessage('No XML document to save.');
    Exit;
  end;

  FilePath := FView.SaveFileDialog('XML Files (*.xml)|*.xml|All Files (*.*)|*.*');
  if FilePath <> '' then
  begin
    try
      // Ensure the raw XML memo's content is the source for saving if it's visible/active
      if FView.IsRawViewPanelVisible then
      begin
        FDocument.LoadFromString(FView.GetRawXmlString); // Re-parse raw text before saving
        FIsDirty := True; // Mark as dirty if re-parsed
      end;

      if FDocument.SaveToFile(FilePath) then
      begin
        FCurrentFilePath := FilePath; // Update current file path
        FIsDirty := False;
        FView.ShowMessage(Format('XML saved as "%s".', [FilePath]));
      end
      else // No semicolon here
      begin
        FView.ShowMessage(Format('Failed to save XML as "%s".', [FilePath]));
      end;
    except
      on E: Exception do
        FView.ShowMessage(Format('Error saving XML: %s', [E.Message]));
    end;
  end
  else
    FView.ShowMessage('Save As operation cancelled.');
end;

procedure TXmlEditorPresenter.ExitApp;
begin
  if ConfirmDiscardChanges then
    Application.Terminate // ***** NO SEMICOLON HERE *****
  else // No semicolon here
    FView.ShowMessage('Exit cancelled.');
end;

procedure TXmlEditorPresenter.AddNode;
begin
  // Placeholder. Real implementation will involve getting selected node,
  // prompting for node details (name, type, value), and calling FDocument.CreateNode
  // or FDocument.Root.AddChild / FDocument.Root.AddAttribute etc.
  FView.ShowMessage('Add Node functionality not yet implemented.');
  FIsDirty := True; // Assume any node change makes it dirty
  UpdateUIFromModel;
end;

procedure TXmlEditorPresenter.RemoveNode;
begin
  // Placeholder. Real implementation will involve getting selected node,
  // confirming deletion, and calling FDocument.Root.RemoveChild or similar.
  FView.ShowMessage('Remove Node functionality not yet implemented.');
  FIsDirty := True; // Assume any node change makes it dirty
  UpdateUIFromModel;
end;

procedure TXmlEditorPresenter.EditNode;
begin
  // Placeholder. Real implementation will involve getting selected node,
  // prompting for new details, and updating FDocument properties.
  FView.ShowMessage('Edit Node functionality not yet implemented.');
  FIsDirty := True; // Assume any node change makes it dirty
  UpdateUIFromModel;
end;

procedure TXmlEditorPresenter.RefreshRawXml;
begin
  // This is where you would refresh the raw XML memo based on the current model state.
  UpdateRawXmlView;
  FView.ShowMessage('Raw XML view refreshed from model.');
end;

procedure TXmlEditorPresenter.ToggleView;
begin
  if FView.IsRawViewPanelVisible then
  begin
    FView.SetRawViewPanelVisibility(False);
    FView.SetVSTViewPanelVisibility(True);
    FView.ShowMessage('Switched to Virtual String Tree view.');
  end
  // ***** THIS 'end' HAS NO SEMICOLON BEFORE 'else' *****
  // This line is where the semicolon was causing error E2153 at line 237:3
  else
  begin
    FView.SetVSTViewPanelVisibility(False);
    FView.SetRawViewPanelVisibility(True);
    FView.ShowMessage('Switched to Raw XML view.');
  end; // This semicolon is correct as it ends the if/else block
  UpdateUIFromModel; // This statement correctly follows the if/else block
end;

procedure TXmlEditorPresenter.UpdateUIFromModel;
begin
  // Update both views based on the current FDocument state
  UpdateRawXmlView;
  UpdateTreeView;
end;

procedure TXmlEditorPresenter.UpdateRawXmlView;
begin
  if Assigned(FDocument) and Assigned(FDocument.Root) then
    FView.UpdateRawXml(FDocument.SaveToString)
  else
    FView.UpdateRawXml(''); // Clear if no document or root
end;

procedure TXmlEditorPresenter.UpdateTreeView;
begin
  if Assigned(FDocument) then
    FView.UpdateXmlTree(FDocument.Root) // Pass the root node to the view
  else
    FView.UpdateXmlTree(nil); // Clear if no document
end;

end.
