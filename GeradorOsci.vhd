library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity geradorOsc_vhdl is
    generic (
        -- Limite padrão de contagem para o divisor de clock se não houver corda selecionada
        MAX_COUNT : integer := 1000000 
    );
    port (
        -- Entradas
        clock_50      : in  std_logic; -- Clock principal de 50 MHz da placa
        enabl         : in  std_logic; -- Chave SW0 (habilita passagem de corrente/gerador)
        key_up        : in  std_logic; -- Botão KEY0 (sobe frequência/aperta corda - ativo em nível baixo)
        key_down      : in  std_logic; -- Botão KEY2 (desce frequência/afrouxa corda - ativo em nível baixo)
        selecao_corda : in  std_logic_vector(2 downto 0); -- Seletor de 3 bits para a simulação de cordas (SW17-15)
        
        -- Saídas
        osc            : out std_logic;
        osc_visualizer : out std_logic_vector(19 downto 0);
        led_clear_osc  : out std_logic;
        aebOutput      : out std_logic
    );
end entity geradorOsc_vhdl;

architecture Comportamento of geradorOsc_vhdl is
    -- Contadores e divisor para gerar uma base de tempo de 1 ms (para debouncer)
    signal div_1ms        : integer range 0 to 49999 := 0;
    signal tick_1ms       : std_logic := '0';
    
    -- Sinais de sincronização e detecção de borda para os botões KEY0 e KEY2
    signal key_up_sync     : std_logic_vector(2 downto 0) := (others => '1');
    signal key_down_sync   : std_logic_vector(2 downto 0) := (others => '1');
    signal key_up_pressed  : std_logic := '0';
    signal key_down_pressed: std_logic := '0';
    
    -- Controle de mudança de corda e temporizador de auto-repetição (hold)
    signal selecao_corda_prev : std_logic_vector(2 downto 0) := "000";
    signal repeat_timer       : integer range 0 to 500 := 0;
    
    -- Desvio acumulado de contagem (muda a frequência do sinal)
    signal offset          : integer := 0;
    
    -- Sinais internos de limites e contagem
    signal limite_base     : integer;
    signal limite_contagem : unsigned(19 downto 0);
    signal contagem        : unsigned(19 downto 0) := (others => '0');
    signal estado_osc      : std_logic := '0';

