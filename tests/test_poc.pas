unit test_poc;

{ Suite minima FPCUnit — POC de validacao do ambiente }

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry;

type
  TTestArredonda = class(TTestCase)
  published
    { 1.006*100=100.6 → Int(101.1)=101 → 1.01  (inequivoco: claramente acima de .5) }
    procedure Arredonda_1006_RetornaUmVirgulaCero1;
    procedure Arredonda_1004_RetornaUmVirgulaCero0;
    procedure Arredonda_Negativo_1006_RetornaMenosUmVirgulaCero1;
    procedure Arredonda_Zero_RetornaZero;
    { 1.005 em IEEE 754 = 1.00499... → arredonda para BAIXO — comportamento real do sistema }
    procedure Arredonda_1005_IEEE754_RetornaUmVirgulaCero0;
  end;

  TTestPMTPrice = class(TTestCase)
  published
    procedure PMT_100k_1pct_120meses_Retorna143471;
    procedure PMT_TaxaZero_RetornaPVdivN;
    procedure PMT_1mes_RetornaPVvezesMaisJuros;
  end;

  TTestDescontoPorIsencao = class(TTestCase)
  published
    procedure Desconto_SemIsencao_RetornaZero;
    procedure Desconto_IsenMora_RetornaMora;
    procedure Desconto_IsenCorr_RetornaCorr;
    procedure Desconto_TodasIsencoes_RetornaSoma;
  end;

  TTestJurosProRata = class(TTestCase)
  published
    { 10000 * (1.01^1 - 1) = 100.00 (mes completo = taxa cheia) }
    procedure JurosProRata_MesCompleto_RetornaTaxaCheia;
    { 10000 * (1.01^0.5 - 1) = 49.88 (meio mes) }
    procedure JurosProRata_MeiaMes_Retorna4988;
    procedure JurosProRata_TaxaZero_RetornaZero;
    procedure JurosProRata_DiasZero_RetornaZero;
  end;

implementation

uses ufinmath_poc;

const
  DELTA_CENTAVO = 0.005; { tolerancia de meio centavo }
  DELTA_TAXA    = 1e-6;  { tolerancia para taxas }

{ --- TTestArredonda --- }

procedure TTestArredonda.Arredonda_1006_RetornaUmVirgulaCero1;
begin
  { 1.006 * 100 = 100.6 → Int(101.1) = 101 → 1.01 }
  AssertEquals('1.006 deve arredondar para 1.01', 1.01, Arredonda(1.006), DELTA_CENTAVO);
end;

procedure TTestArredonda.Arredonda_1004_RetornaUmVirgulaCero0;
begin
  AssertEquals('1.004 deve arredondar para 1.00', 1.00, Arredonda(1.004), DELTA_CENTAVO);
end;

procedure TTestArredonda.Arredonda_Negativo_1006_RetornaMenosUmVirgulaCero1;
begin
  AssertEquals('-1.006 deve arredondar para -1.01', -1.01, Arredonda(-1.006), DELTA_CENTAVO);
end;

procedure TTestArredonda.Arredonda_Zero_RetornaZero;
begin
  AssertEquals('Zero deve retornar zero', 0.00, Arredonda(0.0), DELTA_CENTAVO);
end;

procedure TTestArredonda.Arredonda_1005_IEEE754_RetornaUmVirgulaCero0;
begin
  { IMPORTANTE: 1.005 em IEEE 754 double = 1.004999999...
    Int(1.004999*100 + 0.5) = Int(100.9999) = 100 → resultado = 1.00
    Este e o comportamento REAL do sistema Prognum — nao e bug, e a precisao do tipo Double. }
  AssertEquals('1.005 IEEE754 arredonda para BAIXO (1.00)', 1.00, Arredonda(1.005), DELTA_CENTAVO);
end;

{ --- TTestPMTPrice --- }

procedure TTestPMTPrice.PMT_100k_1pct_120meses_Retorna143471;
begin
  { PMT = 100000 * 0.01 / (1 - 1.01^(-120)) = 1434.71 }
  AssertEquals('PMT PRICE 100k/1%/120m', 1434.71, PMTPrice(100000.0, 0.01, 120), DELTA_CENTAVO);
end;

procedure TTestPMTPrice.PMT_TaxaZero_RetornaPVdivN;
begin
  { Com taxa zero: PMT = PV / N = 12000 / 12 = 1000 }
  AssertEquals('PMT com taxa zero = PV/N', 1000.00, PMTPrice(12000.0, 0.0, 12), DELTA_CENTAVO);
end;

procedure TTestPMTPrice.PMT_1mes_RetornaPVvezesMaisJuros;
begin
  { n=1: PMT = PV * i / (1-(1+i)^-1) = PV * i / (i/(1+i)) = PV * (1+i) }
  AssertEquals('PMT n=1 = PV*(1+i)', 10100.00, PMTPrice(10000.0, 0.01, 1), DELTA_CENTAVO);
end;

{ --- TTestDescontoPorIsencao --- }

procedure TTestDescontoPorIsencao.Desconto_SemIsencao_RetornaZero;
begin
  AssertEquals('Sem isencao → 0', 0.0, DescontoPorIsencao(50, 30, 20, False, False, False), DELTA_CENTAVO);
end;

procedure TTestDescontoPorIsencao.Desconto_IsenMora_RetornaMora;
begin
  AssertEquals('Isen mora → 50', 50.0, DescontoPorIsencao(50, 30, 20, True, False, False), DELTA_CENTAVO);
end;

procedure TTestDescontoPorIsencao.Desconto_IsenCorr_RetornaCorr;
begin
  AssertEquals('Isen corr → 30', 30.0, DescontoPorIsencao(50, 30, 20, False, True, False), DELTA_CENTAVO);
end;

procedure TTestDescontoPorIsencao.Desconto_TodasIsencoes_RetornaSoma;
begin
  { 50 + 30 + 20 = 100 }
  AssertEquals('Todas isencoes → 100', 100.0, DescontoPorIsencao(50, 30, 20, True, True, True), DELTA_CENTAVO);
end;

{ --- TTestJurosProRata --- }

procedure TTestJurosProRata.JurosProRata_MesCompleto_RetornaTaxaCheia;
begin
  { 10000 * (1.01^(30/30) - 1) = 10000 * 0.01 = 100.00 }
  AssertEquals('JurosProRata mes completo = taxa cheia', 100.00, JurosProRata(10000.0, 0.01, 30), DELTA_CENTAVO);
end;

procedure TTestJurosProRata.JurosProRata_MeiaMes_Retorna4988;
begin
  { 10000 * (1.01^0.5 - 1) = 10000 * 0.004987... = 49.88 }
  AssertEquals('JurosProRata meio mes', 49.88, JurosProRata(10000.0, 0.01, 15), DELTA_CENTAVO);
end;

procedure TTestJurosProRata.JurosProRata_TaxaZero_RetornaZero;
begin
  { (1+0)^n - 1 = 0 }
  AssertEquals('JurosProRata taxa zero = 0', 0.00, JurosProRata(10000.0, 0.0, 30), DELTA_CENTAVO);
end;

procedure TTestJurosProRata.JurosProRata_DiasZero_RetornaZero;
begin
  { (1+i)^0 - 1 = 0 }
  AssertEquals('JurosProRata dias zero = 0', 0.00, JurosProRata(10000.0, 0.01, 0), DELTA_CENTAVO);
end;

initialization
  RegisterTest(TTestArredonda);
  RegisterTest(TTestPMTPrice);
  RegisterTest(TTestDescontoPorIsencao);
  RegisterTest(TTestJurosProRata);

end.
