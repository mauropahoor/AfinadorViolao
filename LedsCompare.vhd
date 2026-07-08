library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity LedsCompare is
PORT (
periodo : IN std_logic_vector(19 downto 0);
mdup, dup, afinado, ddown, mddown: OUT std_logic
);
end LedsCompare;
architecture behavior of LedsCompare is
constant real_mdup_period : integer := 599776;
constant real_dup_period : integer := 604996;
constant real_ddown_period : integer := 608500;
constant real_mddown_period : integer := 613795;
constant simulation_mdup_period : integer := 20;
constant simulation_dup_period : integer := 25;
constant simulation_ddown_period : integer := 35;
constant simulation_mddown_period : integer := 40;
begin
process(periodo) is
begin
mdup <= '0';
dup <= '0';
afinado <= '0';
ddown <= '0';
mddown <= '0';
if (to_integer(unsigned(periodo)) < real_mdup_period) then
	mdup <= '1';
elsif (to_integer(unsigned(periodo)) < real_dup_period) then
	dup <= '1';
elsif (to_integer(unsigned(periodo)) < real_ddown_period) then
	afinado <= '1';
elsif (to_integer(unsigned(periodo)) < real_mddown_period) then
	ddown <= '1';
elsif (to_integer(unsigned(periodo)) > real_mddown_period) then
mddown <= '1';
end if;
end process;
end behavior;