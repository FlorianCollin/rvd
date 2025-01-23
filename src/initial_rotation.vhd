library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity initial_rotation is
  port (
    clk     : in    std_logic;
    reset_x : in    std_logic;
    enb     : in    std_logic;
    x_init  : in    std_logic_vector(31 downto 0); -- sfix32_En24
    y_init  : in    std_logic_vector(31 downto 0); -- sfix32_En24
    z_init  : in    std_logic_vector(31 downto 0); -- sfix32_En24
    inport  : in    std_logic;
    x0      : out   std_logic_vector(31 downto 0); -- sfix32_En24
    y0      : out   std_logic_vector(31 downto 0); -- sfix32_En24
    z0      : out   std_logic_vector(31 downto 0)  -- sfix32_En24
  );
end entity initial_rotation;

architecture rtl of initial_rotation is

  -- Signals
  signal y_init_signed      : signed(31 downto 0); -- sfix32_En24
  signal z_init_signed      : signed(31 downto 0); -- sfix32_En24
  signal switch_out1        : signed(31 downto 0); -- sfix32_En24
  signal switch_compare_1   : std_logic;
  signal gain1_cast         : signed(32 downto 0); -- sfix33_En24
  signal gain1_cast_1       : signed(32 downto 0); -- sfix33_En24
  signal gain1_cast_2       : signed(47 downto 0); -- sfix48_En36
  signal gain1_out1         : signed(31 downto 0); -- sfix32_En24
  signal switch1_out1       : signed(31 downto 0); -- sfix32_En24
  signal delay_out1         : signed(31 downto 0); -- sfix32_En24
  signal switch_compare_1_1 : std_logic;
  signal x_init_signed      : signed(31 downto 0); -- sfix32_En24
  signal gain2_cast         : signed(32 downto 0); -- sfix33_En24
  signal gain2_cast_1       : signed(32 downto 0); -- sfix33_En24
  signal gain2_cast_2       : signed(47 downto 0); -- sfix48_En36
  signal gain2_out1         : signed(31 downto 0); -- sfix32_En24
  signal switch2_out1       : signed(31 downto 0); -- sfix32_En24
  signal delay1_out1        : signed(31 downto 0); -- sfix32_En24
  signal switch_compare_1_2 : std_logic;
  signal constant1_out1     : signed(31 downto 0); -- sfix32_En24
  signal sum1_out1          : signed(31 downto 0); -- sfix32_En24
  signal constant_out1      : signed(31 downto 0); -- sfix32_En24
  signal sum_out1           : signed(31 downto 0); -- sfix32_En24
  signal switch3_out1       : signed(31 downto 0); -- sfix32_En24
  signal delay2_out1        : signed(31 downto 0); -- sfix32_En24

begin

  y_init_signed <= signed(y_init);

  z_init_signed <= signed(z_init);

  switch_out1 <= y_init_signed when inport = '0' else
                 z_init_signed;

  switch_compare_1 <= '1' when switch_out1 >= to_signed(0, 32) else
                      '0';

  gain1_cast   <= resize(y_init_signed, 33);
  gain1_cast_1 <= - (gain1_cast);
  gain1_cast_2 <= resize(gain1_cast_1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
  gain1_out1   <= gain1_cast_2(43 downto 12);

  switch1_out1 <= y_init_signed when switch_compare_1 = '0' else
                  gain1_out1;

  delay_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_out1 <= to_signed(0, 32);
      elsif (enb = '1') then
        delay_out1 <= switch1_out1;
      end if;
    end if;

  end process delay_process;

  x0 <= std_logic_vector(delay_out1);

  switch_compare_1_1 <= '1' when switch_out1 >= to_signed(0, 32) else
                        '0';

  x_init_signed <= signed(x_init);

  gain2_cast   <= resize(x_init_signed, 33);
  gain2_cast_1 <= - (gain2_cast);
  gain2_cast_2 <= resize(gain2_cast_1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
  gain2_out1   <= gain2_cast_2(43 downto 12);

  switch2_out1 <= gain2_out1 when switch_compare_1_1 = '0' else
                  x_init_signed;

  delay1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_out1 <= to_signed(0, 32);
      elsif (enb = '1') then
        delay1_out1 <= switch2_out1;
      end if;
    end if;

  end process delay1_process;

  y0 <= std_logic_vector(delay1_out1);

  switch_compare_1_2 <= '1' when switch_out1 >= to_signed(0, 32) else
                        '0';

  constant1_out1 <= to_signed(26353589, 32);

  sum1_out1 <= z_init_signed + constant1_out1;

  constant_out1 <= to_signed(26353589, 32);

  sum_out1 <= z_init_signed - constant_out1;

  switch3_out1 <= sum1_out1 when switch_compare_1_2 = '0' else
                  sum_out1;

  delay2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay2_out1 <= to_signed(0, 32);
      elsif (enb = '1') then
        delay2_out1 <= switch3_out1;
      end if;
    end if;

  end process delay2_process;

  z0 <= std_logic_vector(delay2_out1);

end architecture rtl;

