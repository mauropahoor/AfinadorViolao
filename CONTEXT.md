# Contexto do Projeto: Afinador de Violão em VHDL

Este documento serve como arquivo de contexto do projeto, descrevendo sua arquitetura, estado atual e guia de referência para manutenção e desenvolvimento.

---

## 📌 Informações Gerais
- **Nome do Projeto:** Afinador Digital de Violão
- **Plataforma Target:** FPGA Altera DE2-115 (ou similar com Cyclone IV / Quartus II 13.0+)
- **Linguagem:** VHDL-1993 / VHDL-2008
- **Frequência Principal (Clock):** 50 MHz (`PIN_Y2`)
- **Repositório:** [mauropahoor/Quartus_AfinadorViolao](https://github.com/mauropahoor/Quartus_AfinadorViolao)

---

## ⚙️ Arquitetura e Funcionamento do Sistema

O projeto é um afinador digital que utiliza a técnica de **medição de período** por contagem de pulsos de clock (50 MHz).

### Fluxo de Dados e Interconexão dos Módulos

```
                   +-----------------------------------+
                   |   GeradorOsci (Simulador 50 MHz)  |
                   |   - Suporta E2, A2, D3, G3, B3, E4|
                   |   - Ajuste fino via KEY0 / KEY2   |
                   +-----------------+-----------------+
                                     | osc (Sinal de Entrada)
                                     v
                   +-----------------+-----------------+
                   |       UnidadeControle (FSM)       |
                   |   - Detecção de borda de subida   |
                   |   - Gera pulsos LOAD e CLEAR      |
                   +--------+------------------+------+
                            | LOAD             | CLEAR
                            v                  v
+------------------+   +----+-------------+   +---------------+
|   Counter (20b)  |-->|  registrador (20b|   | Counter (20b) | (Zera a contagem)
| Contagem 50 MHz  |   | Trava amostragem |   +---------------+
+------------------+   +--------+---------+
                                | Período (20 bits)
                      +---------+---------+
                      |                   |
                      v                   v
            +---------+-------+   +-------+---------+
            |   LedsCompare   |   |   LcdController |
            | Comparador de   |   | Exibe Nota, Hz  |
            | Limiares (LEDs) |   | e Mensagem LCD  |
            +-----------------+   +-----------------+
```

---

## 📂 Descrição dos Módulos (Arquivos do Projeto)

1. **`Afinador_Violao.vhd` / `Afinador_Violao.bdf`**:
   - Módulo Top-Level que conecta todas as instâncias (GeradorOscilador, FSM, Counter, Registrador, Comparador de LEDs e Controlador de LCD).
   - Mapeia saídas estáticas para LEDs vermelhos (`osc_visualizer`), LEDs verdes (`mdup`, `dup`, `afinado`, `ddown`, `mddown`) e barramento do LCD (`LCD_DATA`, `LCD_EN`, `LCD_RS`, `LCD_RW`, `LCD_ON`).

2. **`UnidadeControle.vhd`**:
   - Máquina de Estados Finitos (FSM) de 3 estados (`STATE1`, `LDCD`, `STATE2`).
   - Sincroniza a captura do período e o reset do contador no exato momento da borda de subida do sinal áudio/oscilador.

3. **`Counter.vhd`**:
   - Contador de 20 bits alimentado pelo clock de 50 MHz.
   - Possui trava de saturação no valor `1.048.575` para evitar *overflow* quando não há sinal de entrada.

4. **`Register.vhd` / `registrador.vhd`**:
   - Registrador síncrono de 20 bits com entradas `enable` (LOAD da FSM) e `run` (ligado à chave `SW0`). Congela o valor amostrado para estabilidade visual nos displays.

5. **`LedsCompare.vhd`**:
   - Comparador de limiares de contagem para as 6 cordas do violão:
     - **E2** (Mi grave - 82,41 Hz) | **A2** (Lá - 110,00 Hz) | **D3** (Ré - 146,83 Hz)
     - **G3** (Sol - 196,00 Hz) | **B3** (Si - 246,94 Hz) | **E4** (Mi agudo - 329,63 Hz)

6. **`GeradorOsci.vhd`**:
   - Divisor de frequência a partir do clock de 50 MHz para gerar frequências quadradas sintéticas das 6 cordas.
   - Sincronizador debounced para botões `KEY0` (aumenta frequência) e `KEY2` (diminui frequência) para simular afinação/desafinação.

7. **`LcdController.vhd`**:
   - Controlador para display LCD 16x2 (padrão HD44780).
   - Realiza cálculo dinâmico da frequência em Hz com base no período e envia os dados formatados em 2 linhas para o display.

---

## 🎛️ Mapeamento de Entradas/Saídas (FPGA DE2-115)
- **`pin_name1`**: Clock de 50 MHz (`PIN_Y2`)
- **`btn_enable` (`SW0`)**: Liga/desliga simulador e habilita registrador.
- **`selecao_corda` (`SW17-15`)**: Seleção da corda (000=E2, 001=A2, 010=D3, 011=G3, 100=B3, 101=E4).
- **`key_up` (`KEY0`)**: Incrementa frequência no simulador (afina / estica corda).
- **`key_down` (`KEY2`)**: Decrementa frequência no simulador (desafina / afrouxa corda).
- **LEDs Verdes**: Status de afinação (`mdup`, `dup`, `afinado`, `ddown`, `mddown`).
- **LCD (16x2)**: Mostra nota selecionada, frequência instantânea (ex: `82.4 Hz`) e status textual.

---

## 📈 Estado Atual do Projeto
- ✅ Top-Level `Afinador_Violao.vhd` integrado com suporte às 6 cordas e display LCD.
- ✅ Simulador de oscilação atualizado para clock de 50 MHz com ajuste fino por botões.
- ✅ Controlador LCD 16x2 funcional com cálculo dinâmico de frequência.
- ✅ Lógica de saturação do contador e trava de amostragem no registrador operacionais.
