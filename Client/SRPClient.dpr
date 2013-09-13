program SRPClient;

uses
  Forms,
  UnitClient in 'UnitClient.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
