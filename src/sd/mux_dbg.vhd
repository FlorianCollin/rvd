library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity mux_dbg is
  port (
    in1    : in    std_logic_vector((128 - 1) downto 0);
    in2    : in    std_logic_vector((128 - 1) downto 0);
    sel    : in    std_logic;
    o : out   std_logic_vector((128 - 1) downto 0)
  );
end entity mux_dbg;

architecture behavioral of mux_dbg is

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

