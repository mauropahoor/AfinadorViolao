library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lpm_counter3 is
    port (
        clock : in  std_logic;
        q     : out std_logic_vector(19 downto 0);
        cout  : out std_logic
    );
end entity lpm_counter3;

architecture Comportamento of lpm_counter3 is
    signal contagem : unsigned(19 downto 0) := (others => '0');
begin
    process(clock)
    begin
        if rising_edge(clock) then
            contagem <= contagem + 1;
        end if;
    end process;
    
    q <= std_logic_vector(contagem);
    -- cout vai para '1' quando o contador atingir o máximo
    cout <= '1' when contagem = x"FFFFF" else '0'; 
end architecture Comportamento;