program XML_Editor;

uses
  Vcl.Forms,
  MainForm in 'Source\Forms\MainForm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
