program P_XML_Editor;

uses
  Vcl.Forms,
  F_Main in '..\Source\Forms\F_Main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
