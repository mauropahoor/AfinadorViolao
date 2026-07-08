library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lpm_counter1 is
    port (
        clock  : in  std_logic;
        cnt_en : in  std_logic;
        updown : in  std_logic;
        q      : out std_logic_vector(19 downto 0)
    );
end entity lpm_counter1;

architecture Comportamento of lpm_counter1 is
    signal contagem : unsigned(19 downto 0) := (others => '0');
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if cnt_en = '1' then
                if updown = '1' then
                    contagem <= contagem + 1; -- Conta para cima
                else
                    contagem <= contagem - 1; -- Conta para baixo
                end if;
            end if;
        end if;
    end process;
    
    q <= std_logic_vector(contagem);
end architecture Comportamento;