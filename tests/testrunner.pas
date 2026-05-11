program testrunner;

{ Runner de linha de comando para a suite FPCUnit }

{$mode objfpc}{$H+}

uses
  Classes, consoletestrunner,
  test_poc; { garante que a unit e registrada via initialization }

var
  Application: TTestRunner;

begin
  Application := TTestRunner.Create(nil);
  Application.Initialize;
  Application.Run;
  Application.Free;
end.
