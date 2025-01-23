library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity pc_plus_4 is
  port (
    val_inst     : in    std_logic_vector((data_length - 1) downto 0);
    new_val_inst : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity pc_plus_4;

architecture behavioral of pc_plus_4 is

begin

  process (val_inst) is
  begin

    new_val_inst <= std_logic_vector(unsigned(val_inst) + to_unsigned(4, data_length));

  end process;

end architecture behavioral;
