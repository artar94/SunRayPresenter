program SRPClient;

uses
  Forms,
  UnitClient in 'UnitClient.pas' {ClientForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TClientForm, ClientForm);
  Application.Run;
end.
