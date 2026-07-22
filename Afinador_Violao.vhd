library ieee;
use ieee.std_logic_1164.all;

entity Afinador_Violao is
    port (
        -- Entradas
        pin_name1         : in  std_logic; -- Clock principal de 50 MHz
        clock_gerador     : in  std_logic; -- Clock secundário para o gerador (PIN_B14)
        btn_enable        : in  std_logic; -- Chave SW0 (Liga simulador e libera registrador)
        key_up            : in  std_logic; -- Botão KEY0 (Sobe frequência)
        key_down          : in  std_logic; -- Botão KEY2 (Desce frequência)
        selecao_corda     : in  std_logic_vector(2 downto 0); -- Chaves SW15-13
        
        -- Saídas dos LEDs Verdes (Status de Afinação)
        mddown            : out std_logic;
        ddown             : out std_logic;
        afinado           : out std_logic;
        dup               : out std_logic;
        mdup              : out std_logic;
        
        -- LEDs Auxiliares
        led_enab          : out std_logic;
        led_updown        : out std_logic;
        led_clear_osc     : out std_logic;
        geradorOsc_Output : out std_logic;
        unidadeControleTeste : out std_logic;
        aebOutput         : out std_logic;
        
        -- Saídas do Visor LCD 16x2
        LCD_ON            : out std_logic;
        LCD_RS            : out std_logic;
        LCD_RW            : out std_logic;
        LCD_EN            : out std_logic;
        LCD_DATA          : out std_logic_vector(7 downto 0);
        
        -- Visualizador de bits nos LEDs vermelhos (16 bits)
        osc_visualizer    : out std_logic_vector(15 downto 0)
    );
end entity Afinador_Violao;

architecture RTL of Afinador_Violao is

    -- 1. Declaração do componente Gerador de Oscilação
    component geradorOsc_vhdl is
        generic (
            MAX_COUNT : integer := 1000000 
        );
        port (
            clock_50      : in  std_logic;
            enabl         : in  std_logic;
            key_up        : in  std_logic;
            key_down      : in  std_logic;
            selecao_corda : in  std_logic_vector(2 downto 0);
            osc            : out std_logic;
            osc_visualizer : out std_logic_vector(19 downto 0);
            led_clear_osc  : out std_logic;
            aebOutput      : out std_logic
        );
    end component;

    -- 2. Declaração do componente Unidade de Controle (FSM)
    component UnidadeControle is
        port (
            CLK          : in  std_logic;
            RESET        : in  std_logic;
            OSC_INPUT    : in  std_logic;
            LOAD_OUTPUT  : out std_logic;
            CLEAR_OUTPUT : out std_logic
        );
    end component;

    -- 3. Declaração do componente Contador de Período
    component Counter is
        PORT (
            clear : IN std_logic;
            clock : IN std_logic;
            contador : BUFFER std_logic_vector(19 downto 0)
        );
    end component;

    -- 4. Declaração do componente Registrador de Período
    component registrador is
        generic (
            LPM_WIDTH : integer := 8 
        );
        port (
            clk     : in  std_logic;
            reset   : in  std_logic;
            enable  : in  std_logic;
            run     : in  std_logic;
            data    : in  std_logic_vector(LPM_WIDTH-1 downto 0);
            q       : out std_logic_vector(LPM_WIDTH-1 downto 0)
        );
    end component;

    -- 5. Declaração do componente Comparador de Leds
    component LedsCompare is
        PORT (
            periodo : IN std_logic_vector(19 downto 0);
            selecao_corda : IN std_logic_vector(2 downto 0);
            mdup, dup, afinado, ddown, mddown: OUT std_logic
        );
    end component;

    -- 6. Declaração do componente Controlador de LCD 16x2
    component LcdController is
        port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            selecao_corda : in  std_logic_vector(2 downto 0);
            periodo       : in  std_logic_vector(19 downto 0); -- Entrada adicionada
            mdup, dup     : in  std_logic;
            afinado       : in  std_logic;
            ddown, mddown : in  std_logic;
            LCD_ON        : out std_logic;
            LCD_EN        : out std_logic;
            LCD_RS        : out std_logic;
            LCD_RW        : out std_logic;
            LCD_DATA      : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Sinais Internos de Interconexão
    signal sig_osc              : std_logic;
    signal sig_osc_visualizer   : std_logic_vector(19 downto 0);
    signal sig_load             : std_logic;
    signal sig_clear            : std_logic;
    signal sig_contador         : std_logic_vector(19 downto 0);
    signal sig_periodo_salvo    : std_logic_vector(19 downto 0);
    
    -- Sinais de status de afinação internos
    signal sig_mdup, sig_dup    : std_logic;
    signal sig_afinado          : std_logic;
    signal sig_ddown, sig_mddown: std_logic;

