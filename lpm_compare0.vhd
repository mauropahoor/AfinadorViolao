library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lpm_compare0 is
    port (
        dataa : in  std_logic_vector(19 downto 0);
        datab : in  std_logic_vector(19 downto 0);
        aeb   : out std_logic
    );
end entity lpm_compare0;

architecture Comportamento of lpm_compare0 is
begin
    aeb <= '1' when (dataa = datab) else '0';
end architecture Comportamento;