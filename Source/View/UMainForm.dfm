object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mainMenu
  TextHeight = 15
  object vstXMLView: TVirtualStringTree
    Left = -8
    Top = 0
    Width = 633
    Height = 441
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 0
    Header.Height = 15
    Header.MainColumn = -1
    TabOrder = 0
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object mainMenu: TMainMenu
    Left = 584
    Top = 32
    object File1: TMenuItem
      Caption = 'File'
      object File2: TMenuItem
        Caption = 'New'
      end
      object Open1: TMenuItem
        Caption = 'Open...'
      end
      object Open2: TMenuItem
        Caption = 'Save'
      end
      object SaveAs1: TMenuItem
        Caption = 'Save As...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object SaveAs2: TMenuItem
        Caption = 'Exit'
      end
    end
  end
end
