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

## 🚀 Como Executar o Projeto no Quartus II
1. Clone este repositório:
   ```bash
   git clone https://github.com/mauropahoor/Quartus_AfinadorViolao.git
   ```
2. Abra o software **Quartus II 13**.
3. Vá em **File > Open Project** e selecione o arquivo `Afinador_Violao.qpf`.
4. Para simular as formas de onda, abra os arquivos `.vwf` no simulador integrado do Quartus.
5. Para compilar, clique em **Processing > Start Compilation** (ou utilize o atalho `Ctrl + L`).
