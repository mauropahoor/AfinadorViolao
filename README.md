# Projeto Afinador de Violão (Fase Block Diagram - .bdf)

[![Projeto: Esquemático (.bdf)](https://img.shields.io/badge/Projeto-Block_Diagram_(.bdf)-green.svg)](#)
[![IDE: Quartus II 13](https://img.shields.io/badge/IDE-Quartus_II_13-lightgrey.svg)](#)
[![FPGA: Cyclone IV E](https://img.shields.io/badge/FPGA-Cyclone_IV_E-blue.svg)](#)

Este projeto é um afinador de violão digital desenvolvido para a disciplina de **Laboratório de Circuitos Digitais** da UNESP (2026.1). O desenvolvimento é realizado exclusivamente em **Diagramas de Blocos Esquemáticos (Block Diagram Files - `.bdf`)** na ferramenta **Quartus II 13**.

---

## 📋 Descrição do Projeto (Escopo Atual)

O circuito captura a frequência de oscilação da corda, mede o seu **período** (contando ciclos de um clock interno de 50 MHz da FPGA) e indica o status da afinação de forma visual e intuitiva por meio de 5 LEDs de status.

### 🎯 Características Principais:
* **Nota Única de Afinação (Mi2 / E2 - 82,41 Hz):** O afinador é pré-calibrado especificamente para a 6ª corda Mi2 grave (frequência fundamental de 82,41 Hz), dispensando chaves seletoras de cordas.
* **Afinação Guiada por LEDs:** Indicação visual exclusiva através de 5 LEDs de status (`mdup`, `dup`, `afinado`, `ddown`, `mddown`).

---

## 📂 Estrutura dos Blocos Esquemáticos (`.bdf`)

* **`Afinador_Violao.bdf`**: Esquemático Top-Level principal que conecta todos os módulos e mapeia os pinos físicos da placa FPGA DE2-115 (`PIN_Y2`, `PIN_H21`, `PIN_E24`, `PIN_E25`, `PIN_E22`, `PIN_E21`).
* **`PLL_27MHz` (MegaFunction)**: Bloco ALTPLL (IP Core) que recebe o clock principal de 50 MHz e gera um clock perfeitamente isolado de 27.6363 MHz exclusivo para o gerador de ondas.
* **`geradorOsc.bdf`**: Gerador/simulador de sinal de onda quadrada de teste alimentado a 27.6363 MHz, com controle suave via botões `KEY0` / `KEY2`.
* **`UnidadeControle.bdf`**: Máquina de estados (FSM) e detector síncrono de borda de subida que coordena a amostragem (`LOAD`) e a limpeza (`CLEAR`) da contagem.
* **`Counter.bdf`**: Contador de 20 bits alimentado a 50 MHz com lógica de saturação em 1.048.575 ciclos para proteção contra silêncio.
* **`LPM_FF`**: Registrador síncrono *latch* de 20 bits que trava a leitura do período, garantindo indicação estável nos LEDs sem oscilações.
* **`ComparadorDeLeds.bdf`**: Comparador esquemático de 20 bits com limiares fixos para a nota Mi2 (E2) e decodificação por portas `NOT` e `AND` para acender apenas 1 LED por vez.

---

## 🎸 Limiares de Afinação (Nota Mi2 / E2 - 82,41 Hz)

Considerando o clock de 50 MHz ($N_{\text{ideal}} \approx 606.722 \text{ ciclos}$):

| LED | Limite do Contador ($N$) em 20 bits | Frequência Equivalente ($f$) | Significado Lógico |
| :---: | :---: | :---: | :---: |
| **`mdup`** | $N < 599.776$ | $f > 83,36 \text{ Hz}$ | Muito Alto (Sustenido Forte) |
| **`dup`** | $599.776 \le N < 604.996$ | $82,65 \text{ Hz} < f \le 83,36 \text{ Hz}$ | Pouco Alto (Sustenido Leve) |
| **`afinado`** | $604.996 \le N < 608.500$ | $82,17 \text{ Hz} \le f \le 82,65 \text{ Hz}$ | **Afinado (Ideal: 82,41 Hz)** |
| **`ddown`** | $608.500 \le N < 613.795$ | $81,46 \text{ Hz} \le f < 82,17 \text{ Hz}$ | Pouco Baixo (Bemol Leve) |
| **`mddown`** | $N \ge 613.795$ | $f < 81,46 \text{ Hz}$ | Muito Baixo (Bemol Forte) |

### 💡 Guia Visual dos LEDs (Placa DE2-115)
Os 5 LEDs verdes indicam o estado da corda. O objetivo é acender apenas o **LED Central (LEDG2)**.

* 🔴 **LEDG4 (`mdup`)**: Corda **MUITO APERTADA** (Frequência alta). Afrouxe a corda sem medo.
* 🟡 **LEDG3 (`dup`)**: Corda **UM POUCO APERTADA**. Afrouxe a corda bem devagar.
* 🟢 **LEDG2 (`afinado`)**: **AFINAÇÃO PERFEITA** (Tom Mi2). Não mexa na tarracha!
* 🟡 **LEDG1 (`ddown`)**: Corda **UM POUCO FROUXA**. Aperte a corda bem devagar.
* 🔴 **LEDG0 (`mddown`)**: Corda **MUITO FROUXA** (Frequência baixa). Aperte a corda sem medo.

---

## 🎛️ Guia de Controles da Placa

* **`SW0` (Habilita Sistema)**: Liga o simulador de frequência. O LED Vermelho (`LEDR0`) acenderá confirmando que o sistema está operante.
* **`KEY2` (Aumenta Frequência / Estica Corda)**:
  - **Manter pressionado:** Aumenta a frequência (fica mais agudo) da onda simulada de forma contínua e suave.
* **`KEY0` (Diminui Frequência / Afrouxa Corda)**:
  - **Manter pressionado:** Diminui a frequência (fica mais grave) da onda simulada de forma contínua e suave.
* **Nenhum botão pressionado**: O afinador congela a nota gerada no ponto atual, e os LEDs verdes indicam o status da afinação de forma estável.

---

## 🚀 Como Executar e Simular no Quartus II

1. Clone o repositório:
   ```bash
   git clone https://github.com/mauropahoor/Quartus_AfinadorViolao.git
   ```
2. Abra o **Quartus II 13**.
3. Acesse **File > Open Project** e abra o arquivo `Afinador_Violao.qpf`.
4. Para compilar o circuito esquemático, clique em **Processing > Start Compilation** (`Ctrl + L`).
5. Para testar sem a placa física, abra o arquivo `Simulacao.vwf` e execute a simulação funcional por formas de onda.
