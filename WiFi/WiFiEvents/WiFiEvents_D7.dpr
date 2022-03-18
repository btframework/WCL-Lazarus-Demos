program WiFiEvents_D7;

{$I wcl.inc}

uses
  Interfaces,
  Forms,
  main in 'main.pas' {fmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
