library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registrador is
    generic (
        -- Largura do barramento (pode alterar este valor no diagrama de blocos)
        LPM_WIDTH : integer := 8 
    );
    port (
        clk     : in  std_logic;
        reset   : in  std_logic; -- Reset assíncrono (ativo em nível alto)
        enable  : in  std_logic; -- Enable (ativo em nível alto)
        data    : in  std_logic_vector(LPM_WIDTH-1 downto 0);
        q       : out std_logic_vector(LPM_WIDTH-1 downto 0)
    );
end entity registrador;

architecture Comportamento of registrador is
begin
    process(clk, reset)
    begin
        -- Condição de Reset Assíncrono
        if reset = '1' then
            q <= (others => '0'); -- Limpa todas as saídas para '0'
            
        -- Condição de transição de subida do Clock
        elsif rising_edge(clk) then
            -- Apenas atualiza a saída se o Enable estiver ativo
            if enable = '1' then
                q <= data;
            end if;
        end if;
    end process;
end architecture Comportamento;