unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL, VirtualTrees;

type
  TMainForm = class(TForm)
    vstXMLView: TVirtualStringTree;
    mainMenu: TMainMenu;
    File1: TMenuItem;
    File2: TMenuItem;
    Open1: TMenuItem;
    Open2: TMenuItem;
    SaveAs1: TMenuItem;
    SaveAs2: TMenuItem;
    N1: TMenuItem;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

end.
