library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Counter is
PORT (
clear : IN std_logic;
clock : IN std_logic;
contador : BUFFER std_logic_vector(19 downto 0)
);
end entity Counter;
architecture behavior of Counter is
begin
process (clock, clear)
begin
	if rising_edge(clock) then
		if clear = '1' then
			contador <= (others => '0');
		elsif contador = "11111111111111111111" then
contador <= "11111111111111111111";
else
contador <= std_logic_vector(unsigned(contador) + 1);
end if;
end if;
end process;
end architecture behavior;