program Console;

{$MODE Delphi}

{$APPTYPE CONSOLE}

uses
  main in 'main.pas';

var
  ConsoleApp: TwclConsole;

begin
  ConsoleApp := TwclConsole.Create;
  ConsoleApp.Run;
  ConsoleApp.Free;
end.
