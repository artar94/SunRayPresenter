unit UnitServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ScktComp;

const
  SunWidth = 1280;
  SunHeight = 1024;

  TileSize = 128;

  TileCountLine = SunHeight div TileSize;
  TileCountColumn = SunWidth div TileSize;
  TileCount = TileCountLine * TileCountColumn;

type
  TTile = record
    bmp: TBitmap;
    index: Cardinal;
  end;

  TPixel = record
    R,G,B: byte;
  end;
  TPixelArray  = array[0..$effffff] of TPixel;
  PTPixelArray = ^TPixelArray;

  TBmpArray = array [0..TileCount - 1] of TBitmap;

  TTileUpdateIndex = set of 0..TileCount - 1;

type
  TServerForm = class(TForm)
    TimerScreenshot: TTimer;
    ServerSocket: TServerSocket;
    procedure FormCreate(Sender: TObject);
    procedure TimerScreenshotTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure Init;
    procedure Finish;
    procedure ScreenShot;
    procedure UpdateBmpArray(var TileUpdateIndex: TTileUpdateIndex);
    function EqualsBitmap(index: integer): boolean;
  public
    { Public declarations }
  end;

var
  ServerForm: TServerForm;
  // Serv
  SBmp, STileBmp: TBitmap;
  SScreenDC: HDC;
  SCursorIcon: TIcon;
  SBmpArray: TBmpArray;
  STileUpdateIndex: TTileUpdateIndex;

implementation

{$R *.dfm}

procedure TServerForm.Init;
var
  i: integer;
begin
  SScreenDC:= CreateDC('DISPLAY', '',nil,nil);

  for i:= 0 to TileCount - 1 do begin
    SBmpArray[i]:= TBitmap.Create;
    SBmpArray[i].PixelFormat:= pf24bit;
    SBmpArray[i].Width:= TileSize;
    SBmpArray[i].Height:= TileSize;
    SBmpArray[i].Canvas.FillRect(Rect(0, 0, TileSize - 1, TileSize - 1));
  end;

  SCursorIcon:= TIcon.Create;

  SBmp:= TBitmap.Create;
  SBmp.Width:= SunWidth;
  SBmp.Height:= SunHeight;
  SBmp.PixelFormat:= pf24bit;

  STileBmp:= TBitmap.Create;
  STileBmp.Width:= TileSize;
  STileBmp.Height:= TileSize;

  TimerScreenshot.Enabled:= true;
end;

procedure TServerForm.Finish;
var
  i: integer;
begin
  TimerScreenshot.Enabled:= false;

  STileBmp.Free;

  SBmp.Free;

  SCursorIcon.Free;

  for i:= 0 to TileCount - 1 do
    SBmpArray[i].FreeImage;

  ReleaseDC(0, SScreenDC);
end;

procedure TServerForm.ScreenShot;
var
  CP: TPoint;
  CursorInfo: TCursorInfo;
  IconInfo: TIconInfo;
begin
  BitBlt(SBmp.Canvas.Handle, 0,0,SBmp.Width,SBmp.Height, SScreenDC, 0,0,SRCCOPY);

  CursorInfo.cbSize:= SizeOf(TCursorInfo);
  if GetCursorInfo(CursorInfo) then
    if CursorInfo.hCursor <> 0 then
      if GetIconInfo(CursorInfo.hCursor, IconInfo) then begin
        if not IconInfo.fIcon then begin
          CP:= CursorInfo.ptScreenPos;

          DrawIcon(SBmp.Canvas.Handle,
                   CP.X - Integer(IconInfo.xHotspot),
                   CP.Y - Integer(IconInfo.yHotspot),
                   CursorInfo.hCursor);
        end;
        DeleteObject(IconInfo.hbmMask);
        DeleteObject(IconInfo.hbmColor);
      end;
end;

function TServerForm.EqualsBitmap(index: integer): boolean;
var
  i,j: integer;
  PT, PB : PTPixelArray;
  Line, Col: integer;
  PixelT, PixelB: TPixel;
begin
  Result:= false;
  Line:=  (index div TileCountColumn) * TileSize;
  Col:=   (index mod TileCountColumn) * TileSize;
  for i:= 0 to TileSize - 1 do begin
    PT:= SBmpArray[index].ScanLine[i];
    PB:= SBmp.ScanLine[Line + i];
    for j:= 0 to TileSize - 1 do begin
      PixelT:= PT^[j];
      PixelB:= PB^[Col + j];
      if (PixelT.R <> PixelB.R) or (PixelT.G <> PixelB.G) or (PixelT.B <> PixelB.B) then Exit;
    end;
  end;
  Result:= true;
end;

procedure TServerForm.UpdateBmpArray(var TileUpdateIndex: TTileUpdateIndex);
var
  i: integer;
begin
  TileUpdateIndex:= [];

  for i:= 0 to TileCount - 1 do begin
    if not EqualsBitmap(i) then begin
      BitBlt(SBmpArray[i].Canvas.Handle, 0,0, TileSize,TileSize,
             SBmp.Canvas.Handle,
             (i mod TileCountColumn) * TileSize,
             (i div TileCountColumn) * TileSize,
             SRCCOPY);
      TileUpdateIndex:= TileUpdateIndex + [i];
    end;
  end;
end;

procedure TServerForm.FormCreate(Sender: TObject);
begin
  Init;
end;

procedure TServerForm.FormDestroy(Sender: TObject);
begin
  Finish;
end;

procedure TServerForm.TimerScreenshotTimer(Sender: TObject);
var
  TileUpdateIndex: TTileUpdateIndex;
  i,j: integer;
  Size: integer;
  CurrentStream: TMemoryStream;
  buf: array of byte;
begin
  ScreenShot;
  UpdateBmpArray(TileUpdateIndex);

  // DEBUG
  Self.Caption:='';
  for i:=0 to TileCount - 1 do begin
     if i in TileUpdateIndex then
      Self.Caption:= Self.Caption + IntToStr(i) + ' ';
  end;
  // ENDDEBUG

  for i:=0 to ServerSocket.Socket.ActiveConnections - 1 do
    for j:=0 to TileCount - 1 do
      if j in TileUpdateIndex then begin
        CurrentStream:= TMemoryStream.Create;
        SBmpArray[j].SaveToStream(CurrentStream);
        CurrentStream.Seek(0, soFromBeginning);
        Size := CurrentStream.Size;
        SetLength(buf,Size);
        CurrentStream.ReadBuffer(buf[0],Size);
        ServerSocket.Socket.Connections[i].SendBuf(buf[0],Length(buf));
        CurrentStream.Free;
      end;

  //BitBlt(ServerForm.Canvas.Handle, 0,0,ServerForm.ClientWidth,ServerForm.ClientHeight,
  //       SBmp.Canvas.Handle, 0,0,SRCCOPY);
end;



end.
