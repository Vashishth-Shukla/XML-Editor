object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'My XML Editor'
  ClientHeight = 741
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmMain
  Position = poDesigned
  TextHeight = 15
  object sbStatus: TStatusBar
    Left = 0
    Top = 722
    Width = 784
    Height = 19
    Panels = <>
    ExplicitLeft = -8
    ExplicitTop = 414
    ExplicitWidth = 624
  end
  object pnlRawView: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 722
    Align = alClient
    TabOrder = 1
    Visible = False
    ExplicitWidth = 614
    ExplicitHeight = 390
    object splRawView: TSplitter
      Left = 201
      Top = 1
      Height = 720
      ExplicitTop = 2
      ExplicitHeight = 420
    end
    object memRawXml: TMemo
      Left = 204
      Top = 1
      Width = 579
      Height = 720
      Align = alClient
      Lines.Strings = (
        'memRawXml')
      TabOrder = 0
      ExplicitWidth = 409
      ExplicitHeight = 388
    end
    object vstRawXmlStructure: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 200
      Height = 720
      Align = alLeft
      DefaultNodeHeight = 19
      Header.AutoSizeIndex = 0
      Header.Height = 15
      Header.MainColumn = -1
      TabOrder = 1
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      ExplicitHeight = 420
      Columns = <>
    end
  end
  object pnlVstView: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 722
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 614
    ExplicitHeight = 390
    object vstContent: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 782
      Height = 720
      Align = alClient
      DefaultNodeHeight = 19
      Header.AutoSizeIndex = 0
      Header.Height = 15
      Header.MainColumn = -1
      TabOrder = 0
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      ExplicitLeft = 17
      ExplicitTop = 121
      ExplicitWidth = 622
      ExplicitHeight = 420
      Columns = <>
    end
  end
  object mmMain: TMainMenu
    Left = 752
    Top = 8
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
      object N1: TMenuItem
        Caption = '-'
      end
      object miFileExit: TMenuItem
        Caption = 'Exit'
        OnClick = miFileExitClick
      end
    end
    object mmView: TMenuItem
      Caption = 'View'
      object miViewToggle: TMenuItem
        Caption = 'Toggle View'
        OnClick = miViewToggleClick
      end
    end
  end
  object popOpt: TPopupMenu
    Left = 752
    Top = 64
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
      Caption = 'Add Text '
    end
    object miOptAdCmt: TMenuItem
      Caption = 'Add Comment'
    end
    object miOptAdCDT: TMenuItem
      Caption = 'Add CDATA'
    end
    object miOptAdProIns: TMenuItem
      Caption = 'Add Processing Instruction'
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object miOptDlt: TMenuItem
      Caption = 'Delete'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miOptExp: TMenuItem
      Caption = 'Expand'
    end
    object miOptClps: TMenuItem
      Caption = 'Collapse'
    end
  end
end
