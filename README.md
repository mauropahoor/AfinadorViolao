# Projeto Afinador de Violão

[![Linguagem: VHDL](https://img.shields.io/badge/Linguagem-VHDL-blue.svg)](#)
[![IDE: Quartus Prime](https://img.shields.io/badge/IDE-Quartus_Prime-lightgrey.svg)](#)

Este projeto é um afinador de violão digital desenvolvido para a disciplina de **Laboratório de Circuitos Digitais** da UNESP (2026.1). O desenvolvimento foi realizado utilizando a ferramenta **Quartus II 13**.

## 📋 Descrição do Projeto
O projeto utiliza descrição em VHDL e diagramas de blocos (BDF) para implementar a lógica de um afinador de instrumentos (violão). 
Ele analisa a frequência de entrada (ou sinais simulados) e compara com os valores de referência das cordas, indicando se a corda está afinada, abaixo ou acima do tom esperado.

## 🛠️ Tecnologias e Ferramentas
* **Plataforma:** Quartus II (versão 13.0 / 13.1)
* **Linguagem de Descrição de Hardware:** VHDL
* **Esquemas Visuais:** Block Diagram File (.bdf)
* **Simulação:** Vector Waveform File (.vwf)

## 📂 Estrutura de Arquivos Principais

* **`Afinador_Violao.vhd`**: Arquivo Top-Level em VHDL que integra todos os componentes e mapeia os pinos físicos da placa FPGA DE2-115.
* **`Afinador_Violao.bdf`**: Diagrama de blocos visual do Top-Level (Block Diagram File do Quartus).
* **`Afinador_Violao.qpf` / `.qsf`**: Arquivos de projeto do Quartus II e atribuições do Pin Planner.
* **`GeradorOsci.vhd`**: Gerador/simulador de frequências das 6 cordas com suporte a ajuste fino (0,05 Hz), auto-repeat (hold) e reset por `KEY0+KEY2`.
* **`UnidadeControle.vhd`**: Máquina de Estados Finitos (FSM) de 3 estados para sincronização e amostragem síncrona do período da corda.
* **`Counter.vhd`**: Contador de 20 bits alimentado a 50 MHz com lógica de saturação para proteção contra silêncio/ruído.
* **`Register.vhd` / `registrador.vhd`**: Registrador síncrono de 20 bits com trava de amostragem (`enable` / `run`) para estabilização dos dados.
* **`LedsCompare.vhd`**: Comparador de limiares de período que acende os LEDs de status (`mdup`, `dup`, `afinado`, `ddown`, `mddown`).
* **`LcdController.vhd`**: Controlador do visor LCD 16x2 (HD44780) com cálculo em tempo real de frequência em Hz e formatação de texto.

## 🎸 Seleção de Cordas / Notas (Código Binário)

A seleção da corda a ser afinada é feita através das chaves **`SW15-13`** na placa FPGA. Cada combinação binária de 3 bits corresponde a uma das 6 cordas do violão na afinação padrão (*Standard E*):

| Chaves `SW15 SW14 SW13` | Código Binário | Corda / Nota | Denominação | Frequência Alvo |
| :---: | :---: | :---: | :---: | :---: |
| `OFF OFF OFF` | **`000`** | **E2** | 6ª Corda (Mi grave) | **82,41 Hz** |
| `OFF OFF ON` | **`001`** | **A2** | 5ª Corda (Lá) | **110,00 Hz** |
| `OFF ON OFF` | **`010`** | **D3** | 4ª Corda (Ré) | **146,83 Hz** |
| `OFF ON ON` | **`011`** | **G3** | 3ª Corda (Sol) | **196,00 Hz** |
| `ON OFF OFF` | **`100`** | **B3** | 2ª Corda (Si) | **246,94 Hz** |
| `ON OFF ON` | **`101`** | **E4** | 1ª Corda (Mi agudo) | **329,63 Hz** |

---

## 🎛️ Guia de Controles da Placa

* **`SW0` (Habilita Simulador & Registrador)**: Liga a geração do sinal simulado e autoriza a atualização dos registradores de amostragem.
* **`SW15-13` (Seleção da Corda)**: Seleciona a nota de referência em binário conforme a tabela acima.
* **`KEY0` (Aumenta Frequência / Estica Corda)**:
  - **Clique:** Incremento de ajuste fino (0,05 Hz).
  - **Manter pressionado (Hold):** Aumenta a frequência continuamente em rampa.
* **`KEY2` (Diminui Frequência / Afrouxa Corda)**:
  - **Clique:** Decremento de ajuste fino (0,05 Hz).
  - **Manter pressionado (Hold):** Diminui a frequência continuamente em rampa.
* **`KEY0` + `KEY2` (Reset de Afinação)**: Pressionar ambos os botões simultaneamente reseta o sinal simulado para o tom perfeitamente afinado da corda selecionada.

---

## 🚀 Como Executar o Projeto no Quartus II
1. Clone este repositório:
   ```bash
   git clone https://github.com/mauropahoor/Quartus_AfinadorViolao.git
   ```
2. Abra o software **Quartus II 13**.
3. Vá em **File > Open Project** e selecione o arquivo `Afinador_Violao.qpf`.
4. Para simular as formas de onda, abra os arquivos `.vwf` no simulador integrado do Quartus.
5. Para compilar, clique em **Processing > Start Compilation** (ou utilize o atalho `Ctrl + L`).


