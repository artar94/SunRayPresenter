unit UnitClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, ScktComp, ExtCtrls, StdCtrls;

const
  SunWidth = 1280;
  SunHeight = 1024;

  TileSize = 128;

  TileCountLine = SunHeight div TileSize;
  TileCountColumn = SunWidth div TileSize;
  TileCount = TileCountLine * TileCountColumn;

type
  TClientForm = class(TForm)
    ClientSocket: TClientSocket;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
  private
    procedure Init;
    procedure Paint(index: byte);
  public
    { Public declarations }
  end;

var
  ClientForm: TClientForm;

  CurrentStream: TMemoryStream;

  CBmp, CTileBmp: TBitmap;

  count: Int64;

implementation

{$R *.dfm}

procedure TClientForm.Init;
begin
  CBmp:= TBitmap.Create;
  CBmp.Width:= SunWidth;
  CBmp.Height:= SunHeight;
  CBmp.PixelFormat:= pf24bit;

  CTileBmp:= TBitmap.Create;
  CTileBmp.Width:= SunWidth;
  CTileBmp.Height:= SunHeight;
  CTileBmp.PixelFormat:= pf24bit;

  count:= 0;
end;

procedure TClientForm.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  buf: array[0..65535] of byte;
  index:byte;
begin
  Sleep(10);
  CurrentStream.Clear;
  CurrentStream.Seek(0, soFromBeginning);
  //Memo1.Lines.Add(IntToStr(Socket.ReceiveLength));
  Socket. ReceiveBuf(buf[0], Socket.ReceiveLength);
  CurrentStream.WriteBuffer(buf[0], 49206);
  index:=buf[49206];

  CurrentStream.Seek(0, soFromBeginning);
  CTileBmp.LoadFromStream(CurrentStream);

  Paint(index);
end;

procedure TClientForm.FormCreate(Sender: TObject);
begin
  Init;
  CurrentStream:= TMemoryStream.Create;
end;



procedure TClientForm.Paint(index: byte);
begin
  BitBlt(CBmp.Canvas.Handle,
         (index mod TileCountColumn) * TileSize,
         (index div TileCountColumn) * TileSize,
         TileSize, TileSize,
         CTileBmp.Canvas.Handle,
         0,0, SRCCOPY);

  BitBlt(ClientForm.Canvas.Handle,
         0, 0,
         ClientForm.ClientWidth, ClientForm.ClientHeight,
         CBmp.Canvas.Handle,
         0,0, SRCCOPY);
end;

end.
