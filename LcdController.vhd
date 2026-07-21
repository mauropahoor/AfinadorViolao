library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LcdController is
    port (
        clk           : in  std_logic; -- Clock de 50 MHz
        reset         : in  std_logic; -- Reset assíncrono
        selecao_corda : in  std_logic_vector(2 downto 0); -- Seleção de corda (SW17-15)
        periodo       : in  std_logic_vector(19 downto 0); -- Período medido vindo do registrador
        mdup, dup     : in  std_logic; -- Sinais de afinação alta
        afinado       : in  std_logic; -- Sinal de afinado
        ddown, mddown : in  std_logic; -- Sinais de afinação baixa
        
        -- Sinais físicos do LCD da placa DE2-115
        LCD_ON        : out std_logic;
        LCD_EN        : out std_logic;
        LCD_RS        : out std_logic;
        LCD_RW        : out std_logic;
        LCD_DATA      : out std_logic_vector(7 downto 0)
    );
end entity LcdController;

architecture Behavioral of LcdController is
    -- Divisor de clock de 50 MHz para gerar clock lento de 100 kHz (período de 10 us)
    signal clk_div : integer range 0 to 499 := 0;
    signal clk_100k : std_logic := '0';

    -- Sinais de String nativos de 16 caracteres em VHDL
    signal line1_str : string(1 to 16) := "                ";
    signal line2_str : string(1 to 16) := "                ";

    -- FSM de Controle
    type state_type is (
        ST_POWER_ON_DELAY,
        ST_INIT_1, ST_INIT_2, ST_INIT_3, ST_INIT_4,
        ST_INIT_DISP_CONTROL, ST_INIT_CLEAR, ST_INIT_ENTRY_MODE,
        ST_SET_DDRAM_L1, ST_WRITE_L1,
        ST_SET_DDRAM_L2, ST_WRITE_L2,
        ST_WAIT_REFRESH
    );
    signal current_state : state_type := ST_POWER_ON_DELAY;
    
    -- Sub-fases de envio de comando (0: Setup, 1: Pulse EN high, 2: Pulse EN low e atraso)
    signal phase : integer range 0 to 2 := 0;
    signal delay_reg : integer := 0;
    signal char_index : integer range 1 to 16 := 1;

