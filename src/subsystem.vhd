library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity subsystem is
  port (
    clk     : in    std_logic;
    reset_x : in    std_logic;
    enb     : in    std_logic;
    out1    : out   std_logic_vector(31 downto 0)  -- sfix32_En24
  );
end entity subsystem;

architecture rtl of subsystem is

  -- Signals
  signal hdl_counter_ctrl_const_out  : std_logic;
  signal hdl_counter_ctrl_delay_out  : std_logic;
  signal hdl_counter_initial_val_out : signed(6 downto 0);  -- sfix7
  signal count_step                  : signed(6 downto 0);  -- sfix7
  signal hdl_counter_out1            : signed(6 downto 0);  -- sfix7
  signal count                       : signed(6 downto 0);  -- sfix7
  signal hdl_counter_out             : signed(6 downto 0);  -- sfix7
  signal gain_mul_temp               : signed(38 downto 0); -- sfix39_En24
  signal gain_out1                   : signed(31 downto 0); -- sfix32_En24

begin

  hdl_counter_ctrl_const_out <= '1';

  hdl_counter_ctrl_delay_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        hdl_counter_ctrl_delay_out <= '0';
      elsif (enb = '1') then
        hdl_counter_ctrl_delay_out <= hdl_counter_ctrl_const_out;
      end if;
    end if;

  end process hdl_counter_ctrl_delay_process;

  hdl_counter_initial_val_out <= to_signed(-16#40#, 7);

  -- Free running, Signed Counter
  --  initial value   = -64
  --  step value      = 1
  count_step <= to_signed(16#01#, 7);

  count <= hdl_counter_out1 + count_step;

  hdl_counter_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        hdl_counter_out <= to_signed(16#00#, 7);
      elsif (enb = '1') then
        hdl_counter_out <= count;
      end if;
    end if;

  end process hdl_counter_process;

  hdl_counter_out1 <= hdl_counter_initial_val_out when hdl_counter_ctrl_delay_out = '0' else
                      hdl_counter_out;

  gain_mul_temp <= to_signed(823550, 32) * hdl_counter_out1;
  gain_out1     <= gain_mul_temp(31 downto 0);

  out1 <= std_logic_vector(gain_out1);

end architecture rtl;

