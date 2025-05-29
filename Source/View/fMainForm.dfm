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
  object sbStatus: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <>
    ExplicitLeft = 320
    ExplicitTop = 240
    ExplicitWidth = 0
  end
  object pnlRawView: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 422
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 232
    ExplicitTop = 232
    ExplicitWidth = 185
    ExplicitHeight = 41
    object splRawView: TSplitter
      Left = 122
      Top = 1
      Height = 420
      ExplicitLeft = 120
      ExplicitTop = 264
      ExplicitHeight = 100
    end
    object tvRawXmlStructure: TTreeView
      Left = 1
      Top = 1
      Width = 121
      Height = 420
      Align = alLeft
      Indent = 19
      TabOrder = 0
      ExplicitLeft = 256
      ExplicitTop = 160
      ExplicitHeight = 97
    end
    object memRawXml: TMemo
      Left = 125
      Top = 1
      Width = 498
      Height = 420
      Align = alClient
      Lines.Strings = (
        'memRawXml')
      TabOrder = 1
      ExplicitLeft = 224
      ExplicitTop = 168
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
  object pnlVstView: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 422
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 232
    ExplicitTop = 232
    ExplicitWidth = 185
    ExplicitHeight = 41
  end
  object mmMain: TMainMenu
    Left = 608
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
    object mmView: TMenuItem
      Caption = 'View'
      object miViewToggle: TMenuItem
        Caption = 'Toggle View'
      end
    end
  end
  object popOpt: TPopupMenu
    Left = 600
    Top = 56
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
