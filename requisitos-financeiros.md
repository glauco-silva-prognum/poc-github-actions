# Requisitos Financeiros — ucontrato.pas
## Escopo: Funções Matemáticas Puras (Testáveis em GitHub Actions)

> **Restrições obrigatórias dos testes:**
> - Sem banco de dados
> - Sem leitura/escrita de arquivos em disco
> - Sem dependência de data do sistema (`DataH`, `Now`, `Date`)
> - Cada teste < 10 ms
> - Suíte completa < 30 segundos
> - Apenas funções com entrada → saída determinística

---

## Sumário de Categorias

1. [Conversão de Taxas de Juros](#1-conversão-de-taxas-de-juros)
2. [Juros Simples](#2-juros-simples)
3. [Juros Compostos](#3-juros-compostos)
4. [Juros Pro-Rata](#4-juros-pro-rata)
5. [Juros por Dias Corridos e Úteis](#5-juros-por-dias-corridos-e-úteis)
6. [Juros SCP (Sistema Juros Simples Obrigatório)](#6-juros-scp)
7. [Amortização SAC](#7-amortização-sac)
8. [Amortização PRICE](#8-amortização-price)
9. [Amortização SACRE](#9-amortização-sacre)
10. [Valor Presente e Valor Futuro](#10-valor-presente-e-valor-futuro)
11. [TIR — Taxa Interna de Retorno (Newton-Raphson)](#11-tir--taxa-interna-de-retorno)
12. [Desconto por Antecipação](#12-desconto-por-antecipação)
13. [Multa Contratual](#13-multa-contratual)
14. [Mora (Juros de Atraso)](#14-mora-juros-de-atraso)
15. [Seguros MIP e DFI](#15-seguros-mip-e-dfi)
16. [IOF — Cálculo Puro](#16-iof--cálculo-puro)
17. [IFRS9 / Custo Amortizado](#17-ifrs9--custo-amortizado)
18. [Resíduo e Quitação Antecipada](#18-resíduo-e-quitação-antecipada)
19. [Plano Empresa — Núcleo Matemático](#19-plano-empresa--núcleo-matemático)

---

## 1. Conversão de Taxas de Juros

### 1.1 Taxa Mensal a partir de Taxa Anual Nominal

**Função:** `CalculaJuros()` — `ucontrato.pas` ~l.11014  
**Classificação:** ✅ Puro

**Fórmula:**
```
i_mensal = TxNominal / (12 × 100)
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `TxJuros` | Double | Taxa anual nominal (%) |
| `PerParcelas` | Integer | Periodicidade (12 = mensal) |

**Resultado:** `IndJuros` — fator de juros mensal (decimal)

**Casos de Teste:**
```
TxJuros=12.0, PerParcelas=12 → IndJuros = 0.01 (1% a.m.)
TxJuros=6.0,  PerParcelas=12 → IndJuros = 0.005 (0,5% a.m.)
TxJuros=0.0,  PerParcelas=12 → IndJuros = 0.0
TxJuros=24.0, PerParcelas=12 → IndJuros = 0.02 (2% a.m.)
```

---

### 1.2 Taxa Equivalente Composta (Mensal ↔ Anual)

**Função:** `CalculaJuros()` com `JurosSimples=False`  
**Classificação:** ✅ Puro

**Fórmula:**
```
i_mensal = (1 + i_anual)^(1/12) - 1
i_anual  = (1 + i_mensal)^12 - 1
```

**Casos de Teste:**
```
i_anual=0.12 → i_mensal = (1.12)^(1/12)-1 ≈ 0.009489 (0,9489% a.m.)
i_mensal=0.01 → i_anual = (1.01)^12-1 ≈ 0.126825 (12,6825% a.a.)
i_mensal=0.02 → i_anual = (1.02)^12-1 ≈ 0.268242 (26,8242% a.a.)
```

---

### 1.3 Taxa Periódica para Base Dias Corridos (TpJuros=6)

**Função:** `CalculaJurosPorDiasCorridosOuUteis()` — l.11014  
**Classificação:** ✅ Puro

**Fórmula:**
```
IndJuros = (1 + TxAnual/100)^(Dias/360) - 1
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `TxJuros` | Double | Taxa anual (%) |
| `Dias` | Integer | Número de dias corridos |

**Casos de Teste:**
```
TxJuros=12.0, Dias=30  → IndJuros = (1.12)^(30/360)-1 ≈ 0.009489
TxJuros=12.0, Dias=360 → IndJuros = 0.12
TxJuros=12.0, Dias=15  → IndJuros = (1.12)^(15/360)-1 ≈ 0.004736
TxJuros=6.0,  Dias=30  → IndJuros = (1.06)^(30/360)-1 ≈ 0.004868
```

---

### 1.4 Taxa Periódica para Base Dias Úteis (TpJuros=7)

**Função:** `CalculaJurosPorDiasCorridosOuUteis()` — l.11014  
**Classificação:** ✅ Puro

**Fórmula:**
```
IndJuros = (1 + TxAnual/100)^(DiasUteis/252) - 1
```

**Casos de Teste:**
```
TxJuros=12.0, DiasUteis=21 → IndJuros = (1.12)^(21/252)-1 ≈ 0.009489
TxJuros=12.0, DiasUteis=252→ IndJuros = 0.12
TxJuros=12.0, DiasUteis=10 → IndJuros = (1.12)^(10/252)-1 ≈ 0.004510
```

---

### 1.5 Taxa Juros para Sistema de Fiança (SisAmFianca)

**Função:** `CalculaJurosSisAmFianca()` — l.11335  
**Classificação:** ✅ Puro

**Fórmula:**
```
IndJuros = TxJuros / 360 * Dias / 100
```
*(Juros simples sobre base 360 dias)*

**Casos de Teste:**
```
TxJuros=12.0, Dias=30  → IndJuros = 12.0/360*30/100 = 0.01
TxJuros=12.0, Dias=360 → IndJuros = 0.12
TxJuros=6.0,  Dias=30  → IndJuros = 0.005
```

---

## 2. Juros Simples

### 2.1 Montante por Juros Simples

**Função:** `CalculaJurosSimples()` — l.11113  
**Classificação:** ✅ Puro

**Fórmulas (dos PDFs Prognum):**
```
J = C × i × n
M = C × (1 + i × n)
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `C` (Capital) | Double | Saldo devedor / valor base |
| `i` (IndJuros) | Double | Taxa por período (decimal) |
| `n` (Parcelas) | Integer | Número de períodos |

**Resultado:** `Juros` (J) e `Montante` (M)

**Casos de Teste (PDF: MatematicaFinanceira_MontanteCapitalJuros.pdf):**
```
C=10000.0, i=0.01, n=1 → J=100.00, M=10100.00
C=25000.0, i=0.008, n=6 → J=1200.00, M=26200.00 (juros simples)
C=10000.0, i=0.01, n=12 → J=1200.00, M=11200.00
C=1000.0,  i=0.005, n=24 → J=120.00, M=1120.00
```

**Casos especiais:**
```
i=0.0 → J=0.0, M=C (sem juros)
n=0   → J=0.0, M=C
```

---

## 3. Juros Compostos

### 3.1 Montante por Juros Compostos

**Função:** `CalculaJurosCompostos()` — l.11956  
**Classificação:** ✅ Puro

**Fórmulas (dos PDFs Prognum):**
```
M = C × (1 + i)^n
J = M - C
```

**Casos de Teste (PDF: MatematicaFinanceira_JurosSimplesCompostos.pdf):**
```
C=25000.0, i=0.008, n=6  → M ≈ 26370.94 (compostos)
C=10000.0, i=0.01,  n=12 → M ≈ 11268.25
C=10000.0, i=0.01,  n=1  → M = 10100.00
C=1000.0,  i=0.02,  n=6  → M ≈ 1126.16
```

**Comparação Juros Simples vs Compostos (PDF pág. 6):**
```
C=25000, i=0,8% a.m., n=6,7 meses:
  Simples:   M = 25000×(1+0.008×6.7) = 26340.00
  Compostos: M = 25000×(1.008)^6.7   ≈ 26370.94
```

**Casos especiais:**
```
n=0   → M=C, J=0
i=0.0 → M=C, J=0
n=1   → M=C×(1+i) [equivalente a juros simples]
```

---

## 4. Juros Pro-Rata

### 4.1 Cálculo de Juros Pro-Rata (base 30 dias/mês)

**Função:** `CalcJurosProRata()` — l.39364  
**Classificação:** ✅ Puro

**Fórmula:**
```
FracionMes = DiasProRata / 30
JurosProRata = SaldoDev × ((1 + IndJuros)^FracionMes - 1)
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `SaldoDev` | Double | Saldo devedor |
| `IndJuros` | Double | Taxa mensal (decimal) |
| `DiasProRata` | Integer | Dias fracionados (0–30) |

**Casos de Teste:**
```
SaldoDev=100000.0, IndJuros=0.01, DiasProRata=15
  → FracionMes=0.5, Juros=100000×((1.01)^0.5-1) ≈ 498.76

SaldoDev=100000.0, IndJuros=0.01, DiasProRata=30
  → FracionMes=1.0, Juros=100000×0.01 = 1000.00

SaldoDev=100000.0, IndJuros=0.01, DiasProRata=0
  → Juros=0.0

SaldoDev=200000.0, IndJuros=0.005, DiasProRata=10
  → FracionMes=10/30≈0.3333, Juros≈333.06
```

---

## 5. Juros por Dias Corridos e Úteis

### 5.1 Juros sobre Dias Corridos (TpJuros=6, base 360)

**Função:** `CalculaJurosPorDiasCorridosOuUteis()` — l.11014  
**Classificação:** ✅ Puro

**Fórmula completa:**
```
IndJuros = (1 + TxAnual/100)^(Dias/360) - 1
Juros    = SaldoDev × IndJuros
```

**Casos de Teste:**
```
SaldoDev=100000.0, TxAnual=12.0, Dias=30
  → IndJuros≈0.009489, Juros≈948.88

SaldoDev=100000.0, TxAnual=12.0, Dias=360
  → IndJuros=0.12, Juros=12000.00

SaldoDev=50000.0, TxAnual=6.0, Dias=30
  → IndJuros=(1.06)^(1/12)-1≈0.004868, Juros≈243.40
```

---

### 5.2 Juros sobre Dias Úteis (TpJuros=7, base 252)

**Classificação:** ✅ Puro

**Casos de Teste:**
```
SaldoDev=100000.0, TxAnual=12.0, DiasUteis=21
  → IndJuros=(1.12)^(21/252)-1≈0.009489, Juros≈948.88

SaldoDev=100000.0, TxAnual=12.0, DiasUteis=252
  → Juros=12000.00
```

---

## 6. Juros SCP

### 6.1 Juros Simples Obrigatórios SCP (SistAmort=7)

**Função:** `CalculaJurosSimplesSCP()` — l.11101  
**Classificação:** ✅ Puro

**Regra:** SCP sempre usa juros simples, independente do tipo de juros do contrato.

**Fórmula:**
```
Juros = SaldoDev × TxJuros / 100 / PerParcelas
```
*(Para periodicidade mensal: `PerParcelas=12`)*

**Casos de Teste:**
```
SaldoDev=100000.0, TxJuros=12.0, PerParcelas=12
  → Juros = 100000×0.12/12 = 1000.00

SaldoDev=200000.0, TxJuros=6.0, PerParcelas=12
  → Juros = 200000×0.06/12 = 1000.00
```

---

### 6.2 Juros Simples SCP por Dias Corridos/Úteis

**Função:** `CalculaJurosSCPPorDiasCorridosOuUteis()`  
**Classificação:** ✅ Puro

**Fórmula (dias corridos, base 360):**
```
Juros = SaldoDev × TxJuros / 100 / 360 × Dias
```

**Casos de Teste:**
```
SaldoDev=100000.0, TxJuros=12.0, Dias=30
  → Juros = 100000×0.12/360×30 = 1000.00

SaldoDev=100000.0, TxJuros=12.0, Dias=15
  → Juros = 500.00
```

---

## 7. Amortização SAC

### 7.1 Parcela SAC (Sistema de Amortização Constante)

**Plano:** 112 (ou `SistAmort=1`)  
**Classificação:** ✅ Puro

**Fórmulas:**
```
Amortizacao = SaldoDev / PrazosRestantes
Juros       = SaldoDev × IndJuros
Parcela     = Amortizacao + Juros
SaldoDevNovo= SaldoDev - Amortizacao
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `SaldoDev` | Double | Saldo devedor atual |
| `IndJuros` | Double | Taxa mensal (decimal) |
| `PrazosRestantes` | Integer | Meses restantes |

**Casos de Teste:**
```
Financiamento: 100000.0, taxa=1% a.m., 120 meses

Parcela 1:
  Amort  = 100000/120 = 833.33
  Juros  = 100000×0.01 = 1000.00
  Parcela= 1833.33
  SaldoNovo = 99166.67

Parcela 2:
  Amort  = 99166.67/119 ≈ 833.33
  Juros  = 99166.67×0.01 ≈ 991.67
  Parcela≈ 1825.00

Última parcela:
  Amort  = SaldoRest (quitação total)
  Juros  = SaldoRest×0.01
```

**Invariante SAC:**
```
Amortizacao é constante ao longo do plano:
  Amort = FinanciamentoInicial / PrazoTotal
```

---

## 8. Amortização PRICE

### 8.1 Parcela PRICE (Sistema Francês)

**Plano:** 111 (ou `SistAmort=2`)  
**Função:** `CalcAmaisJ()` — ucontrato.pas  
**Classificação:** ✅ Puro

**Fórmulas:**
```
PMT = PV × i / (1 - (1+i)^(-n))

Juros_k      = SaldoDev_k × i
Amort_k      = PMT - Juros_k
SaldoDev_k+1 = SaldoDev_k - Amort_k
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `PV` | Double | Valor financiado |
| `i` | Double | Taxa mensal (decimal) |
| `n` | Integer | Prazo em meses |

**Casos de Teste:**
```
PV=100000.0, i=0.01, n=120
  PMT = 100000×0.01/(1-1.01^(-120))
      = 1000/(1-0.302995) ≈ 1434.71

Parcela 1:
  Juros  = 100000×0.01 = 1000.00
  Amort  = 1434.71-1000.00 = 434.71
  Saldo  = 99565.29

Parcela 120 (última):
  Parcela≈1434.71 (constante)
  Amort > Juros (amortizacao crescente)
```

**Casos especiais:**
```
i=0.0 → PMT = PV/n (divisão simples, sem juros)
n=1   → PMT = PV×(1+i)
```

**Verificação (PDF: MatematicaFinanceira_FluxoDeCaixa.pdf):**
```
VP de prestação de 1000 no mês 6 com i=1,2%:
  VP = 1000/(1.012)^6 ≈ 931.48
```

---

## 9. Amortização SACRE

### 9.1 Parcela SACRE (Misto SAC/PRICE)

**Plano:** 86 ou 76 (onde `Plano mod 10 = SACR`)  
**Função:** `MontaParcelasSacre()`  
**Classificação:** ✅ Puro

**Regra:** Amortização calculada como PRICE, mas parcela decresce como SAC quando atualização monetary supera amortização calculada.

**Fórmulas:**
```
PMT_ref = PV × i / (1-(1+i)^(-n))   {referência PRICE}
Amort_k = PMT_ref - SaldoDev_k × i   {amortização}
Parcela_k = SaldoDev_k × i + Amort_k  {= PMT_ref enquanto saldo não diverge}
```

**Casos de Teste (comportamento básico sem correção monetária):**
```
PV=100000.0, i=0.01, n=120
  → PMT_ref ≈ 1434.71 (idêntico ao PRICE sem correção)
  → Parcela cresce se CM supera amortização prevista
```

---

## 10. Valor Presente e Valor Futuro

### 10.1 Valor Presente

**Classificação:** ✅ Puro

**Fórmula (PDF: MatematicaFinanceira_FluxoDeCaixa.pdf):**
```
VP = VF / (1 + i)^n
```

**Casos de Teste:**
```
VF=1000.0, i=0.012, n=6  → VP = 1000/(1.012)^6 ≈ 931.48
VF=10000.0, i=0.01, n=12 → VP = 10000/(1.01)^12 ≈ 8874.49
VF=500.0,   i=0.005, n=24→ VP = 500/(1.005)^24 ≈ 443.87
VF=1000.0,  i=0.0, n=10  → VP = 1000.0 (sem desconto)
```

---

### 10.2 Valor Futuro

**Classificação:** ✅ Puro

**Fórmula:**
```
VF = VP × (1 + i)^n
```

**Casos de Teste:**
```
VP=10000.0, i=0.01, n=12 → VF = 10000×(1.01)^12 ≈ 11268.25
VP=1000.0,  i=0.008, n=6 → VF = 1000×(1.008)^6  ≈ 1048.77
```

---

### 10.3 Valor Presente de Série de Parcelas (Anuidade)

**Classificação:** ✅ Puro

**Fórmula:**
```
VP = PMT × (1-(1+i)^(-n)) / i
```

**Casos de Teste:**
```
PMT=1434.71, i=0.01, n=120 → VP ≈ 100000.0 (inverso do PRICE)
PMT=1000.0,  i=0.01, n=12  → VP ≈ 11255.08
```

---

## 11. TIR — Taxa Interna de Retorno

### 11.1 Newton-Raphson para TIR

**Função:** `XTIR()` — l.45741  
**Classificação:** ⚠️ Isolável (fluxo de caixa como array puro)

**Algoritmo:**
```
VPL(i) = Σ Fk / (1+i)^k = 0

Iteração Newton-Raphson:
  i_novo = i_atual - VPL(i)/VPL'(i)

Convergência: |VPL(i)| < 0.00000009
Limite: 300 iterações
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `Fluxos[]` | Array[Double] | Fluxo de caixa (F0 negativo) |
| `N` | Integer | Número de períodos |
| `ChuteTIR` | Double | Estimativa inicial |

**Casos de Teste:**
```
Fluxo simples (empréstimo + 3 pagamentos):
  F0=-1000, F1=400, F2=400, F3=400
  TIR ≈ 9.7% a.p. (verificar numericamente)

Fluxo PRICE PV=100000, PMT=1434.71, n=120:
  F0=-100000, F1..120=+1434.71
  TIR = 1.0% a.m. (= taxa usada para calcular)

Convergência:
  Tolerância: 0.00000009
  Máx iterações: 300
```

**Constante hardcoded:** Ano 50 = data zero para cálculo de TIR baseado em datas.

---

### 11.2 VPL — Valor Presente Líquido

**Classificação:** ✅ Puro

**Fórmula:**
```
VPL = Σ(k=0..n) Fk / (1+i)^k
```

**Casos de Teste (PDF: MatematicaFinanceira_FluxoDeCaixa.pdf):**
```
F0=-1000, F1=+600, F2=+600, i=1% a.m.
  VPL = -1000 + 600/1.01 + 600/1.01^2
      = -1000 + 594.06 + 588.18
      ≈ 182.24

VPL=0 quando i = TIR (definição)
```

---

## 12. Desconto por Antecipação

### 12.1 Desconto de Parcelas Vincendas

**Função:** `DescontoPorTaxa()` — l.6680  
**Classificação:** ✅ Puro

**Fórmula:**
```
ValorDescontado = ValorParcela / (1 + IndJuros)^PeríodosAntecipados
Desconto        = ValorParcela - ValorDescontado
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `ValorParcela` | Double | Valor nominal da parcela |
| `IndJuros` | Double | Taxa de desconto mensal |
| `Periodos` | Integer | Meses de antecipação |

**Casos de Teste:**
```
ValorParcela=1000.0, IndJuros=0.01, Periodos=1
  → Descontado = 1000/1.01 ≈ 990.10
  → Desconto   = 9.90

ValorParcela=1000.0, IndJuros=0.01, Periodos=6
  → Descontado = 1000/(1.01)^6 ≈ 942.05
  → Desconto   = 57.95

ValorParcela=1434.71, IndJuros=0.01, Periodos=12
  → Descontado = 1434.71/(1.01)^12 ≈ 1272.57
```

---

### 12.2 Saldo para Quitação (VP de Vincendas)

**Função:** `CalculaSaldoParaQuitacao()` — l.2080  
**Classificação:** ⚠️ Isolável (requer injeção do array de parcelas vincendas)

**Fórmula:**
```
SaldoQuitacao = Σ(k=1..n) Parcela_k / (1 + i)^k
```

**Casos de Teste:**
```
10 parcelas de 1000.0 com i=1% a.m.:
  Saldo = Σ 1000/(1.01)^k para k=1..10
        ≈ 9471.30

5 parcelas de 1434.71 com i=1% a.m.:
  Saldo ≈ 6792.82
```

---

## 13. Multa Contratual

### 13.1 Cálculo de Multa por Atraso

**Função:** `ValorMulta()` — l.36391  
**Classificação:** ✅ Puro

**Fórmula:**
```
Multa = int(Valor × PercMulta / 100 × 100 + 0.5) / 100
```
*(Arredondamento padrão do sistema)*

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `Valor` | Double | Valor base para multa |
| `PercMulta` | Double | Percentual de multa (%) |

**Valores hardcoded:**
- `PA=81`: multa padrão = **2%**

**Casos de Teste:**
```
Valor=1000.0,  PercMulta=2.0  → Multa=20.00
Valor=1500.0,  PercMulta=2.0  → Multa=30.00
Valor=999.99,  PercMulta=2.0  → Multa=20.00
Valor=0.0,     PercMulta=2.0  → Multa=0.00
Valor=1000.0,  PercMulta=0.0  → Multa=0.00
Valor=1000.004,PercMulta=1.0  → Multa=10.00 (arredondamento)
Valor=1000.005,PercMulta=1.0  → Multa=10.01 (arredondamento)
```

---

### 13.2 Arredondamento Padrão do Sistema

**Classificação:** ✅ Puro

**Fórmula:**
```
Arredonda(v) = int(v × 100 + 0.5) / 100
```

**Casos de Teste:**
```
1.004 → 1.00
1.005 → 1.01
1.999 → 2.00
0.001 → 0.00
100.555 → 100.56
-1.005 → verificar comportamento (negativo)
```

---

## 14. Mora (Juros de Atraso)

### 14.1 Juros de Mora Simples (TMora padrão)

**Função:** parte de `CorrecaoJMJCChaves()`  
**Classificação:** ✅ Puro (com parâmetros injetados)

**Fórmula:**
```
VMora = Valor × TxMora × Dias / 36000
```
*(Constante 36000 = 100 × 360 — base 360 dias, taxa em %)*

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `Valor` | Double | Valor em atraso |
| `TxMora` | Double | Taxa de mora anual (%) |
| `Dias` | Integer | Dias de atraso |

**Valores hardcoded:** `36000` (base de cálculo da mora)

**Casos de Teste:**
```
Valor=1000.0, TxMora=12.0, Dias=30
  → VMora = 1000×12×30/36000 = 10.00

Valor=1000.0, TxMora=12.0, Dias=1
  → VMora = 1000×12×1/36000 ≈ 0.33

Valor=1000.0, TxMora=12.0, Dias=360
  → VMora = 1000×12×360/36000 = 120.00

Valor=1000.0, TxMora=0.0, Dias=30
  → VMora = 0.00

Valor=0.0,    TxMora=12.0, Dias=30
  → VMora = 0.00
```

---

### 14.2 Tipos de TMora — Comportamentos Matemáticos Puros

Os TMora a seguir têm lógica matemática pura (sem consulta ao banco):

| TMora | Comportamento |
|-------|--------------|
| Isenção total | `VMora = 0` |
| Redução 20% | `VMora = VMora × 0.8` |
| JM (juros moratórios) | `VMora = Valor × TxMora × Dias / 36000` |
| JC (juros contratuais) | `VMora = Valor × ((1+i)^(Dias/30)-1)` |

**Casos de Teste para Redução 20%:**
```
Valor=1000.0, TxMora=12.0, Dias=30
  → VMora_base = 10.00
  → VMora_reduzido = 8.00
```

**Casos de Teste para JC (juros compostos na mora):**
```
Valor=1000.0, i_mensal=0.01, Dias=30
  → VMora = 1000×((1.01)^1-1) = 10.00

Valor=1000.0, i_mensal=0.01, Dias=15
  → VMora = 1000×((1.01)^0.5-1) ≈ 4.99
```

---

## 15. Seguros MIP e DFI

### 15.1 Cálculo de Prêmio MIP (Morte e Invalidez)

**Classificação:** ✅ Puro (com faixas etárias como parâmetro injetado)

**Fórmula:**
```
PremioMIP = SaldoDevedor × AliquotaMIP / 100
```

**Faixas etárias (parâmetros injetáveis — não de banco neste contexto):**
| Faixa | Idade | Alíquota típica |
|-------|-------|-----------------|
| 1 | até 25 anos | menor |
| 2 | 26–35 anos | média-baixa |
| 3 | 36–55 anos | média-alta |
| 4 | acima 55 anos | maior |

**Casos de Teste:**
```
SaldoDev=100000.0, AliquotaMIP=0.036/100 (faixa 1)
  → Premio = 100000×0.00036 = 36.00

SaldoDev=200000.0, AliquotaMIP=0.072/100 (faixa 3)
  → Premio = 200000×0.00072 = 144.00
```

---

### 15.2 Cálculo de Prêmio DFI (Danos Físicos ao Imóvel)

**Classificação:** ✅ Puro

**Fórmula:**
```
PremioDFI = ValorImovel × AliquotaDFI / 100
```

**Casos de Teste:**
```
ValorImovel=300000.0, AliquotaDFI=0.025/100
  → Premio = 300000×0.00025 = 75.00

ValorImovel=150000.0, AliquotaDFI=0.02/100
  → Premio = 30.00
```

---

## 16. IOF — Cálculo Puro

### 16.1 IOF à Vista (Prazo ≤ 365 dias)

**Função:** `ObtemIOFPorPrazo()` — l.3605  
**Classificação:** ✅ Puro (com alíquotas como parâmetros)

**Fórmula:**
```
IOF = SaldoDev × min(Dias,365) × PercIOF/100 + PercIOFOp/100
```

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `SaldoDev` | Double | Saldo devedor |
| `Dias` | Integer | Prazo em dias |
| `PercIOF` | Double | Alíquota IOF diária (%) |
| `PercIOFOp` | Double | Alíquota IOF operacional (%) |

**Regra importante:** `min(Dias, 365)` — prazo máximo para IOF = 365 dias.

**Casos de Teste:**
```
SaldoDev=100000.0, Dias=30,  PercIOF=0.0041, PercIOFOp=0.38
  → IOF = 100000×30×0.0041/100 + 0.38/100
       = 123.00 + 0.0038 ≈ 123.00

SaldoDev=100000.0, Dias=365, PercIOF=0.0041, PercIOFOp=0.38
  → IOF = 100000×365×0.0041/100 ≈ 1496.50

SaldoDev=100000.0, Dias=400, PercIOF=0.0041, PercIOFOp=0.38
  → IOF = 100000×365×0.0041/100 (limitado a 365 dias)
```

---

## 17. IFRS9 / Custo Amortizado

### 17.1 Taxa Interna Original do Contrato (Custo Amortizado)

**Função:** `CalculaTxJurosCA()` — l.4216  
**Classificação:** ⚠️ Isolável (requer fluxo de caixa como array)

**Método:** TIR do fluxo de caixa original do contrato.

**Fórmula:**
```
TxOriginalCtrIFRS9 = TIR do fluxo original (Newton-Raphson)
```

---

### 17.2 Juros IFRS9 (Método do Custo Amortizado)

**Classificação:** ✅ Puro

**Fórmula:**
```
JurosIFRS9 = SaldoIFRS9 × TxOriginalCtrIFRS9 / 1200
```
*(Divisão por 1200 = 100 × 12, para converter taxa anual % em taxa mensal decimal)*

**Parâmetros:**
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `SaldoIFRS9` | Double | Saldo IFRS9 corrente |
| `TxOriginalCtrIFRS9` | Double | TIR original (%) anual |

**Casos de Teste:**
```
SaldoIFRS9=100000.0, TxOriginal=12.0
  → Juros = 100000×12/1200 = 1000.00

SaldoIFRS9=200000.0, TxOriginal=6.0
  → Juros = 200000×6/1200 = 1000.00

SaldoIFRS9=0.0, TxOriginal=12.0
  → Juros = 0.00
```

---

### 17.3 Atualização do Saldo IFRS9

**Classificação:** ✅ Puro

**Fórmula:**
```
SaldoIFRS9_novo = SaldoIFRS9 + JurosIFRS9 - PagamentoPeriodo
```

**Casos de Teste:**
```
SaldoIFRS9=100000.0, JurosIFRS9=1000.0, Pagamento=1434.71
  → SaldoNovo = 100000+1000-1434.71 = 99565.29

SaldoIFRS9=100000.0, JurosIFRS9=1000.0, Pagamento=1000.0
  → SaldoNovo = 100000 (juros = pagamento → saldo constante)
```

---

### 17.4 Resolução 3516 — Taxa SELIC Mensal

**Classificação:** ✅ Puro (com SELIC como parâmetro injetado)

**Fórmula:**
```
Tx3516 = ((1 + TxSelic_anual/100)^(1/12) - 1) × 100
```

**Casos de Teste:**
```
TxSelic_anual=13.75
  → Tx3516 = ((1.1375)^(1/12)-1)×100 ≈ 1.080% a.m.

TxSelic_anual=12.0
  → Tx3516 = ((1.12)^(1/12)-1)×100 ≈ 0.9489% a.m.

TxSelic_anual=0.0
  → Tx3516 = 0.0
```

---

## 18. Resíduo e Quitação Antecipada

### 18.1 Cálculo de Resíduo de Quitação

**Função:** `CalculaResiduoQuitacao()` — l.2082  
**Classificação:** ⚠️ Isolável

**Fórmula (quitação pelo saldo devedor):**
```
ValorQuitacao = SaldoDevedor + JurosPendentes + MultaQuitacao
```

**Casos de Teste:**
```
SaldoDev=50000.0, Juros=500.0, Multa=0.0
  → Quitacao = 50500.00

SaldoDev=50000.0, Juros=0.0, Multa=0.0
  → Quitacao = 50000.00
```

---

### 18.2 Desconto por Antecipação Total (VP de todas vincendas)

**Classificação:** ✅ Puro

**Fórmula:**
```
SaldoQuitacao = Σ(k=1..n) PMT_k / (1+i)^k
```

**Casos de Teste:**
```
n=12, PMT=1434.71, i=0.01:
  Saldo = Σ 1434.71/(1.01)^k, k=1..12 ≈ 16105.74

n=1, PMT=1434.71, i=0.01:
  Saldo = 1434.71/1.01 ≈ 1420.50
```

---

## 19. Plano Empresa — Núcleo Matemático

### 19.1 Carência de Amortização

**TipoCtr:** `[33, 34, 35, 36, 47]`  
**Classificação:** ✅ Puro (lógica de carência é matemática pura)

**Regra:**
```
Durante carência: Parcela = apenas Juros (sem amortização)
Após carência:    Parcela = Amort + Juros (normal)
```

**Fórmula durante carência:**
```
ParcelaCarencia = SaldoDev × IndJuros
SaldoNovo       = SaldoDev  {sem amortização}
```

**Casos de Teste:**
```
SaldoDev=200000.0, IndJuros=0.01, CarenciaMeses=6

Meses 1–6 (carência):
  Parcela = 200000×0.01 = 2000.00
  Saldo permanece = 200000.00

Mês 7 (após carência):
  Amort  = 200000 / (120-6) ≈ 1754.39  [SAC]
  Juros  = 200000×0.01 = 2000.00
  Parcela= 3754.39
```

---

### 19.2 Cronograma de Liberação (Construção)

**Classificação:** ✅ Puro (matemática de parcelas liberadas)

**Regra:**
```
Saldo após liberação = Saldo_anterior + Valor_liberado
Juros do período    = Saldo_atual × IndJuros
```

**Casos de Teste:**
```
SaldoInicial=0, Liberacao_1=50000 no mês 1, Liberacao_2=50000 no mês 4

Mês 1: Saldo=50000, Juros=50000×0.01=500
Mês 2: Saldo=50000, Juros=500
Mês 4: Saldo=100000, Juros=1000
```

---

## Apêndice A — Constantes Hardcoded

| Constante | Valor | Localização | Uso |
|-----------|-------|-------------|-----|
| Base mora | `36000` | `CorrecaoJMJCChaves` | `VMora = Valor × Tx × Dias / 36000` |
| Multa padrão | `2%` (PA=81) | `ValorMulta()` | Multa por atraso |
| Arredondamento | `int(x×100+0.5)/100` | todo o sistema | Padrão centavos |
| Base dias corridos | `360` | `CalculaJurosPorDiasCorridos` | Dias/360 |
| Base dias úteis | `252` | `CalculaJurosPorDiasUteis` | DiasUteis/252 |
| Base pro-rata | `30` | `CalcJurosProRata()` | Dias/30 por mês |
| TIR tolerância | `0.00000009` | `XTIR()` | Convergência Newton-Raphson |
| TIR max iter | `300` | `XTIR()` | Limite iterações |
| TIR data zero | Ano 50 | `XTIR()` | Hardcoded ponto de referência |
| IFRS9 divisor | `1200` | `JurosIFRS9` | Taxa anual % → mensal decimal |
| PerParcelas mensal | `12` | `CalculaJuros()` | Periodicidade padrão |

---

## Apêndice B — Tabela de Testabilidade

| # | Função | Classificação | Estratégia de Isolamento |
|---|--------|--------------|--------------------------|
| 1 | `CalculaJuros()` — taxa mensal | ✅ Puro | — |
| 2 | `CalculaJuros()` — taxa equivalente | ✅ Puro | — |
| 3 | `CalculaJurosPorDiasCorridosOuUteis()` TpJuros=6 | ✅ Puro | — |
| 4 | `CalculaJurosPorDiasCorridosOuUteis()` TpJuros=7 | ✅ Puro | — |
| 5 | `CalculaJurosSisAmFianca()` | ✅ Puro | — |
| 6 | `CalculaJurosSimples()` | ✅ Puro | — |
| 7 | `CalculaJurosCompostos()` | ✅ Puro | — |
| 8 | `CalcJurosProRata()` | ✅ Puro | — |
| 9 | `CalculaJurosSimplesSCP()` | ✅ Puro | — |
| 10 | `CalculaJurosSCPPorDiasCorridosOuUteis()` | ✅ Puro | — |
| 11 | Parcela SAC | ✅ Puro | — |
| 12 | PMT PRICE — `CalcAmaisJ()` | ✅ Puro | — |
| 13 | `MontaParcelasSacre()` | ✅ Puro | — |
| 14 | VP = VF/(1+i)^n | ✅ Puro | — |
| 15 | VF = VP×(1+i)^n | ✅ Puro | — |
| 16 | VP de anuidade | ✅ Puro | — |
| 17 | `ValorMulta()` | ✅ Puro | — |
| 18 | Arredondamento centavos | ✅ Puro | — |
| 19 | Mora simples (VMora) | ✅ Puro | — |
| 20 | Mora compostos (JC) | ✅ Puro | — |
| 21 | Mora com redução 20% | ✅ Puro | — |
| 22 | Prêmio MIP | ✅ Puro | — |
| 23 | Prêmio DFI | ✅ Puro | — |
| 24 | IOF à vista | ✅ Puro | — |
| 25 | JurosIFRS9 | ✅ Puro | — |
| 26 | Atualização SaldoIFRS9 | ✅ Puro | — |
| 27 | Tx3516 (SELIC mensal) | ✅ Puro | — |
| 28 | Carência Plano Empresa | ✅ Puro | — |
| 29 | Liberação de obra | ✅ Puro | — |
| 30 | `DescontoPorTaxa()` | ✅ Puro | — |
| 31 | VPL | ✅ Puro | — |
| 32 | `XTIR()` Newton-Raphson | ⚠️ Isolável | Injetar fluxo como array Double[] |
| 33 | `CalculaTxJurosCA()` | ⚠️ Isolável | Injetar fluxo de caixa original como parâmetro |
| 34 | `CalculaSaldoParaQuitacao()` | ⚠️ Isolável | Injetar array de parcelas vincendas |
| 35 | `CalculaResiduoQuitacao()` | ⚠️ Isolável | Injetar saldo + juros pendentes |

---

## Apêndice C — Estratégias de Isolamento para ⚠️ Isolável

### C.1 TIR / XTIR()
```python
# Injetar fluxo de caixa diretamente (sem banco, sem arquivo)
def test_tir_price():
    pmt = 1434.71
    fluxo = [-100000.0] + [pmt] * 120
    tir = calcular_tir(fluxo, chute_inicial=0.01)
    assert abs(tir - 0.01) < 1e-6
```

### C.2 CalculaTxJurosCA()
```python
# Fluxo de caixa do contrato como parâmetro puro
def test_custo_amortizado():
    fluxo_original = [-100000.0] + [1434.71] * 120
    tx_ca = calcular_tx_ca(fluxo_original)
    # tx_ca deve ser ≈ 1% a.m. = 12% a.a.
    assert abs(tx_ca * 12 - 12.0) < 0.001
```

### C.3 CalculaSaldoParaQuitacao()
```python
# Injetar parcelas vincendas como lista
def test_saldo_quitacao():
    parcelas = [1000.0] * 10
    i = 0.01
    saldo = calcular_saldo_quitacao(parcelas, i)
    # VP de 10 parcelas de 1000 com 1%
    assert abs(saldo - 9471.30) < 0.01
```

---

## Apêndice D — Referências

| Documento | Conteúdo |
|-----------|----------|
| `MatematicaFinanceira_MontanteCapitalJuros.pdf` | Definições J, M, C; exemplos base |
| `MatematicaFinanceira_JurosSimplesCompostos.pdf` | Fórmulas JS/JC, taxas equivalentes, nominal/efetiva |
| `MatematicaFinanceira_FluxoDeCaixa.pdf` | VP, VF, VPL, TIR, exemplo PMT |
| `MatematicaFinanceira_Planilhas.pdf` | Funções IRR, XIRR, PV, FV, DAYS360 |
| `ucontrato.pas` | Implementação Delphi — 47.169 linhas |
