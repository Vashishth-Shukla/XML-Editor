program MyXmlEditor;

uses
  Vcl.Forms,
  fMainForm in '..\Source\View\fMainForm.pas' {frmMain},
  uIXmlAttribute in '..\Source\Model\Interfaces\uIXmlAttribute.pas',
  uIXmlNode in '..\Source\Model\Interfaces\uIXmlNode.pas',
  UIXmlDocument in '..\Source\Model\Interfaces\UIXmlDocument.pas',
  uXmlAttributeMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlAttributeMsXmlAdapter.pas',
  uXmlDocumentMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlDocumentMsXmlAdapter.pas',
  uXmlNodeMsXmlAdapter in '..\Source\Model\Adapters\MsXmlAdapter\uXmlNodeMsXmlAdapter.pas',
  uXmlCommon in '..\Source\Model\DataTypes\uXmlCommon.pas',
  uIXmlAdapterFactory in '..\Source\Model\Interfaces\uIXmlAdapterFactory.pas',
  uXmlAdapterFactory in '..\Source\Model\Adapters\MsXmlAdapter\uXmlAdapterFactory.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
