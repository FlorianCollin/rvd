library ieee;
use ieee.std_logic_1164.all;

entity tb_error_to_sd is
end tb_error_to_sd;

architecture tb of tb_error_to_sd is

    component error_to_sd
        port (clk               : in std_logic;
              error_msg         : in std_logic_vector ((128 - 1) downto 0);
              alu_error_capture : in std_logic;
              data_full_n       : in std_logic;
              we                : out std_logic;
              data              : out std_logic_vector (7 downto 0);
              counter_debug     : out std_logic_vector (3 downto 0);
              status_debug      : out std_logic;
              final_flush       : out std_logic);
    end component;

    signal clk               : std_logic;
    signal error_msg         : std_logic_vector ((128 - 1) downto 0);
    signal alu_error_capture : std_logic;
    signal data_full_n       : std_logic;
    signal we                : std_logic;
    signal data              : std_logic_vector (7 downto 0);
    signal counter_debug     : std_logic_vector (3 downto 0);
    signal status_debug      : std_logic;
    signal final_flush       : std_logic;

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : error_to_sd
    port map (clk               => clk,
              error_msg         => error_msg,
              alu_error_capture => alu_error_capture,
              data_full_n       => data_full_n,
              we                => we,
              data              => data,
              counter_debug     => counter_debug,
              status_debug      => status_debug,
              final_flush       => final_flush);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        error_msg <= (others => '0');
        alu_error_capture <= '0';
        data_full_n <= '1';
        wait for 100 ns;
        alu_error_capture <= '1';
        error_msg <= x"0f0e0d0c0b0a09080706050403020100";
        wait for 40 ns;
        alu_error_capture <= '0';
        wait for 100 * TbPeriod;

   
        wait;
    end process;

end tb;