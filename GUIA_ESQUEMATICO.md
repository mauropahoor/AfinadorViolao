# Guia de Montagem: Top-Level em Diagrama Esquemático (BDF)

Agora que os arquivos VHDL auxiliares foram criados, siga este passo a passo detalhado para montar sua arquitetura visualmente no Quartus, cumprindo 100% da exigência do professor.

## Passo 1: Criar os Símbolos (Caixas Pretas)
Para cada um dos arquivos VHDL abaixo, abra-os no Quartus e vá no menu **File > Create/Update > Create Symbol Files for Current File**.
- `Counter.vhd`
- `GeradorOsci.vhd`
- `LcdController.vhd`
- `UnidadeControle.vhd`
- `LimitGenerator.vhd` *(Novo)*
- `LedDecoder.vhd` *(Novo)*

Isso vai gerar arquivos `.bsf` (Block Symbol File) que você poderá arrastar para o seu diagrama esquemático.

## Passo 2: O Novo Arquivo Top-Level
1. Exclua o arquivo `Afinador_Violao.vhd` do seu projeto (Clique com o botão direito nele na aba de arquivos do Quartus e escolha *Remove File from Project*). 
2. Crie um novo **Block Diagram/Schematic File** (File > New > Block Diagram/Schematic File).
3. Salve-o imediatamente como `Afinador_Violao.bdf`.

## Passo 3: Criar os Componentes Nativos do Quartus (MegaWizard)
O professor pediu que registrador e comparador usem os do Quartus.
Dê um clique duplo em uma área vazia do esquemático, vá em **megafunctions > storage** e insira o `lpm_ff` (Flip Flop):
1. **lpm_width (Largura):** 20 bits
2. Pinos de entrada: `clock`, `enable`, `data[19..0]`
3. Pino de saída: `q[19..0]`

Agora, vá em **megafunctions > arithmetic** e insira o `lpm_compare`:
1. **Largura:** 20 bits
2. Selecione para ele ter apenas as entradas `dataa` e `datab`, e a saída `AlB` (A is less than B).
3. Após inserir 1 na tela, faça um "Copiar e Colar" (Ctrl+C, Ctrl+V) para ter **4 blocos de comparador na tela**.

## Passo 4: O "Sanduíche" do Comparador Visual
O antigo código que decidia qual LED acender foi dividido em 3 partes físicas no seu desenho:
1. Coloque o bloco **LimitGenerator**. Ligue a entrada dele no barramento `selecao_corda[2..0]`.
2. Pegue os **4 blocos lpm_compare**. 
   - No pino `dataa` de TODOS ELES, conecte a saída do Registrador de 20 bits (que contém o período medido).
   - No pino `datab` de cada um deles, conecte uma saída do **LimitGenerator** (um recebe `limit_mdup`, outro `limit_dup`, etc).
3. Coloque o bloco **LedDecoder**. Ligue as 4 saídas `AlB` dos comparadores nas 4 entradas do LedDecoder.
4. Ligue as 5 saídas do LedDecoder diretamente nos pinos de saída dos LEDs (mdup, dup, afinado, etc).

## Passo 5: Fazer o resto das ligações
Arraste os outros blocos (GeradorOsci, LcdController, UnidadeControle, Counter) para a tela e faça as ligações dos fios (wires) entre eles exatamente como estavam no código VHDL antigo. 
- Lembre-se de adicionar **Input Pins** e **Output Pins** na tela para interagir com o mundo externo (ex: `clock_gerador` no B14, `btn_enable`, etc).

> [!IMPORTANT]
> Vá no menu **Assignments > Settings** e certifique-se de que a `Top-Level Entity` está configurada como `Afinador_Violao` (que agora se refere ao seu novo arquivo .bdf em vez do VHDL). Compile o projeto!
