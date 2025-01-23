library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity my_cordic_rotati is
  port (
    clk        : in    std_logic;
    reset_x    : in    std_logic;
    clk_enable : in    std_logic;
    x_init1    : in    std_logic_vector(31 downto 0); -- sfix32_En24
    y_init1    : in    std_logic_vector(31 downto 0); -- sfix32_En24
    z_init1    : in    std_logic_vector(31 downto 0); -- sfix32_En24
    rot        : in    std_logic;
    ce_out     : out   std_logic;
    xn         : out   std_logic_vector(31 downto 0); -- sfix32_En24
    yn         : out   std_logic_vector(31 downto 0); -- sfix32_En24
    zn         : out   std_logic_vector(31 downto 0)  -- sfix32_En24
  );
end entity my_cordic_rotati;

architecture rtl of my_cordic_rotati is

  -- Component Declarations
  component initial_rotation is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x_init  : in    std_logic_vector(31 downto 0);
      y_init  : in    std_logic_vector(31 downto 0);
      z_init  : in    std_logic_vector(31 downto 0);
      inport  : in    std_logic;
      x0      : out   std_logic_vector(31 downto 0);
      y0      : out   std_logic_vector(31 downto 0);
      z0      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_0 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x0      : in    std_logic_vector(31 downto 0);
      y0      : in    std_logic_vector(31 downto 0);
      z0      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x1      : out   std_logic_vector(31 downto 0);
      y1      : out   std_logic_vector(31 downto 0);
      z1      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_1 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x1      : in    std_logic_vector(31 downto 0);
      y1      : in    std_logic_vector(31 downto 0);
      z1      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x2      : out   std_logic_vector(31 downto 0);
      y2      : out   std_logic_vector(31 downto 0);
      z2      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_2 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x2      : in    std_logic_vector(31 downto 0);
      y2      : in    std_logic_vector(31 downto 0);
      z2      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x3      : out   std_logic_vector(31 downto 0);
      y3      : out   std_logic_vector(31 downto 0);
      z3      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_3 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x3      : in    std_logic_vector(31 downto 0);
      y3      : in    std_logic_vector(31 downto 0);
      z3      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x4      : out   std_logic_vector(31 downto 0);
      y4      : out   std_logic_vector(31 downto 0);
      z4      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_4 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x4      : in    std_logic_vector(31 downto 0);
      y4      : in    std_logic_vector(31 downto 0);
      z4      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x5      : out   std_logic_vector(31 downto 0);
      y5      : out   std_logic_vector(31 downto 0);
      z5      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_5 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x5      : in    std_logic_vector(31 downto 0);
      y5      : in    std_logic_vector(31 downto 0);
      z5      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x6      : out   std_logic_vector(31 downto 0);
      y6      : out   std_logic_vector(31 downto 0);
      z6      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_6 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x6      : in    std_logic_vector(31 downto 0);
      y6      : in    std_logic_vector(31 downto 0);
      z6      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x7      : out   std_logic_vector(31 downto 0);
      y7      : out   std_logic_vector(31 downto 0);
      z7      : out   std_logic_vector(31 downto 0)
    );
  end component;

  component cordic_stage_7 is
    port (
      clk     : in    std_logic;
      reset_x : in    std_logic;
      enb     : in    std_logic;
      x7      : in    std_logic_vector(31 downto 0);
      y7      : in    std_logic_vector(31 downto 0);
      z7      : in    std_logic_vector(31 downto 0);
      rot     : in    std_logic;
      x8      : out   std_logic_vector(31 downto 0);
      y8      : out   std_logic_vector(31 downto 0);
      z8      : out   std_logic_vector(31 downto 0)
    );
  end component;

  -- Component Configuration Statements
  FOR ALL : initial_rotation
    USE ENTITY work.initial_rotation(rtl);

  FOR ALL : cordic_stage_0
    USE ENTITY work.cordic_stage_0(rtl);

  FOR ALL : cordic_stage_1
    USE ENTITY work.cordic_stage_1(rtl);

  FOR ALL : cordic_stage_2
    USE ENTITY work.cordic_stage_2(rtl);

  FOR ALL : cordic_stage_3
    USE ENTITY work.cordic_stage_3(rtl);

  FOR ALL : cordic_stage_4
    USE ENTITY work.cordic_stage_4(rtl);

  FOR ALL : cordic_stage_5
    USE ENTITY work.cordic_stage_5(rtl);

  FOR ALL : cordic_stage_6
    USE ENTITY work.cordic_stage_6(rtl);

  FOR ALL : cordic_stage_7
    USE ENTITY work.cordic_stage_7(rtl);

  -- Signals
  signal initial_rotation_out1      : std_logic_vector(31 downto 0); -- ufix32
  signal initial_rotation_out2      : std_logic_vector(31 downto 0); -- ufix32
  signal initial_rotation_out3      : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_0_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_0_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_0_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_1_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_1_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_1_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_2_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_2_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_2_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_3_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_3_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_3_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_4_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_4_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_4_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_5_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_5_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_5_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_6_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_6_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_6_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_7_out1        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_7_out2        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_7_out3        : std_logic_vector(31 downto 0); -- ufix32
  signal cordic_stage_7_out1_signed : signed(31 downto 0);           -- sfix32_En24
  signal gain_mul_temp              : signed(63 downto 0);           -- sfix64_En48
  signal gain_out1                  : signed(31 downto 0);           -- sfix32_En24
  signal switch4_out1               : signed(31 downto 0);           -- sfix32_En24

