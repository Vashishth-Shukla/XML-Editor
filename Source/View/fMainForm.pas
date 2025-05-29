unit fMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree, VirtualTrees.AncestorVCL,
  VirtualTrees, Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmMain = class(TForm)
    mmMain: TMainMenu;
    mmFile: TMenuItem;
    miFileNew: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSave: TMenuItem;
    miFileSaveAs: TMenuItem;
    miFileExit: TMenuItem;
    N1: TMenuItem;
    sbStatus: TStatusBar;
    pnlRawView: TPanel;
    tvRawXmlStructure: TTreeView;
    memRawXml: TMemo;
    splRawView: TSplitter;
    pnlVstView: TPanel;
    mmView: TMenuItem;
    miViewToggle: TMenuItem;
    popOpt: TPopupMenu;
    miOptAdElem: TMenuItem;
    miOptAdAttri: TMenuItem;
    miOptAdTxt: TMenuItem;
    miOptAdCmt: TMenuItem;
    miOptAdCDT: TMenuItem;
    miOptAdProIns: TMenuItem;
    miOptExp: TMenuItem;
    miOptClps: TMenuItem;
    N2: TMenuItem;
    miOptDlt: TMenuItem;
    N3: TMenuItem;
    miOptAdElmBfr: TMenuItem;
    miOptAdElmAft: TMenuItem;
    miOptAdElmCld: TMenuItem;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

end.