begin

    -- Alimenta os pinos estáticos do LCD
    LCD_ON <= '1'; -- LCD sempre ligado
    LCD_RW <= '0'; -- Sempre escrita

    -- Gerador de clock lento de 100 kHz (base de tempo de 10 us)
    process(clk, reset)
    begin
        if reset = '1' then
            clk_div <= 0;
            clk_100k <= '0';
        elsif rising_edge(clk) then
            if clk_div = 499 then
                clk_div <= 0;
                clk_100k <= not clk_100k;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    -- Mapeamento das informações de texto para a Linha 1 (Calcula a frequência em tempo real por indexação)
    process(selecao_corda, periodo)
        variable v_periodo : integer;
        variable v_freq    : integer range 0 to 9999;
        variable dig1, dig2, dig3, dig4 : integer;
        variable note_char1, note_char2 : character;
    begin
        -- Define o nome da corda selecionada
        case selecao_corda is
            when "000" => note_char1 := 'E'; note_char2 := '2';
            when "001" => note_char1 := 'A'; note_char2 := '2';
            when "010" => note_char1 := 'D'; note_char2 := '3';
            when "011" => note_char1 := 'G'; note_char2 := '3';
            when "100" => note_char1 := 'B'; note_char2 := '3';
            when "101" => note_char1 := 'E'; note_char2 := '4';
            when others => note_char1 := 'E'; note_char2 := '2';
        end case;

        line1_str(1) <= note_char1;
        line1_str(2) <= note_char2;
        line1_str(3) <= ' ';
        line1_str(4) <= '-';
        line1_str(5) <= ' ';

        v_periodo := to_integer(unsigned(periodo));
        
        -- Calcula a frequência atual multiplicada por 10 (ex: 82.4 Hz vira o inteiro 824)
        if v_periodo > 50000 and v_periodo /= 1048575 then
            v_freq := 500000000 / v_periodo;
        else
            v_freq := 0;
        end if;

        -- Extrai os dígitos decimais e formata os caracteres por indexação (seguro contra incompatibilidade de tamanho)
        if v_freq >= 1000 then -- Frequências de 100.0 Hz a 999.9 Hz (como A2 a 110.0 Hz)
            dig1 := v_freq / 1000;
            dig2 := (v_freq / 10) mod 10;
            dig3 := (v_freq / 10) mod 10;
            dig4 := v_freq mod 10;
            
            line1_str(6)  <= character'val(48 + dig1);
            line1_str(7)  <= character'val(48 + dig2);
            line1_str(8)  <= character'val(48 + dig3);
            line1_str(9)  <= '.';
            line1_str(10) <= character'val(48 + dig4);
        elsif v_freq > 0 then -- Frequências de 0.1 Hz a 99.9 Hz (como E2 a 82.4 Hz)
            dig1 := v_freq / 100;
            dig2 := (v_freq / 10) mod 10;
            dig3 := v_freq mod 10;
            
            line1_str(6)  <= ' ';
            line1_str(7)  <= character'val(48 + dig1);
            line1_str(8)  <= character'val(48 + dig2);
            line1_str(9)  <= '.';
            line1_str(10) <= character'val(48 + dig3);
        else
            -- Se o sinal estiver desligado/sem sinal
            line1_str(6)  <= ' ';
            line1_str(7)  <= '0';
            line1_str(8)  <= '0';
            line1_str(9)  <= '.';
            line1_str(10) <= '0';
        end if;

        line1_str(11) <= ' ';
        line1_str(12) <= 'H';
        line1_str(13) <= 'z';
        line1_str(14) <= ' ';
        line1_str(15) <= ' ';
        line1_str(16) <= ' ';
    end process;

    -- Mapeamento das informações de texto para a Linha 2 (Atribuição direta de strings literais de 16 caracteres)
    process(afinado, dup, mdup, ddown, mddown)
    begin
        if afinado = '1' then
            line2_str <= "    Afinado     ";
        elsif dup = '1' then
            line2_str <= " Desafinado (H) ";
        elsif mdup = '1' then
            line2_str <= "  Muito Alto    ";
        elsif ddown = '1' then
            line2_str <= " Desafinado (L) ";
        elsif mddown = '1' then
            line2_str <= "  Muito Baixo   ";
        else
            line2_str <= "  Sem Sinal...  ";
        end if;
    end process;

    -- FSM que processa a escrita do LCD rodando a 100 kHz (a cada 10 us)
    process(clk_100k, reset)
        variable current_char : character;
    begin
        if reset = '1' then
            current_state <= ST_POWER_ON_DELAY;
            phase <= 0;
            delay_reg <= 1500; -- 15 ms delay inicialmente (1500 * 10 us)
            LCD_EN <= '0';
            LCD_RS <= '0';
            LCD_DATA <= (others => '0');
            char_index <= 1;
        elsif rising_edge(clk_100k) then
            
            -- Se estivermos aguardando o tempo de atraso de algum comando
            if delay_reg > 0 then
                delay_reg <= delay_reg - 1;
                LCD_EN <= '0';
            else
                case current_state is
                    
                    -- Atraso de inicialização pós energia (15 ms)
                    when ST_POWER_ON_DELAY =>
                        current_state <= ST_INIT_1;
                        phase <= 0;

                    -- Comando Inicialização 1 (0x38) - Esperar 4.1 ms (410 contagens)
                    when ST_INIT_1 =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"38";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 410;
                            current_state <= ST_INIT_2;
                        end if;

                    -- Comando Inicialização 2 (0x38) - Esperar 100 us (10 contagens)
                    when ST_INIT_2 =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"38";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 10;
                            current_state <= ST_INIT_3;
                        end if;

                    -- Comando Inicialização 3 (0x38) - Esperar 40 us (4 contagens)
                    when ST_INIT_3 =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"38";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            current_state <= ST_INIT_4;
                        end if;

                    -- Configuração de Função (Function Set - 0x38) - Esperar 40 us (4 contagens)
                    when ST_INIT_4 =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"38";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            current_state <= ST_INIT_DISP_CONTROL;
                        end if;

                    -- Liga o display, desliga o cursor (Display ON - 0x0C) - Esperar 40 us
                    when ST_INIT_DISP_CONTROL =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"0C";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            current_state <= ST_INIT_CLEAR;
                        end if;

                    -- Limpa a tela (Clear - 0x01) - Esperar 1.64 ms (164 contagens)
                    when ST_INIT_CLEAR =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"01";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 164;
                            current_state <= ST_INIT_ENTRY_MODE;
                        end if;

                    -- Modo de Entrada (Entry Mode - 0x06) - Esperar 40 us
                    when ST_INIT_ENTRY_MODE =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"06";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            current_state <= ST_SET_DDRAM_L1;
                        end if;

                    -- Posiciona o Cursor no início da Linha 1 (0x80) - Esperar 40 us
                    when ST_SET_DDRAM_L1 =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"80";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            char_index <= 1;
                            current_state <= ST_WRITE_L1;
                        end if;

                    -- Escreve os 16 caracteres da Linha 1
                    when ST_WRITE_L1 =>
                        current_char := line1_str(char_index);
                        if phase = 0 then
                            LCD_RS   <= '1'; -- Modo Dados
                            LCD_DATA <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            if char_index = 16 then
                                current_state <= ST_SET_DDRAM_L2;
                            else
                                char_index <= char_index + 1;
                            end if;
                        end if;

                    -- Posiciona o Cursor no início da Linha 2 (0xC0) - Esperar 40 us
                    when ST_SET_DDRAM_L2 =>
                        if phase = 0 then
                            LCD_RS   <= '0';
                            LCD_DATA <= x"C0";
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            char_index <= 1;
                            current_state <= ST_WRITE_L2;
                        end if;

                    -- Escreve os 16 caracteres da Linha 2
                    when ST_WRITE_L2 =>
                        current_char := line2_str(char_index);
                        if phase = 0 then
                            LCD_RS   <= '1'; -- Modo Dados
                            LCD_DATA <= std_logic_vector(to_unsigned(character'pos(current_char), 8));
                            LCD_EN   <= '0';
                            phase    <= 1;
                        elsif phase = 1 then
                            LCD_EN   <= '1';
                            phase    <= 2;
                        else
                            LCD_EN   <= '0';
                            phase    <= 0;
                            delay_reg <= 4;
                            if char_index = 16 then
                                -- Atraso de 200 ms antes de atualizar novamente
                                delay_reg <= 20000;
                                current_state <= ST_SET_DDRAM_L1;
                            else
                                char_index <= char_index + 1;
                            end if;
                        end if;

                    when others =>
                        current_state <= ST_SET_DDRAM_L1;
                end case;
            end if;
        end if;
    end process;

end architecture Behavioral;
