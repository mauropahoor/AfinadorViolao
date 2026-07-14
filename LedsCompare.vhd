library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity LedsCompare is
PORT (
periodo : IN std_logic_vector(19 downto 0);
selecao_corda : IN std_logic_vector(2 downto 0); -- Entrada de seleção de 3 bits para as 6 cordas
mdup, dup, afinado, ddown, mddown: OUT std_logic
);
end LedsCompare;
architecture behavior of LedsCompare is
begin
process(periodo, selecao_corda) is
    variable v_mdup_period   : integer;
    variable v_dup_period    : integer;
    variable v_ddown_period  : integer;
    variable v_mddown_period : integer;
begin
    -- Seleciona os limites de contagem de acordo com a corda escolhida
    case selecao_corda is
        when "000" => -- E2 (Mi grave) - 82.41 Hz
            v_mdup_period   := 599776;
            v_dup_period    := 604996;
            v_ddown_period  := 608500;
            v_mddown_period := 613795;
            
        when "001" => -- A2 (Lá) - 110.00 Hz
            v_mdup_period   := 449377;
            v_dup_period    := 453232;
            v_ddown_period  := 455859;
            v_mddown_period := 459818;
            
        when "010" => -- D3 (Ré) - 146.83 Hz
            v_mdup_period   := 336658;
            v_dup_period    := 339547;
            v_ddown_period  := 341514;
            v_mddown_period := 344481;
            
        when "011" => -- G3 (Sol) - 196.00 Hz
            v_mdup_period   := 252198;
            v_dup_period    := 254364;
            v_ddown_period  := 255839;
            v_mddown_period := 258062;
            
        when "100" => -- B3 (Si) - 246.94 Hz
            v_mdup_period   := 200176;
            v_dup_period    := 201893;
            v_ddown_period  := 203063;
            v_mddown_period := 204827;
            
        when "101" => -- E4 (Mi agudo) - 329.63 Hz
            v_mdup_period   := 149960;
            v_dup_period    := 151247;
            v_ddown_period  := 152124;
            v_mddown_period := 153445;
            
        when others => -- Valor padrão (Mi grave)
            v_mdup_period   := 599776;
            v_dup_period    := 604996;
            v_ddown_period  := 608500;
            v_mddown_period := 613795;
    end case;

    -- Lógica de comparação com os limites dinâmicos
    mdup <= '0';
    dup <= '0';
    afinado <= '0';
    ddown <= '0';
    mddown <= '0';

    if (to_integer(unsigned(periodo)) < v_mdup_period) then
        mdup <= '1';
    elsif (to_integer(unsigned(periodo)) < v_dup_period) then
        dup <= '1';
    elsif (to_integer(unsigned(periodo)) < v_ddown_period) then
        afinado <= '1';
    elsif (to_integer(unsigned(periodo)) < v_mddown_period) then
        ddown <= '1';
    else
        mddown <= '1'; -- Acende mddown se for igual ou maior que v_mddown_period
    end if;
end process;
end behavior;
