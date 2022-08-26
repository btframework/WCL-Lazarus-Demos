program BleSniffer_D7;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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
