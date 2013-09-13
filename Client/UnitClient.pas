unit UnitClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, ScktComp;

type
  TForm1 = class(TForm)
    ClientSocket: TClientSocket;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Socket.
end;

end.
