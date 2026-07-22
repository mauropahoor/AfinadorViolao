library ieee;
use ieee.std_logic_1164.all;

entity LedDecoder is
    PORT (
        comp_mdup   : IN std_logic; -- 1 se periodo < limit_mdup
        comp_dup    : IN std_logic; -- 1 se periodo < limit_dup
        comp_ddown  : IN std_logic; -- 1 se periodo < limit_ddown
        comp_mddown : IN std_logic; -- 1 se periodo < limit_mddown
        
        mdup        : OUT std_logic;
        dup         : OUT std_logic;
        afinado     : OUT std_logic;
        ddown       : OUT std_logic;
        mddown      : OUT std_logic
    );
end LedDecoder;

architecture behavior of LedDecoder is
begin
    process(comp_mdup, comp_dup, comp_ddown, comp_mddown)
    begin
        -- Zera todos os leds por padrão
        mdup    <= '0';
        dup     <= '0';
        afinado <= '0';
        ddown   <= '0';
        mddown  <= '0';
        
        -- Lógica de prioridade exatamente como no antigo if-else
        if comp_mdup = '1' then
            mdup <= '1';
        elsif comp_dup = '1' then
            dup <= '1';
        elsif comp_ddown = '1' then
            afinado <= '1';
        elsif comp_mddown = '1' then
            ddown <= '1';
        else
            mddown <= '1';
        end if;
    end process;
end behavior;
