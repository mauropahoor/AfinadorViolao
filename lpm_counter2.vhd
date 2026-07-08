library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lpm_counter2 is
    port (
        clock : in  std_logic;
        sclr  : in  std_logic;
        q     : out std_logic_vector(19 downto 0)
    );
end entity lpm_counter2;

architecture Comportamento of lpm_counter2 is
    signal contagem : unsigned(19 downto 0) := (others => '0');
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if sclr = '1' then
                contagem <= (others => '0');
            else
                contagem <= contagem + 1;
            end if;
        end if;
    end process;
    
    q <= std_logic_vector(contagem);
end architecture Comportamento;