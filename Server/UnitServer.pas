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

  TBmpArray = array [1..TileCount] of TBitmap;

  TTileUpdateIndex = set of 1..TileCount;

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

  for i:= 1 to TileCount do
    SBmpArray[i]:= TBitmap.Create;

  SCursorIcon:= TIcon.Create;

  SBmp:= TBitmap.Create;
  SBmp.Width:= SunWidth;
  SBmp.Height:= SunHeight;
  SBmp.PixelFormat:= pf32bit;

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

  for i:= 1 to TileCount do
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


procedure TServerForm.UpdateBmpArray(var TileUpdateIndex: TTileUpdateIndex);
var
  i, j: integer;
  TileIndex: integer;
begin
  for i:= 1 to TileCountLine do
    for j:= 1 to TileCountColumn do begin
      BitBlt(STileBmp.Canvas.Handle, 0,0, TileSize,TileSize,
             SBmp.Canvas.Handle, (j-1)*TileSize, (i-1)*TileSize, SRCCOPY);
      TileIndex:= TileCountColumn*(i-1) + j;
      if STileBmp <> SBmpArray[TileIndex] then begin
        TileUpdateIndex:= TileUpdateIndex + [TileIndex];
        SBmpArray[TileIndex]:= STileBmp;
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
begin
  ScreenShot;
  UpdateBmpArray(TileUpdateIndex);

  

  BitBlt(ServerForm.Canvas.Handle, 0,0,ServerForm.ClientWidth,ServerForm.ClientHeight,
         SBmp.Canvas.Handle, 0,0,SRCCOPY);
end;


end.
