object frmMain: TfrmMain
  Left = 573
  Top = 154
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
    SimplePanel = True
  end
  object pnlRawView: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 722
    Align = alClient
    TabOrder = 1
    Visible = False
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
      PopupMenu = popOpt
      TabOrder = 1
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <
        item
          Position = 0
          Text = 'Element'
          Width = 200
        end>
    end
  end
  object pnlVstView: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 722
    Align = alClient
    TabOrder = 2
    object vstContent: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 782
      Height = 720
      Align = alClient
      DefaultNodeHeight = 19
      Header.AutoSizeIndex = 0
      Header.Height = 15
      PopupMenu = popOpt
      TabOrder = 0
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <
        item
          Position = 0
          Text = 'Value'
          Width = 200
        end
        item
          Position = 1
        end>
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
      Caption = 'Add Text '
      OnClick = miOptAdTxtClick
    end
    object miOptAdCmt: TMenuItem
      Caption = 'Add Comment'
      OnClick = miOptAdCmtClick
    end
    object miOptAdCDT: TMenuItem
      Caption = 'Add CDATA'
      OnClick = miOptAdCDTClick
    end
    object miOptAdProIns: TMenuItem
      Caption = 'Add Processing Instruction'
      OnClick = miOptAdProInsClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object miOptDlt: TMenuItem
      Caption = 'Delete'
      OnClick = miOptDltClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miOptExp: TMenuItem
      Caption = 'Expand'
      OnClick = miOptExpClick
    end
    object miOptClps: TMenuItem
      Caption = 'Collapse'
      OnClick = miOptClpsClick
    end
  end
end
