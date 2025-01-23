library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity mux2_1 is
  port (
    in1    : in    std_logic_vector((data_length - 1) downto 0);
    in2    : in    std_logic_vector((data_length - 1) downto 0);
    sel    : in    std_logic;
    o : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity mux2_1;

architecture behavioral of mux2_1 is

begin

  process (sel, in2, in1) is
  begin

    if (sel='1') then
      o <= in2;
    else
      o <= in1;
    end if;

  end process;

end architecture behavioral;

