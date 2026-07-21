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
* `Afinador_Violao.qpf`: Arquivo de projeto do Quartus.
* `Afinador_Violao.qsf`: Arquivo de configurações e atribuições de pinos (Pin Planner).
* `Afinador_Violao.bdf`: Diagrama de blocos principal (Top-Level).
* `UnidadeControle.vhd`: Bloco de controle do fluxo do afinador.
* `LedsCompare.vhd`: Bloco de comparação de LEDs.
* `Counter.vhd`: Contador auxiliar.
* `Register.vhd` / `registrador.vhd`: Registradores para salvar o estado/dados.
* `GeradorOsci.vhd`: Gerador de oscilação / divisor de clock.

## 🎸 Seleção de Cordas / Notas (Código Binário)

A seleção da corda a ser afinada é feita através das chaves **`SW17-15`** na placa FPGA. Cada combinação binária de 3 bits corresponde a uma das 6 cordas do violão na afinação padrão (*Standard E*):

| Chaves `SW17 SW16 SW15` | Código Binário | Corda / Nota | Denominação | Frequência Alvo |
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
* **`SW17-15` (Seleção da Corda)**: Seleciona a nota de referência em binário conforme a tabela acima.
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

> 📘 Para mais detalhes sobre a arquitetura e equações do projeto, consulte o arquivo [CONTEXT.md](./CONTEXT.md).

