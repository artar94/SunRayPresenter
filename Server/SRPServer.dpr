program SRPServer;

uses
  Forms,
  UnitServer in 'UnitServer.pas' {ServerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
