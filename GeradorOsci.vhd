library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity geradorOsc_vhdl is
    generic (
        -- Limite padrão de contagem para o divisor de clock (pode ser sobrescrito pelo genérico se necessário)
        MAX_COUNT : integer := 1000000 
    );
    port (
        -- Entradas
        clock_27      : in  std_logic;
        enabl         : in  std_logic;
        up_down       : in  std_logic;
        selecao_corda : in  std_logic_vector(2 downto 0); -- Seletor de 3 bits para a simulação de cordas
        
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
    signal limite_contagem : unsigned(19 downto 0);
begin

    -- Ligação direta das chaves/botões para os LEDs (apenas para visualização na placa)
    led_enab   <= enabl;
    led_updown <= up_down;
    
    -- Ligando os sinais internos nas saídas
    osc            <= estado_osc;
    osc_visualizer <= std_logic_vector(contagem);

    -- Determina o limite da contagem de divisão baseando-se no clock de 27 MHz
    limite_contagem <= to_unsigned(163815, 20) when selecao_corda = "000" else -- E2 (82.41 Hz) -> 27MHz/(2*163815) = 82.41 Hz
                       to_unsigned(122727, 20) when selecao_corda = "001" else -- A2 (110.00 Hz) -> 27MHz/(2*122727) = 110.00 Hz
                       to_unsigned(91943, 20)  when selecao_corda = "010" else -- D3 (146.83 Hz) -> 27MHz/(2*91943) = 146.83 Hz
                       to_unsigned(68878, 20)  when selecao_corda = "011" else -- G3 (196.00 Hz) -> 27MHz/(2*68878) = 196.00 Hz
                       to_unsigned(54669, 20)  when selecao_corda = "100" else -- B3 (246.94 Hz) -> 27MHz/(2*54669) = 246.94 Hz
                       to_unsigned(40955, 20)  when selecao_corda = "101" else -- E4 (329.63 Hz) -> 27MHz/(2*40955) = 329.63 Hz
                       to_unsigned(MAX_COUNT, 20); -- Default caso não corresponda a nenhuma corda (ou utilize o valor genérico)
    
    -- Processo do Divisor de Frequência
    process(clock_27)
    begin
        if rising_edge(clock_27) then
            -- Só funciona se o botão enable (enabl) estiver ativado
            if enabl = '1' then
                
                -- Se o contador atingiu o limite dinâmico...
                if contagem >= limite_contagem then
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
