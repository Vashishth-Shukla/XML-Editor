program MyXmlEditor;

uses
  Vcl.Forms,
  fMainForm in '..\Source\View\fMainForm.pas' {frmMain},
  uIXmlAttribute in '..\Source\Model\Interfaces\uIXmlAttribute.pas',
  uIXmlNode in '..\Source\Model\Interfaces\uIXmlNode.pas',
  uIXmlDocument in '..\Source\Model\Interfaces\uIXmlDocument.pas', // FIX: Corrected typo from UIXmlDocument
  uXmlAttributeMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlAttributeMsXmlAdapter.pas',
  uXmlDocumentMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlDocumentMsXmlAdapter.pas',
  uXmlNodeMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlNodeMsXmlAdapter.pas',
  uXmlCommon in '..\Source\Model\DataTypes\uXmlCommon.pas',
  uIXmlAdapterFactory in '..\Source\Model\Interfaces\uIXmlAdapterFactory.pas',
  uXmlAdapterFactory in '..\Source\Model\Adapters\MsXmlAdapter\uXmlAdapterFactory.pas', // This is your concrete factory
  uIXmlEditorPresenter in '..\Source\Presenter\uIXmlEditorPresenter.pas',
  uXmlEditorPresenter in '..\Source\Presenter\uXmlEditorPresenter.pas';

{$R *.res}

var
  LPresenter: IXmlEditorPresenter;  // Declare a variable for your Presenter interface
  LFactory: IXmlAdapterFactory;    // Declare a variable for your Factory interface
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain); // The form is created here

  // --- NEW MVP CONNECTION CODE ---

  // 1. Create an instance of your concrete XML Adapter Factory
  // Assuming 'uXmlAdapterFactory.pas' defines a class named 'TXmlAdapterFactory'
  LFactory := TXmlAdapterFactory.Create;

  // 2. Create an instance of your Presenter, passing the Form (as IMainFormView) and the Factory
  LPresenter := TXmlEditorPresenter.Create(frmMain, LFactory);

  // 3. Assign the created Presenter instance to the Form
  frmMain.SetPresenter(LPresenter);

  // --- END NEW MVP CONNECTION CODE ---

  Application.Run; // Run the application
end.
