program XML_Editor;

uses
  Vcl.Forms,
  UfrmMain in '..\Source\View\UfrmMain.pas' {frmMain},
  U_XmlNodeWrapper in 'U_XmlNodeWrapper.pas',
  IXmlDocument in '..\Source\Model\Interfaces\IXmlDocument.pas',
  IXmlDocumentObserver in '..\Source\Model\Interfaces\IXmlDocumentObserver.pas',
  IXmlEngine in '..\Source\Model\Interfaces\IXmlEngine.pas',
  IXmlNode in '..\Source\Model\Interfaces\IXmlNode.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