begin

    -- Ligando saídas externas diretas do gerador
    geradorOsc_Output    <= sig_osc;
    osc_visualizer(15 downto 13) <= selecao_corda;
    osc_visualizer(12 downto 1) <= (others => '0');
    osc_visualizer(0)    <= btn_enable;
    unidadeControleTeste <= sig_load; -- Permite ver o pulso de LOAD
    
    -- LEDs auxiliares estáticos
    led_enab             <= btn_enable;
    led_updown           <= not key_up; -- Acende se KEY0 estiver sendo pressionado

    -- Instância 1: Gerador de Sinais Simulados
    inst_GeradorOsc : geradorOsc_vhdl
        generic map (
            MAX_COUNT => 163815
        )
        port map (
            clock_50      => clock_gerador,
            enabl         => btn_enable,
            key_up        => key_up,
            key_down      => key_down,
            selecao_corda => selecao_corda,
            osc            => sig_osc,
            osc_visualizer => sig_osc_visualizer,
            led_clear_osc  => led_clear_osc,
            aebOutput      => aebOutput
        );

    -- Instância 2: Unidade de Controle do Fluxo (FSM)
    inst_FSM : UnidadeControle
        port map (
            CLK          => pin_name1,
            RESET        => '0', -- Sem reset externo ativo
            OSC_INPUT    => sig_osc,
            LOAD_OUTPUT  => sig_load,
            CLEAR_OUTPUT => sig_clear
        );

    -- Instância 3: Contador de Ciclos de Clock
    inst_Contador : Counter
        port map (
            clear    => sig_clear,
            clock    => pin_name1,
            contador => sig_contador
        );

    -- Instância 4: Registrador de 20 bits (com trava SW0/run)
    inst_Registrador : registrador
        generic map (
            LPM_WIDTH => 20
        )
        port map (
            clk    => pin_name1,
            reset  => '0',
            enable => sig_load,
            run    => btn_enable,
            data   => sig_contador,
            q      => sig_periodo_salvo
        );

    -- Instância 5: Comparador de Limiares para Leds
    inst_Comparador : LedsCompare
        port map (
            periodo       => sig_periodo_salvo,
            selecao_corda => selecao_corda,
            mdup          => sig_mdup,
            dup           => sig_dup,
            afinado       => sig_afinado,
            ddown         => sig_ddown,
            mddown        => sig_mddown
        );

    -- Instancia saídas do comparador para a placa
    mdup    <= sig_mdup;
    dup     <= sig_dup;
    afinado <= sig_afinado;
    ddown   <= sig_ddown;
    mddown  <= sig_mddown;

    -- Instância 6: Controlador de Texto do Visor LCD 16x2
    inst_LCD : LcdController
        port map (
            clk           => pin_name1,
            reset         => '0',
            selecao_corda => selecao_corda,
            periodo       => sig_periodo_salvo, -- Período conectado
            mdup          => sig_mdup,
            dup           => sig_dup,
            afinado       => sig_afinado,
            ddown         => sig_ddown,
            mddown        => sig_mddown,
            LCD_ON        => LCD_ON,
            LCD_EN        => LCD_EN,
            LCD_RS        => LCD_RS,
            LCD_RW        => LCD_RW,
            LCD_DATA      => LCD_DATA
        );

end architecture RTL;
