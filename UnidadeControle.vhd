library ieee;
use ieee.std_logic_1164.all;

entity UnidadeControle is
    port (
        CLK          : in  std_logic;
        RESET        : in  std_logic;
        OSC_INPUT    : in  std_logic;
        LOAD_OUTPUT  : out std_logic;
        CLEAR_OUTPUT : out std_logic
    );
end UnidadeControle;

architecture Behavioral of UnidadeControle is
    type state_type is (STATE1, LDCD, STATE2);
    signal current_state, next_state : state_type;
begin

    -- Processo sequencial: atualiza o estado na borda de subida do clock
    process (CLK, RESET)
    begin
        if RESET = '1' then
            current_state <= STATE1;
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;

    -- Processo combinacional: define proximo estado e saidas
    process (current_state, OSC_INPUT)
    begin
        -- Valores padrao
        LOAD_OUTPUT  <= '0';
        CLEAR_OUTPUT <= '0';
        next_state   <= current_state;

        case current_state is
            when STATE1 =>
                if OSC_INPUT = '1' then
                    next_state <= LDCD;
                end if;

            when LDCD =>
                LOAD_OUTPUT  <= '1';
                CLEAR_OUTPUT <= '1';
                next_state   <= STATE2;

            when STATE2 =>
                if OSC_INPUT = '0' then
                    next_state <= STATE1;
                end if;

            when others =>
                next_state <= STATE1;
        end case;
    end process;

end Behavioral;