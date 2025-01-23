library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity alu3 is
  port (
    sel_func_alu         : in    std_logic_vector(3 downto 0);
    sel_func_alu_connect : in    std_logic_vector(2 downto 0);
    operand1             : in    std_logic_vector((data_length - 1) downto 0);
    operand2             : in    std_logic_vector((data_length - 1) downto 0);
    result               : out   std_logic_vector((data_length - 1) downto 0);
    val_connect          : out   std_logic;
    alu_error_capture    : out   std_logic;
    r3                   : out   std_logic_vector((data_length*3 - 1) downto 0)
  );
end entity alu3;

architecture behavioral of alu3 is

component alu is
  port (
    sel_func_alu         : in    std_logic_vector(3 downto 0);
    sel_func_alu_connect : in    std_logic_vector(2 downto 0);
    operand1             : in    std_logic_vector((data_length - 1) downto 0);
    operand2             : in    std_logic_vector((data_length - 1) downto 0);
    result               : out   std_logic_vector((data_length - 1) downto 0);
    val_connect          : out   std_logic
  );
end component;

component selector is
  port (
    i0          : in    std_logic_vector((data_length - 1) downto 0);
    i1          : in    std_logic_vector((data_length - 1) downto 0);
    i2          : in    std_logic_vector((data_length - 1) downto 0);
    ce          : out    std_logic;
    r           : out   std_logic_vector((data_length - 1) downto 0)
  );
end component;

signal s_r0, s_r1, s_r2 : std_logic_vector((data_length - 1) downto 0);
signal val_c0, val_c2 : std_logic;
signal val_c1 : std_logic;

begin

process(val_c0, val_c1, val_c2) is
begin
  if ((val_c0 = val_c1) and (val_c1 = val_c2)) then
      val_connect <= val_c0;
  elsif (val_c0 /= val_c1) and (val_c1 = val_c2) then 
      val_connect <= val_c1;
      
  elsif (val_c0 = val_c1) and (val_c1 = not val_c2) then
      val_connect <= val_c0;
  else
      val_connect <= val_c0;
  end if;
end process;

alu0 : alu
port map (
  sel_func_alu          => sel_func_alu,
  sel_func_alu_connect  => sel_func_alu_connect,
  operand1              => operand1,
  operand2              => operand2,
  result                => s_r0,
  val_connect           => val_c0);

alu1 : alu
port map (
  sel_func_alu          => sel_func_alu,
  sel_func_alu_connect  => sel_func_alu_connect,
  operand1              => operand1,
  operand2              => operand2,
  result                => s_r1,
  val_connect           => val_c1);

alu2 : alu
port map (
  sel_func_alu          => sel_func_alu,
  sel_func_alu_connect  => sel_func_alu_connect,
  operand1              => operand1,
  operand2              => operand2,
  result                => s_r2,
  val_connect           => val_c2);
    
inst_selector: selector
port map (
  i0 => s_r0,
  i1=> s_r1,
  i2=> s_r2,
  ce => alu_error_capture,
  r => result);

  r3 <= s_r2 & s_r1 & s_r0;

end architecture behavioral;
