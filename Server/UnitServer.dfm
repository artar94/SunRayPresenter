object ServerForm: TServerForm
  Left = 190
  Top = 123
  Width = 573
  Height = 473
  Caption = 'ServerForm'
  Color = clWhite
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
    Interval = 100
    OnTimer = TimerScreenshotTimer
    Left = 8
  end
  object ServerSocket: TServerSocket
    Active = True
    Port = 6889
    ServerType = stNonBlocking
    Left = 64
  end
end
