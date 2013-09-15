unit UnitClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, ScktComp;

type
  TForm1 = class(TForm)
    ClientSocket: TClientSocket;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CurrentStream: TMemoryStream;
  Current:TBitmap;
    Cur:TMemoryStream;
implementation

{$R *.dfm}

procedure TForm1.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
    buf: array[0..65535] of byte;
    index:byte;

begin
    Socket.ReceiveBuf(buf[0], Socket.ReceiveLength);
    CurrentStream.WriteBuffer(buf[0], 49206);
    index:=buf[49206];
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
CurrentStream:= TMemoryStream.Create;
cur := TMemoryStream.Create;
Current := TBitmap.Create;
end;

end.
