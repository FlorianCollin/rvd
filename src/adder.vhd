library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity adder is
  port (
    operand_1 : in    std_logic_vector((data_length - 1) downto 0);
    operand_2 : in    std_logic_vector((data_length - 1) downto 0);
    result    : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity adder;

architecture behavioral of adder is

begin

  result <= std_logic_vector(signed(operand_1) + signed(operand_2));

end architecture behavioral;
