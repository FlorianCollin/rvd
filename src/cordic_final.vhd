library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity cordic_final is
  port (
    operand2     : in    std_logic_vector(31 downto 0);
    sel_func_alu : in    std_logic_vector(3 downto 0);
    resultat     : out   std_logic_vector(31 downto 0);
    clk          : in    std_logic;
    reset_x      : in    std_logic;
    clk_enable   : in    std_logic
  );
end entity cordic_final;

architecture behavioral of cordic_final is

  component pre_cordic is
    port (
      sel_func_alu : in    std_logic_vector(3 downto 0);
      operand      : in    std_logic_vector(31 downto 0);
      inport       : out   std_logic;
      z0           : out   std_logic_vector(31 downto 0);
      root         : out   std_logic
    );
  end component;

  component top_level is
    port (
      clk        : in    std_logic;
      reset_x    : in    std_logic;
      clk_enable : in    std_logic;
      inport     : in    std_logic;
      rot        : in    std_logic;
      z_init1    : in    std_logic_vector(31 downto 0);
      xn         : out   std_logic_vector(31 downto 0);
      yn         : out   std_logic_vector(31 downto 0);
      zn         : out   std_logic_vector(31 downto 0)
    );
  end component;

  component select_resultat is
    port (
      xn           : in    std_logic_vector(31 downto 0);
      yn           : in    std_logic_vector(31 downto 0);
      zn           : in    std_logic_vector(31 downto 0);
      sel_func_alu : in    std_logic_vector(3 downto 0);
      resultat     : out   std_logic_vector(31 downto 0)
    );
  end component;

  signal s_import  : std_logic;
  signal s_rot     : std_logic;
  signal s_z_init1 : std_logic_vector(31 downto 0);
  signal s_xn      : std_logic_vector(31 downto 0);
  signal s_yn      : std_logic_vector(31 downto 0);
  signal s_zn      : std_logic_vector(31 downto 0);

begin

  inst_pre_cordic : component pre_cordic
    port map (
      sel_func_alu => sel_func_alu,
      operand      => operand2,
      inport       => s_import,
      z0           => s_z_init1,
      root         => s_rot
    );

  inst_top_level : component top_level
    port map (
      clk        => clk,
      reset_x    => reset_x,
      clk_enable => clk_enable,
      inport     => s_import,
      rot        => s_rot,
      z_init1    => s_z_init1,
      xn         => s_xn,
      yn         => s_yn,
      zn         => s_zn
    );

  inst_select_resultat : component select_resultat
    port map (
      xn           => s_xn,
      yn           => s_yn,
      zn           => s_zn,
      sel_func_alu => sel_func_alu,
      resultat     => resultat
    );

end architecture behavioral;
