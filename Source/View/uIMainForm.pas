unit uIMainForm;

interface

uses
  System.Generics.Collections, // For TList<T> if any IXmlNode methods use it (good to include for future proofing)
  uIXmlNode;                   // For the IXmlNode type used in UpdateXmlTree

type
  // Interface for the Main Form (View)
  // The Presenter will interact with the form through this interface.
  IMainFormView = interface
    ['{638DFD12-0DA9-44D5-A8FB-0F31637C8F6E}']
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

implementation

end.
