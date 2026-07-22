library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LimitGenerator is
    PORT (
        selecao_corda : IN std_logic_vector(2 downto 0);
        limit_mdup    : OUT std_logic_vector(19 downto 0);
        limit_dup     : OUT std_logic_vector(19 downto 0);
        limit_ddown   : OUT std_logic_vector(19 downto 0);
        limit_mddown  : OUT std_logic_vector(19 downto 0)
    );
end LimitGenerator;

architecture behavior of LimitGenerator is
begin
    process(selecao_corda)
    begin
        case selecao_corda is
            when "000" => -- E2 (Mi grave)
                limit_mdup   <= std_logic_vector(to_unsigned(599776, 20));
                limit_dup    <= std_logic_vector(to_unsigned(604996, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(608500, 20));
                limit_mddown <= std_logic_vector(to_unsigned(613795, 20));
                
            when "001" => -- A2 (Lá)
                limit_mdup   <= std_logic_vector(to_unsigned(449377, 20));
                limit_dup    <= std_logic_vector(to_unsigned(453232, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(455859, 20));
                limit_mddown <= std_logic_vector(to_unsigned(459818, 20));
                
            when "010" => -- D3 (Ré)
                limit_mdup   <= std_logic_vector(to_unsigned(336658, 20));
                limit_dup    <= std_logic_vector(to_unsigned(339547, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(341514, 20));
                limit_mddown <= std_logic_vector(to_unsigned(344481, 20));
                
            when "011" => -- G3 (Sol)
                limit_mdup   <= std_logic_vector(to_unsigned(252198, 20));
                limit_dup    <= std_logic_vector(to_unsigned(254364, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(255839, 20));
                limit_mddown <= std_logic_vector(to_unsigned(258062, 20));
                
            when "100" => -- B3 (Si)
                limit_mdup   <= std_logic_vector(to_unsigned(200176, 20));
                limit_dup    <= std_logic_vector(to_unsigned(201893, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(203063, 20));
                limit_mddown <= std_logic_vector(to_unsigned(204827, 20));
                
            when "101" => -- E4 (Mi agudo)
                limit_mdup   <= std_logic_vector(to_unsigned(149960, 20));
                limit_dup    <= std_logic_vector(to_unsigned(151247, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(152124, 20));
                limit_mddown <= std_logic_vector(to_unsigned(153445, 20));
                
            when others => -- Valor padrão (Mi grave)
                limit_mdup   <= std_logic_vector(to_unsigned(599776, 20));
                limit_dup    <= std_logic_vector(to_unsigned(604996, 20));
                limit_ddown  <= std_logic_vector(to_unsigned(608500, 20));
                limit_mddown <= std_logic_vector(to_unsigned(613795, 20));
        end case;
    end process;
end behavior;
