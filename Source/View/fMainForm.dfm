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
  object vstContent: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 624
    Height = 422
    Align = alClient
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 0
    Header.Height = 15
    Header.MainColumn = -1
    TabOrder = 0
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object mmMain: TMainMenu
    Left = 592
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
      object N2: TMenuItem
        Caption = '-'
      end
      object miFileExit: TMenuItem
        Caption = 'Exit'
      end
    end
  end
  object popOpt: TPopupMenu
    Left = 592
    Top = 80
    object miOptAdElem: TMenuItem
      Caption = 'Add Element'
      object miOptAdElmBfr: TMenuItem
        Caption = 'Before'
      end
      object miOptAdElmAft: TMenuItem
        Caption = 'After'
      end
      object miOptAdElmCld: TMenuItem
        Caption = 'Child'
      end
    end
    object miOptAdAttri: TMenuItem
      Caption = 'Add Attribute'
    end
    object miOptAdTxt: TMenuItem
      Caption = 'Add Text'
    end
    object miOptAdCmt: TMenuItem
      Caption = 'Add Comment'
    end
    object miOptAdCDT: TMenuItem
      Caption = 'Add CDTD'
    end
    object miOptAdProIns: TMenuItem
      Caption = 'Add Process Instructions'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miOptDlt: TMenuItem
      Caption = 'Delete'
      OnClick = miOptDltClick
    end
  end
end
