object ServerForm: TServerForm
  Left = 96
  Top = 125
  Width = 928
  Height = 480
  Caption = 'ServerForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object TimerScreenshot: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerScreenshotTimer
    Left = 152
    Top = 40
  end
  object ServerSocket: TServerSocket
    Active = True
    Port = 6889
    ServerType = stNonBlocking
    Left = 208
    Top = 40
  end
end
