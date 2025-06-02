program MyXmlEditor;

uses
  Vcl.Forms,
  fMainForm in '..\Source\View\fMainForm.pas' {frmMain},
  uIXmlEditorPresenter in '..\Source\Presenter\uIXmlEditorPresenter.pas',
  uXmlEditorPresenter in '..\Source\Presenter\uXmlEditorPresenter.pas',
  uIXmlAdapterFactory in '..\Source\Model\Interfaces\uIXmlAdapterFactory.pas',
  uXmlAdapterFactory in '..\Source\Model\Adapters\MsXmlAdapter\uXmlAdapterFactory.pas',
  uIXmlDocument in '..\Source\Model\Interfaces\UIXmlDocument.pas',
  uIXmlNode in '..\Source\Model\Interfaces\uIXmlNode.pas',
  uXmlDocumentMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlDocumentMsXmlAdapter.pas',
  uXmlNodeMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlNodeMsXmlAdapter.pas',
  uXmlCommon in '..\Source\Model\DataTypes\uXmlCommon.pas';

{$R *.res}

var
  LFactory: IXmlAdapterFactory;
  LPresenter: IXmlEditorPresenter;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Application.CreateForm(TfrmMain, frmMain);

  LFactory := TXmlAdapterFactory.Create;
  LPresenter := TXmlEditorPresenter.Create(LFactory);

  frmMain.SetPresenter(LPresenter);
  LPresenter.SetView(frmMain);
  LPresenter.NewXml;

  Application.Run;
end.

