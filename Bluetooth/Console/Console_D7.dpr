program Console_D7;

{$I wcl.inc}

{$APPTYPE CONSOLE}

uses
  main in 'main.pas';

var
  Console: TwclConsole;

begin
  Console := TwclConsole.Create;
  Console.Run;
  Console.Free;
end.
