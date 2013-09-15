object Form1: TForm1
  Left = 333
  Top = 311
  Width = 928
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ClientSocket: TClientSocket
    Active = True
    Address = '127.0.0.1'
    ClientType = ctNonBlocking
    Host = '127.0.0.1'
    Port = 6889
    OnRead = ClientSocketRead
    Left = 328
    Top = 96
  end
end
