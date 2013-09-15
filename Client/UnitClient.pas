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
    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    procedure Init;
    procedure Paint(index: byte);
  public
    { Public declarations }
  end;

  TPacket = array[0..65535] of byte;


  TElem = record
    Packet: TPacket;
    Index : Byte;
  end;
  PNode = ^Node; // ??? ????????? ?? ??????? ???????
  Node = record  // ??????? ???????
    Elem : TElem;
    next : PNode;
  end;

  TQueue = record // ???????
    first:  PNode;
    last:   PNode;
  end;
var
  ClientForm: TClientForm;

  CurrentStream: TMemoryStream;

  CBmp, CTileBmp: TBitmap;

  count: Int64;

  PacketList: TList;

  buf: TPacket;

  ptr: integer;

  Q: TQueue;
implementation

{$R *.dfm}

procedure QueueInit(var Q: TQueue); // ????????????? ???????
begin
  Q.first:= nil;
  Q.last:=  nil;
end;

function QueueIsEmpty(const Q: TQueue):boolean; // ???????? ??????? ?? ???????
begin
  Result:= (Q.first = nil) and (Q.last = nil);
end;

function QueuePop(var Q: TQueue):TElem; // ????????? ???????? ?? ???????
var
  d:PNode;
begin
  Result:= Q.first^.Elem;
  if Q.first <> Q.last then begin
    d:= Q.first;
    Q.first:= Q.first^.next;
    Dispose(d);
  end else begin
    Dispose(Q.first);
    Q.first:= nil;
    Q.last:=  nil;
  end;
end;

procedure QueueClean(var Q: TQueue); // ??????? ???????
begin
  while not QueueIsEmpty(Q) do
    QueuePop(Q);
end;

procedure QueuePush(var Q: TQueue; E:TElem); // ????????? ???????? ? ???????
var
  x:PNode;
begin
  New(x);
  x^.Elem:= E;
  if QueueIsEmpty(Q) then begin
    Q.first:= x;
    Q.last:=  x;
  end else begin
    Q.last^.next:=  x;
    Q.last:=        x;
  end;
end;

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

  PacketList := TList.Create;
  ptr:=0;
  QueueInit(Q);
end;

procedure TClientForm.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  size: integer;
  index:byte;
  cur: TElem;
begin
  CurrentStream.Clear;
  CurrentStream.Seek(0, soFromBeginning);
  size:=Socket.ReceiveLength;
  //Memo1.Lines.Add(IntToStr(Socket.ReceiveLength));
  if ptr+size>65536 then begin
      Socket.ReceiveBuf(buf[ptr],65536-ptr);
      cur.Index:=buf[49206];
      cur.Packet:=buf;
      QueuePush(q,cur);
      ptr:=0;
      size:=Socket.ReceiveLength;
      Socket.ReceiveBuf(buf[ptr],size);
  end
  else begin
      Socket.ReceiveBuf(buf[ptr],size);
      ptr := ptr+size;
      if ptr=65536 then begin
          cur.Index:=buf[49206];
          cur.Packet:=buf;
          QueuePush(q,cur);
          ptr:=0;
      end;
  end;

  //CurrentStream.WriteBuffer(buf[0], 49206);


  //CurrentStream.Seek(0, soFromBeginning);
  //CTileBmp.LoadFromStream(CurrentStream);

  //Paint(index);
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

procedure TClientForm.Button1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TClientForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #27 then Close;
end;

end.
