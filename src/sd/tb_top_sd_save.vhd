library ieee;
use ieee.std_logic_1164.all;

entity tb_top_sd_save is
end tb_top_sd_save;

architecture tb of tb_top_sd_save is

    component top_sd_save
        port (clk                       : in std_logic;
              reset                     : in std_logic;
              rvd_error_capture_enable  : in std_logic;
              rvd_error_msg             : in std_logic_vector (127 downto 0);
              inject_error              : in std_logic;
              sd_debug                  : out std_logic_vector (5 downto 0);
              sd_error                  : out std_logic;
              SD_DAT                    : inout std_logic_vector (3 downto 0);
              SD_CD                     : in std_logic;
              SD_CLK                    : out std_logic;
              SD_CMD                    : inout std_logic;
              sd_fsm_state              : out std_logic_vector (7 downto 0);
              sd_rst_debug              : out std_logic;
              sd_busy_debug             : out std_logic;
              sd_module_state_debug     : out std_logic_vector (7 downto 0);
              error_to_sd_counter_debug : out std_logic_vector (3 downto 0);
              error_to_sd_status_debug  : out std_logic;
              alu_error_capture_debug   : out std_logic;
              error_msg_debug           : out std_logic_vector (127 downto 0);
              data_full_n_debug         : out std_logic;
              we_debug                  : out std_logic;
              data_debug                : out std_logic_vector (7 downto 0);
              final_flush_debug         : out std_logic;
              error_to_sd_fsm_state_debug : out std_logic_vector(1 downto 0)
              );
    end component;

    signal clk                       : std_logic;
    signal reset                     : std_logic;
    signal rvd_error_capture_enable  : std_logic;
    signal rvd_error_msg             : std_logic_vector (127 downto 0);
    signal inject_error              : std_logic;
    signal sd_debug                  : std_logic_vector (5 downto 0);
    signal sd_error                  : std_logic;
    signal SD_DAT                    : std_logic_vector (3 downto 0);
    signal SD_CD                     : std_logic;
    signal SD_CLK                    : std_logic;
    signal SD_CMD                    : std_logic;
    signal sd_fsm_state              : std_logic_vector (7 downto 0);
    signal sd_rst_debug              : std_logic;
    signal sd_busy_debug             : std_logic;
    signal sd_module_state_debug     : std_logic_vector (7 downto 0);
    signal error_to_sd_counter_debug : std_logic_vector (3 downto 0);
    signal error_to_sd_status_debug  : std_logic;
    signal alu_error_capture_debug   : std_logic;
    signal error_msg_debug           : std_logic_vector (127 downto 0);
    signal data_full_n_debug         : std_logic;
    signal we_debug                  : std_logic;
    signal data_debug                : std_logic_vector (7 downto 0);
    signal final_flush_debug         : std_logic;
    signal error_to_sd_fsm_state_debug : std_logic_vector(1 downto 0);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : top_sd_save
    port map (clk                       => clk,
              reset                     => reset,
              rvd_error_capture_enable  => rvd_error_capture_enable,
              rvd_error_msg             => rvd_error_msg,
              inject_error              => inject_error,
              sd_debug                  => sd_debug,
              sd_error                  => sd_error,
              SD_DAT                    => SD_DAT,
              SD_CD                     => SD_CD,
              SD_CLK                    => SD_CLK,
              SD_CMD                    => SD_CMD,
              sd_fsm_state              => sd_fsm_state,
              sd_rst_debug              => sd_rst_debug,
              sd_busy_debug             => sd_busy_debug,
              sd_module_state_debug     => sd_module_state_debug,
              error_to_sd_counter_debug => error_to_sd_counter_debug,
              error_to_sd_status_debug  => error_to_sd_status_debug,
              alu_error_capture_debug   => alu_error_capture_debug,
              error_msg_debug           => error_msg_debug,
              data_full_n_debug         => data_full_n_debug,
              we_debug                  => we_debug,
              data_debug                => data_debug,
              final_flush_debug         => final_flush_debug,
              error_to_sd_fsm_state_debug => error_to_sd_fsm_state_debug);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        rvd_error_capture_enable <= '0';
        rvd_error_msg <= (others => '0');
        inject_error <= '0';
        SD_CD <= '0';

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        inject_error <= '1';
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