begin

  u_initial_rotation : component initial_rotation
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x_init  => x_init1,
      y_init  => y_init1,
      z_init  => z_init1,
      inport  => rot,
      x0      => initial_rotation_out1,
      y0      => initial_rotation_out2,
      z0      => initial_rotation_out3
    );

  u_cordic_stage_0 : component cordic_stage_0
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x0      => initial_rotation_out1,
      y0      => initial_rotation_out2,
      z0      => initial_rotation_out3,
      rot     => rot,
      x1      => cordic_stage_0_out1,
      y1      => cordic_stage_0_out2,
      z1      => cordic_stage_0_out3
    );

  u_cordic_stage_1 : component cordic_stage_1
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x1      => cordic_stage_0_out1,
      y1      => cordic_stage_0_out2,
      z1      => cordic_stage_0_out3,
      rot     => rot,
      x2      => cordic_stage_1_out1,
      y2      => cordic_stage_1_out2,
      z2      => cordic_stage_1_out3
    );

  u_cordic_stage_2 : component cordic_stage_2
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x2      => cordic_stage_1_out1,
      y2      => cordic_stage_1_out2,
      z2      => cordic_stage_1_out3,
      rot     => rot,
      x3      => cordic_stage_2_out1,
      y3      => cordic_stage_2_out2,
      z3      => cordic_stage_2_out3
    );

  u_cordic_stage_3 : component cordic_stage_3
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x3      => cordic_stage_2_out1,
      y3      => cordic_stage_2_out2,
      z3      => cordic_stage_2_out3,
      rot     => rot,
      x4      => cordic_stage_3_out1,
      y4      => cordic_stage_3_out2,
      z4      => cordic_stage_3_out3
    );

  u_cordic_stage_4 : component cordic_stage_4
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x4      => cordic_stage_3_out1,
      y4      => cordic_stage_3_out2,
      z4      => cordic_stage_3_out3,
      rot     => rot,
      x5      => cordic_stage_4_out1,
      y5      => cordic_stage_4_out2,
      z5      => cordic_stage_4_out3
    );

  u_cordic_stage_5 : component cordic_stage_5
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x5      => cordic_stage_4_out1,
      y5      => cordic_stage_4_out2,
      z5      => cordic_stage_4_out3,
      rot     => rot,
      x6      => cordic_stage_5_out1,
      y6      => cordic_stage_5_out2,
      z6      => cordic_stage_5_out3
    );

  u_cordic_stage_6 : component cordic_stage_6
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x6      => cordic_stage_5_out1,
      y6      => cordic_stage_5_out2,
      z6      => cordic_stage_5_out3,
      rot     => rot,
      x7      => cordic_stage_6_out1,
      y7      => cordic_stage_6_out2,
      z7      => cordic_stage_6_out3
    );

  u_cordic_stage_7 : component cordic_stage_7
    port map (
      clk     => clk,
      reset_x => reset_x,
      enb     => clk_enable,
      x7      => cordic_stage_6_out1,
      y7      => cordic_stage_6_out2,
      z7      => cordic_stage_6_out3,
      rot     => rot,
      x8      => cordic_stage_7_out1,
      y8      => cordic_stage_7_out2,
      z8      => cordic_stage_7_out3
    );

  cordic_stage_7_out1_signed <= signed(cordic_stage_7_out1);

  gain_mul_temp <= to_signed(-10188117, 32) * cordic_stage_7_out1_signed;
  gain_out1     <= gain_mul_temp(55 downto 24);

  switch4_out1 <= gain_out1 when rot = '0' else
                  cordic_stage_7_out1_signed;

  xn <= std_logic_vector(switch4_out1);

  ce_out <= clk_enable;

  yn <= cordic_stage_7_out2;

  zn <= cordic_stage_7_out3;

end architecture rtl;

