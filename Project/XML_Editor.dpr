program XML_Editor;

uses
  Vcl.Forms,
  UMainForm in '..\Source\View\UMainForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
