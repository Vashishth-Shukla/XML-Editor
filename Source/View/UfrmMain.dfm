object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmMain
  TextHeight = 15
  object mmMain: TMainMenu
    Left = 584
    Top = 16
    object mmFile: TMenuItem
      Caption = 'File'
      object miFileNew: TMenuItem
        Caption = 'New'
      end
      object miFileOpen: TMenuItem
        Caption = 'Open...'
      end
      object miFileSave: TMenuItem
        Caption = 'Save'
      end
      object miFileSaveAs: TMenuItem
        Caption = 'Save As...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miFileExit: TMenuItem
        Caption = 'Exit'
      end
    end
  end
end
