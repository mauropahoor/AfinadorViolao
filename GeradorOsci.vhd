library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity geradorOsc_vhdl is
    generic (
        -- Limite de contagem para dividir o clock. 
        -- Quanto maior o número, mais lento será o sinal 'osc'.
        MAX_COUNT : integer := 1000000 
    );
    port (
        -- Entradas
        clock_27 : in  std_logic;
        enabl    : in  std_logic;
        up_down  : in  std_logic;
        
        -- Saídas
        led_enab       : out std_logic;
        led_updown     : out std_logic;
        osc            : out std_logic;
        osc_visualizer : out std_logic_vector(19 downto 0);
        led_clear_osc  : out std_logic;
        aebOutput      : out std_logic
    );
end entity geradorOsc_vhdl;

architecture Comportamento of geradorOsc_vhdl is
    signal contagem : unsigned(19 downto 0) := (others => '0');
    signal estado_osc : std_logic := '0';
begin

    -- Ligação direta das chaves/botões para os LEDs (apenas para visualização na placa)
    led_enab   <= enabl;
    led_updown <= up_down;
    
    -- Ligando os sinais internos nas saídas
    osc            <= estado_osc;
    osc_visualizer <= std_logic_vector(contagem);
    
    -- Processo do Divisor de Frequência
    process(clock_27)
    begin
        if rising_edge(clock_27) then
            -- Só funciona se o botão enable (enabl) estiver ativado
            if enabl = '1' then
                
                -- Se o contador atingiu o limite máximo...
                if contagem >= MAX_COUNT then
                    contagem <= (others => '0'); -- Zera o contador
                    estado_osc <= not estado_osc; -- Inverte o sinal de clock (0 vira 1, 1 vira 0)
                    
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
                -- Se não estiver habilitado, zera tudo
                contagem <= (others => '0');
                estado_osc <= '0';
                aebOutput <= '0';
                led_clear_osc <= '1';
            end if;
        end if;
    end process;

end architecture Comportamento;