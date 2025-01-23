library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity cordic_stage_0 is
  port (
    clk     : in    std_logic;
    reset_x : in    std_logic;
    enb     : in    std_logic;
    x0      : in    std_logic_vector(31 downto 0); -- sfix32_En24
    y0      : in    std_logic_vector(31 downto 0); -- sfix32_En24
    z0      : in    std_logic_vector(31 downto 0); -- sfix32_En24
    rot     : in    std_logic;
    x1      : out   std_logic_vector(31 downto 0); -- sfix32_En24
    y1      : out   std_logic_vector(31 downto 0); -- sfix32_En24
    z1      : out   std_logic_vector(31 downto 0)  -- sfix32_En24
  );
end entity cordic_stage_0;

architecture rtl of cordic_stage_0 is

  -- Signals
  signal y0_signed          : signed(31 downto 0); -- sfix32_En24
  signal z0_signed          : signed(31 downto 0); -- sfix32_En24
  signal switch3_out1       : signed(31 downto 0); -- sfix32_En24
  signal switch_compare_1   : std_logic;
  signal x0_signed          : signed(31 downto 0); -- sfix32_En24
  signal sum3_out1          : signed(31 downto 0); -- sfix32_En24
  signal sum_out1           : signed(31 downto 0); -- sfix32_En24
  signal switch_out1        : signed(31 downto 0); -- sfix32_En24
  signal delay_out1         : signed(31 downto 0); -- sfix32_En24
  signal switch_compare_1_1 : std_logic;
  signal sum5_out1          : signed(31 downto 0); -- sfix32_En24
  signal sum4_out1          : signed(31 downto 0); -- sfix32_En24
  signal switch1_out1       : signed(31 downto 0); -- sfix32_En24
  signal delay1_out1        : signed(31 downto 0); -- sfix32_En24
  signal switch_compare_1_2 : std_logic;
  signal constant18_out1    : signed(31 downto 0); -- sfix32_En24
  signal sum2_out1          : signed(31 downto 0); -- sfix32_En24
  signal sum1_out1          : signed(31 downto 0); -- sfix32_En24
  signal switch2_out1       : signed(31 downto 0); -- sfix32_En24
  signal delay2_out1        : signed(31 downto 0); -- sfix32_En24

begin

  y0_signed <= signed(y0);

  z0_signed <= signed(z0);

  switch3_out1 <= y0_signed when rot = '0' else
                  z0_signed;

  switch_compare_1 <= '1' when switch3_out1 >= to_signed(0, 32) else
                      '0';

  x0_signed <= signed(x0);

  sum3_out1 <= x0_signed + y0_signed;

  sum_out1 <= x0_signed - y0_signed;

  switch_out1 <= sum3_out1 when switch_compare_1 = '0' else
                 sum_out1;

  delay_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_out1 <= to_signed(0, 32);
      elsif (enb = '1') then
        delay_out1 <= switch_out1;
      end if;
    end if;

  end process delay_process;

  x1 <= std_logic_vector(delay_out1);

  switch_compare_1_1 <= '1' when switch3_out1 >= to_signed(0, 32) else
                        '0';

  sum5_out1 <= y0_signed - x0_signed;

  sum4_out1 <= x0_signed + y0_signed;

  switch1_out1 <= sum5_out1 when switch_compare_1_1 = '0' else
                  sum4_out1;

  delay1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_out1 <= to_signed(0, 32);
      elsif (enb = '1') then
        delay1_out1 <= switch1_out1;
      end if;
    end if;

  end process delay1_process;

  y1 <= std_logic_vector(delay1_out1);

  switch_compare_1_2 <= '1' when switch3_out1 >= to_signed(0, 32) else
                        '0';

  constant18_out1 <= to_signed(13176795, 32);

  sum2_out1 <= constant18_out1 + z0_signed;

  sum1_out1 <= z0_signed - constant18_out1;

  switch2_out1 <= sum2_out1 when switch_compare_1_2 = '0' else
                  sum1_out1;

  delay2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay2_out1 <= to_signed(0, 32);
      elsif (enb = '1') then
        delay2_out1 <= switch2_out1;
      end if;
    end if;

  end process delay2_process;

  z1 <= std_logic_vector(delay2_out1);

end architecture rtl;

