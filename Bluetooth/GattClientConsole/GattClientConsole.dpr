program GattClientConsole;

{$MODE Delphi}

{$APPTYPE CONSOLE}

uses
  main in 'main.pas';

begin
  with TGattClientApplication.Create do begin
    Run;
    Free;
  end;

  Writeln('Press ENTER to exit');
  Readln;
end.
