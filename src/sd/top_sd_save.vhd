library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity top_sd_save is
  port (

    clk          : in    STD_LOGIC;                                          -- Main clock, frequency given by generic CLK_FREQ_HZ
    reset        : in    STD_LOGIC;                                          -- reset, active high
    

    rvd_error_capture_enable   : in    STD_LOGIC;     -- from RVD
    rvd_error_msg : in std_logic_vector(127 downto 0); -- from RVD

    inject_error : in std_logic; -- SW0
    flush_force : in std_logic; -- activation forcé du flush de la sd
    -- Quand inject_error = '1' cela génère l'ecriture dans la mémoire du message d'érreur de debug dans la carte SD
    -- pour réécrire un nouveau message d'érreur dans la carte SD il faut que inject_error repasse à 0 avant de reprendre l'état '1' !!
    -- un générateur d'impulsion est utilisé pour transformé un front montant de inject_error en un état '1' pendant 1 période d'horloge (simulant ainsi le comportement du CPU)
    

    sd_debug        : out   STD_LOGIC_VECTOR( 5 downto 0);                      -- only meaningfull for debug or error read
    sd_error     : out   STD_LOGIC;                                          -- '1' if an error occured, error value is in debug output
                
    SD_DAT       : inout STD_LOGIC_VECTOR( 3 downto 0);                      -- DATA line for SDcard access
    SD_CD        : in    STD_LOGIC;                                          -- SDcard detected (active low)
    -- SD_WP        : in    STD_LOGIC:='0';                                     -- (optional) SDcard physical write protection indicator
    SD_CLK       : out   STD_LOGIC;                                          -- Communication clock
    SD_CMD       : inout STD_LOGIC;


    -- DEBUG
    -- signaux de debug pour le module SDcard_writestream
    sd_fsm_state    : out std_logic_vector(7 downto 0);
    sd_rst_debug : out std_logic;
    sd_busy_debug : out std_logic;
    sd_module_state_debug : out std_logic_vector(7 downto 0);

    -- signaux de debug pour le module error_to_sd
    error_to_sd_counter_debug : out std_logic_vector(3 downto 0);
    error_to_sd_status_debug : out std_logic;
    error_to_sd_fsm_state_debug : out std_logic_vector(1 downto 0);

    -- internal signal for debug
    alu_error_capture_debug : out std_logic;
    error_msg_debug : out std_logic_vector(127 downto 0);
    data_full_n_debug : out std_logic;
    we_debug : out std_logic;
    data_debug : out std_logic_vector(7 downto 0);
    final_flush_debug : out std_logic
  );
end entity top_sd_save;