begin

    -- Ligação direta das saídas
    osc            <= estado_osc;
    osc_visualizer <= std_logic_vector(contagem);

    -- 1. Base de tempo de 1 ms (debouncing e leitura estritamente síncrona dos botões)
    process(clock_50)
    begin
        if rising_edge(clock_50) then
            if div_1ms = 49999 then
                div_1ms <= 0;
                tick_1ms <= '1';
            else
                div_1ms <= div_1ms + 1;
                tick_1ms <= '0';
            end if;
        end if;
    end process;

    -- 2. Sincronizador de 3 estágios para evitar metaestabilidade nos botões assíncronos
    process(clock_50)
    begin
        if rising_edge(clock_50) then
            if tick_1ms = '1' then
                key_up_sync   <= key_up_sync(1 downto 0)   & key_up;
                key_down_sync <= key_down_sync(1 downto 0) & key_down;
            end if;
        end if;
    end process;

    -- 3. Detector de borda de descida (pressionar o botão físico - ativo em nível baixo)
    key_up_pressed   <= '1' when key_up_sync(2 downto 1)   = "10" else '0';
    key_down_pressed <= '1' when key_down_sync(2 downto 1) = "10" else '0';

    -- 4. Escolha da nota base (Limites ideais de contagem para divisão baseados em Clock de 50 MHz)
    limite_base <= 303361 when selecao_corda = "000" else -- E2 (82.41 Hz) -> 50MHz/(2*303361) = 82.41 Hz
                   227272 when selecao_corda = "001" else -- A2 (110.00 Hz) -> 50MHz/(2*227272) = 110.00 Hz
                   170264 when selecao_corda = "010" else -- D3 (146.83 Hz) -> 50MHz/(2*170264) = 146.83 Hz
                   127551 when selecao_corda = "011" else -- G3 (196.00 Hz) -> 50MHz/(2*127551) = 196.00 Hz
                   101239 when selecao_corda = "100" else -- B3 (246.94 Hz) -> 50MHz/(2*101239) = 246.94 Hz
                   75842  when selecao_corda = "101" else -- E4 (329.63 Hz) -> 50MHz/(2*75842) = 329.63 Hz
                   303361; -- Default E2

    -- 5. Lógica de ajuste fino de frequência com Auto-Repeat e Reset duplo
    process(clock_50)
    begin
        if rising_edge(clock_50) then
            -- Atalho 1: Pressionar KEY0 e KEY2 simultaneamente zera o offset (Reset Fino)
            if key_up_sync(2) = '0' and key_down_sync(2) = '0' then
                offset <= 0;
                repeat_timer <= 0;
            
            -- Atalho 2: Alternar as chaves SW de seleção de corda zera o offset
            elsif selecao_corda /= selecao_corda_prev then
                offset <= 0;
                selecao_corda_prev <= selecao_corda;
                repeat_timer <= 0;
                
            else
                -- KEY0 mantido pressionado (Sobe frequência / reduz limite divisor)
                if key_up_sync(2) = '0' then
                    if key_up_pressed = '1' then
                        if offset > -50000 then
                            offset <= offset - 200; -- Passo de ajuste fino imediato
                        end if;
                        repeat_timer <= 0;
                    elsif tick_1ms = '1' then
                        if repeat_timer >= 300 then -- Aguarda 300ms de segurada inicial
                            if offset > -50000 then
                                offset <= offset - 200; -- Incremento contínuo a cada 40ms
                            end if;
                            repeat_timer <= 260; -- Reseta para o próximo pulso em 40ms (300 - 260)
                        else
                            repeat_timer <= repeat_timer + 1;
                        end if;
                    end if;

                -- KEY2 mantido pressionado (Desce frequência / aumenta limite divisor)
                elsif key_down_sync(2) = '0' then
                    if key_down_pressed = '1' then
                        if offset < 50000 then
                            offset <= offset + 200; -- Passo de ajuste fino imediato
                        end if;
                        repeat_timer <= 0;
                    elsif tick_1ms = '1' then
                        if repeat_timer >= 300 then
                            if offset < 50000 then
                                offset <= offset + 200; -- Incremento contínuo a cada 40ms
                            end if;
                            repeat_timer <= 260; -- Reseta para o próximo pulso em 40ms
                        else
                            repeat_timer <= repeat_timer + 1;
                        end if;
                    end if;

                else
                    repeat_timer <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Limite de contagem total (Frequência Ajustada = limite_base + offset)
    limite_contagem <= to_unsigned(limite_base + offset, 20);

    -- 6. Processo do Divisor de Frequência Principal
    process(clock_50)
    begin
        if rising_edge(clock_50) then
            if enabl = '1' then
                
                -- Se o contador atingiu o limite dinâmico...
                if contagem >= limite_contagem then
                    contagem <= (others => '0'); -- Zera o contador
                    estado_osc <= not estado_osc; -- Inverte o sinal de clock (gera a onda quadrada)
                    
                    -- Ativa as saídas de aviso de limite (flags)
                    aebOutput <= '1';
                    led_clear_osc <= '1';
                else
                    -- Continua contando
                    contagem <= contagem + 1;
                    
                    -- Desativa as saídas de aviso
                    aebOutput <= '0';
                    led_clear_osc <= '0';
                end if;
                
            else
                -- Se o enable (SW0) estiver desligado, zera e "congela" a oscilação em zero
                contagem <= (others => '0');
                estado_osc <= '0';
                aebOutput <= '0';
                led_clear_osc <= '1';
            end if;
        end if;
    end process;

end architecture Comportamento;
