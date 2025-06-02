object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 741
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmMain
  OnCreate = FormCreate
  TextHeight = 15
  object vstContent: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 584
    Height = 722
    Align = alClient
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 0
    Header.Height = 15
    Header.MainColumn = -1
    PopupMenu = popOpt
    TabOrder = 0
    OnDblClick = vstContentDblClick
    OnEditing = vstContentEditing
    OnNewText = vstContentNewText
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    ExplicitWidth = 624
    ExplicitHeight = 422
    Columns = <>
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 722
    Width = 584
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 422
    ExplicitWidth = 624
  end
  object mmMain: TMainMenu
    Left = 592
    Top = 16
    object mmFile: TMenuItem
      Caption = 'File'
      object miFileNew: TMenuItem
        Caption = 'New'
        OnClick = miFileNewClick
      end
      object miFileOpen: TMenuItem
        Caption = 'Open...'
        OnClick = miFileOpenClick
      end
      object miFileSave: TMenuItem
        Caption = 'Save'
        OnClick = miFileSaveClick
      end
      object miFileSaveAs: TMenuItem
        Caption = 'Save As...'
        OnClick = miFileSaveAsClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miFileExit: TMenuItem
        Caption = 'Exit'
        OnClick = miFileExitClick
      end
    end
  end
  object popOpt: TPopupMenu
    Left = 592
    Top = 80
    object miOptAdElem: TMenuItem
      Caption = 'Add Element'
      OnClick = miOptAdElemClick
      object miOptAdElmBfr: TMenuItem
        Caption = 'Before'
        OnClick = miOptAdElmBfrClick
      end
      object miOptAdElmAft: TMenuItem
        Caption = 'After'
        OnClick = miOptAdElmAftClick
      end
      object miOptAdElmCld: TMenuItem
        Caption = 'Child'
        OnClick = miOptAdElmCldClick
      end
    end
    object miOptAdAttri: TMenuItem
      Caption = 'Add Attribute'
      OnClick = miOptAdAttriClick
    end
    object miOptAdTxt: TMenuItem
      Caption = 'Add Text'
      OnClick = miOptAdTxtClick
    end
    object miOptAdCmt: TMenuItem
      Caption = 'Add Comment'
      OnClick = miOptAdCmtClick
    end
    object miOptAdCDT: TMenuItem
      Caption = 'Add CDTD'
      OnClick = miOptAdCDTClick
    end
    object miOptAdProIns: TMenuItem
      Caption = 'Add Process Instructions'
      Enabled = False
      OnClick = miOptAdProInsClick
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