architecture behavioral of top_sd_save is
    
    component SDcard_writestream is
        Generic(CLK_FREQ_HZ         : integer := 125000000; -- 100000000;           -- the frequency of the clock expressed in Hz
                VIVADO_SYNTH        : boolean := True;                -- select the correct part of code to use to get a proper RAM implementation in vivado
                WORD_SIZE_PW2       : integer range 0 to 3 := 0;      -- codes the data size of interface : it is 2^WORD_SIZE_PW2 bytes
                PRE_ERASE           : boolean := True;                -- determines if the SDcard should first be pre-erased to improve performance
                HIGH_SPEED_IF       : boolean := False;               -- When True, runs SDcard bus @50MHz (might not be reliable)
                LITTLE_ENDIAN       : boolean := True
        ); 
        Port ( clk          : in    STD_LOGIC;                                          -- Main clock, frequency given by generic CLK_FREQ_HZ
               reset        : in    STD_LOGIC;                                          -- reset, active high
               
               data_in      : in    STD_LOGIC_VECTOR(8*(2**WORD_SIZE_PW2)-1 downto 0);  -- stream data input
               data_write   : in    STD_LOGIC;                                          -- data write, tells the module to write data_in
               data_full_n  : out   STD_LOGIC;                                          -- '1' when it is possible to write
               
               final_flush  : in    STD_LOGIC := '0';                                   -- optional data flush
               
               debug        : out   STD_LOGIC_VECTOR( 5 downto 0);                      -- only meaningfull for debug or error read
               sd_error     : out   STD_LOGIC;                                          -- '1' if an error occured, error value is in debug output
                          
               SD_DAT       : inout STD_LOGIC_VECTOR( 3 downto 0);                      -- DATA line for SDcard access
               SD_CD        : in    STD_LOGIC;                                          -- SDcard detected (active low)
               SD_WP        : in    STD_LOGIC:='0';                                     -- (optional) SDcard physical write protection indicator
               SD_CLK       : out   STD_LOGIC;                                          -- Communication clock
               SD_CMD       : inout STD_LOGIC;
               fsm_state    : out std_logic_vector(7 downto 0);
               rst_debug : out std_logic;
               busy_debug : out std_logic;
               module_state_debug : out std_logic_vector(7 downto 0)
               );                                         -- Command line
    
    end component;

    -- fsm pour envoyer les 16 octets corréspondant au message d'erreur de 128 bits
    component error_to_sd is
        port (
          clk : in std_logic;
          reset : in std_logic;
          error_msg : in std_logic_vector((128 - 1) downto 0);
          alu_error_capture : in std_logic;
          data_full_n : in std_logic;
          we : out std_logic; -- write enable for SD card module
          data : out std_logic_vector(7 downto 0);
          counter_debug : out std_logic_vector(3 downto 0);
          status_debug : out std_logic;
          final_flush : out std_logic;
          fsm_state_debug : out std_logic_vector(1 downto 0)
        );
    end component;

    component mux2_1bits is
    port (
          in1    : in    std_logic;
          in2    : in    std_logic;
          sel    : in    std_logic;
          o      : out   std_logic
        );
    end component;

    component mux2 is
        generic (
          size : integer := 8
        );
        port (
          in1 : in    std_logic_vector(size - 1 downto 0);
          in2 : in    std_logic_vector(size - 1 downto 0);
          sel : in    std_logic;
          o   : out   std_logic_vector(size - 1 downto 0)
        );
    end component;

    component impul is
        port (
          clk : in std_logic;
          val_in : in std_logic;
          val_out : out std_logic
        );
    end component;
    
    -- constant & signal

    constant gnd : std_logic := '0';
    constant constant_error_msg_debug : std_logic_vector(127 downto 0) := x"0f0e0d0c0b0a09080706050403020100";
    constant error_msg_size : integer := 128;
    constant CLK_FREQ_HZ : integer := 100000000;


    signal s_data_in     : std_logic_vector(7 downto 0);
    signal s_data_write  : std_logic;
    signal s_data_full_n : std_logic;
    
    signal s_final_flush : std_logic;

    signal s_inject_error_impul : std_logic;
    
    signal s_error_msg : std_logic_vector(127 downto 0);
    signal s_alu_error_capture : std_logic;
    


begin

    inst_impul : component impul
    port map(
        clk => clk,
        val_in => inject_error,
        val_out => s_inject_error_impul
    );

    inst_mux2_1bits : component mux2_1bits
    port map (
            in1 => rvd_error_capture_enable,
            in2 => s_inject_error_impul, -- inject_error = '1' => laisse passer une impulsion
            sel => inject_error,
            o   => s_alu_error_capture
    );

    inst_mux2 : component mux2
    generic map (
        size => error_msg_size
    )
    port map (
        in1 => rvd_error_msg,
        in2 => constant_error_msg_debug,
        sel => inject_error,
        o   => s_error_msg
    );

    

    inst_SDcard_writestream : component SDcard_writestream
    generic map (
      CLK_FREQ_HZ => CLK_FREQ_HZ,
      VIVADO_SYNTH => True,
      WORD_SIZE_PW2 => 0,
      PRE_ERASE => True,
      HIGH_SPEED_IF => False,
      LITTLE_ENDIAN => True
    ) 
    port map (
        clk => clk,
        reset => reset,
        
        data_in => s_data_in,
        data_write => s_data_write,
        data_full_n => s_data_full_n,
        
        final_flush => s_final_flush or flush_force,
        
        debug => sd_debug,
        sd_error => sd_error,
                
        SD_DAT => SD_DAT,
        SD_CD => SD_CD,
        SD_WP => gnd,
        SD_CLK => SD_CLK,
        SD_CMD => SD_CMD,
        fsm_state => sd_fsm_state,
        rst_debug => sd_rst_debug,
        busy_debug => sd_busy_debug,
        module_state_debug => sd_module_state_debug
    );

    

    inst_error_to_sd : component error_to_sd 
        port map (
          clk => clk,
          reset => reset,
          error_msg => s_error_msg, -- from RVD OR error_msg_debug
          alu_error_capture => s_alu_error_capture,
          data_full_n => s_data_full_n,
          we => s_data_write, -- write enable for SD card module
          data => s_data_in,
          counter_debug => error_to_sd_counter_debug,
          status_debug => error_to_sd_status_debug,
          final_flush => s_final_flush,
          fsm_state_debug => error_to_sd_fsm_state_debug
        );

    alu_error_capture_debug <= s_alu_error_capture;
    error_msg_debug <= s_error_msg;
    data_full_n_debug <= s_data_full_n;
    we_debug <= s_data_write;
    data_debug <= s_data_in;
    final_flush_debug <= s_final_flush or flush_force;

end architecture behavioral;

