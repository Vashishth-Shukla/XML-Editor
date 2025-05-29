unit uIXmlEditorPresenter;

interface

uses
  System.Rtti; // For [ComponentPlatform(TRESTCategory.All)] if you're using it

type
  // Interface for the XML Editor Presenter
  // This defines the contract between the View (fMainForm) and the Presenter logic.
  [ComponentPlatform(TRESTCategory.All)] // Optional: Keep if consistent with your project
  IXmlEditorPresenter = interface
    ['{87AD9D6C-F1D7-4064-AE75-DDB8383680A4}']
    procedure NewXml;
    procedure OpenXml;
    procedure LoadXml; // For loading from the raw text memo
    procedure SaveXml;
    procedure SaveAsXml;
    procedure ExitApp; // Handles application exit logic
    procedure AddNode;
    procedure RemoveNode;
    procedure EditNode;
    procedure RefreshRawXml; // To update memRawXml from the tree/model
    procedure ToggleView; // To switch between VST and raw view
    // Other methods will be added as needed for detailed node manipulation (e.g., specific AddElementBefore, AddAttribute, etc.)
  end;

implementation

end.
