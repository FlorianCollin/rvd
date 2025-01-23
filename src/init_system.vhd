library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity init_system is
  port (
    clk        : in    std_logic;
    reset_x    : in    std_logic;
    clk_enable : in    std_logic;
    inport     : in    std_logic;
    ce_out     : out   std_logic;
    out1       : out   std_logic_vector(31 downto 0); -- sfix32_En24
    out2       : out   std_logic_vector(31 downto 0)  -- sfix32_En24
  );
--      out3                              :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En24
--    );
end entity init_system;

architecture rtl of init_system is

  -- Component Declarations
  component subsystem is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      out1    : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cos_cordic_nw is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      angle   : in    std_logic_vector(31 downto 0);
      cos     : out   std_logic_vector(31 downto 0)
    );
  end component;

  component sin_cordic_nw is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      angle   : in    std_logic_vector(31 downto 0);
      sin     : out   std_logic_vector(31 downto 0)
    );
  end component;

  -- -- Component Configuration Statements
  -- FOR ALL : subsystem
  --   USE ENTITY work.subsystem(rtl);

  -- FOR ALL : Cos_cordic_nw
  --   USE ENTITY work.cos_cordic_nw(rtl);

  -- FOR ALL : Sin_cordic_nw
  --   USE ENTITY work.sin_cordic_nw(rtl);

  -- Signals
  signal subsystem_out1     : std_logic_vector(31 downto 0); -- ufix32
  signal delay_out1         : std_logic_vector(31 downto 0); -- ufix32
  signal delay_out1_signed  : signed(31 downto 0);           -- sfix32_En30
  signal delay_out1_dtc     : signed(31 downto 0);           -- sfix32_En24
  signal x_init_out1        : signed(31 downto 0);           -- sfix32_En24
  signal switch_out1        : signed(31 downto 0);           -- sfix32_En24
  signal delay1_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal delay1_out1_signed : signed(31 downto 0);           -- sfix32_En30
  signal delay1_out1_dtc    : signed(31 downto 0);           -- sfix32_En24
  signal y_init_out1        : signed(31 downto 0);           -- sfix32_En24
  signal switch1_out1       : signed(31 downto 0);           -- sfix32_En24

begin

  u_subsystem : component subsystem
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      out1    => subsystem_out1
    );

  u_cos : component cos_cordic_nw
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      angle   => subsystem_out1,
      cos     => delay_out1
    );

  u_sin : component sin_cordic_nw
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      angle   => subsystem_out1,
      sin     => delay1_out1
    );

  delay_out1_signed <= signed(delay_out1);

  delay_out1_dtc <= resize(delay_out1_signed(31 downto 6), 32);

  x_init_out1 <= to_signed(10188117, 32);

  switch_out1 <= delay_out1_dtc when inport = '0' else
                 x_init_out1;

  out1 <= std_logic_vector(switch_out1);

  delay1_out1_signed <= signed(delay1_out1);

  delay1_out1_dtc <= resize(delay1_out1_signed(31 downto 6), 32);

  y_init_out1 <= to_signed(0, 32);

  switch1_out1 <= delay1_out1_dtc when inport = '0' else
                  y_init_out1;

  out2 <= std_logic_vector(switch1_out1);

  ce_out <= clk_enable;

--  out3 <= subsystem_out1;

end architecture rtl;

