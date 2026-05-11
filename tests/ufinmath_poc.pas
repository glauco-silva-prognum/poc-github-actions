unit ufinmath_poc;

{ Biblioteca minima de funcoes matematicas puras — POC FPCUnit }

{$mode objfpc}{$H+}

interface

function Arredonda(Valor: Double): Double;
function PMTPrice(PV, I: Double; N: Integer): Double;

implementation

uses Math;

{ Replica exata de int(Valor*100+0.5)/100 do ucontrato.pas }
function Arredonda(Valor: Double): Double;
begin
  if Valor >= 0 then
    Result := Int(Valor * 100 + 0.5) / 100
  else
    Result := -Int(Abs(Valor) * 100 + 0.5) / 100;
end;

{ CalcAmaisJ() — PMT = PV * i / (1 - (1+i)^(-n)) }
function PMTPrice(PV, I: Double; N: Integer): Double;
begin
  if Abs(I) < 1e-10 then
    Result := PV / N
  else
    Result := PV * I / (1 - Power(1 + I, -N));
end;

end.
