unit ufinmath_poc;

{ Biblioteca minima de funcoes matematicas puras — POC FPCUnit }

{$mode objfpc}{$H+}

interface

function Arredonda(Valor: Double): Double;
function PMTPrice(PV, I: Double; N: Integer): Double;
function DescontoPorIsencao(Mora, Corr, Multa: Double; IsenMora, IsenCorr, IsenMulta: boolean): Double;
function JurosProRata(SaldoDev, IndJuros: Double; DiasProRata: Integer): Double;

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

{ Replica exata de TParcelaReneg.DescontoPorIsencao em ucontrato.pas }
function DescontoPorIsencao(Mora, Corr, Multa: Double; IsenMora, IsenCorr, IsenMulta: boolean): Double;
begin
  Result := 0;
  if IsenMora  then Result := Result + Mora;
  if IsenCorr  then Result := Result + Corr;
  if IsenMulta then Result := Result + Multa;
end;

{ IndJuros e a taxa mensal em decimal (ex: 0.01 = 1% a.m.)
  Expoente DiasProRata/30 converte dias corridos em fracao do mes }
function JurosProRata(SaldoDev, IndJuros: Double; DiasProRata: Integer): Double;
begin
  Result := SaldoDev * (Power(1 + IndJuros, DiasProRata / 30) - 1);
end;

end.
