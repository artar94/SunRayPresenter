object ClientForm: TClientForm
  Left = 177
  Top = 146
  BorderStyle = bsNone
  Caption = 'ClientForm'
  ClientHeight = 398
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
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
