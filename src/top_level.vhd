library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity top_level is
  port (
    clk        : in    std_logic;
    reset_x    : in    std_logic;
    clk_enable : in    std_logic;
    inport     : in    std_logic;
    rot        : in    std_logic;
    z_init1 : in    std_logic_vector(31 downto 0);
    xn      : out   std_logic_vector(31 downto 0);
    yn      : out   std_logic_vector(31 downto 0);
    zn      : out   std_logic_vector(31 downto 0)
  );
end entity top_level;

architecture behavioral of top_level is

  signal s_ce_out  : std_logic;
  signal s_x_init1 : std_logic_vector(31 downto 0);
  signal s_y_init1 : std_logic_vector(31 downto 0);
  signal s_z_init1 : std_logic_vector(31 downto 0);

  component my_cordic_rotati is
    port (
      clk        : in    std_logic;
      reset_x    : in    std_logic;
      clk_enable : in    std_logic;
      x_init1    : in    std_logic_vector(31 downto 0);
      y_init1    : in    std_logic_vector(31 downto 0);
      z_init1    : in    std_logic_vector(31 downto 0);
      rot        : in    std_logic;
      ce_out     : out   std_logic;
      xn         : out   std_logic_vector(31 downto 0);
      yn         : out   std_logic_vector(31 downto 0);
      zn         : out   std_logic_vector(31 downto 0)
    );
  end component;

  component init_system is
    port (
      clk        : in    std_logic;
      reset_x    : in    std_logic;
      clk_enable : in    std_logic;
      inport     : in    std_logic;
      ce_out     : out   std_logic;
      out1       : out   std_logic_vector(31 downto 0);
      out2       : out   std_logic_vector(31 downto 0)
    );
  end component;

begin

  init : component init_system
    port map (
      clk        => clk,
      reset_x    => reset_x,
      clk_enable => clk_enable,
      inport     => inport,
      out1       => s_x_init1,
      out2       => s_y_init1,
      --      out3 => s_z_init1,
      ce_out => s_ce_out
    );

  cordic : component my_cordic_rotati
    port map (
      clk        => clk,
      reset_x    => reset_x,
      clk_enable => clk_enable,
      rot        => rot,
      x_init1    => s_x_init1,
      y_init1    => s_y_init1,
      z_init1    => z_init1,
      xn         => xn,
      yn         => yn,
      zn         => zn,
      ce_out     => s_ce_out
    );

end architecture behavioral;
