library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity mux2 is
  generic (
    size : integer := 8
  );
  port (
    in1 : in    std_logic_vector(size - 1 downto 0);
    in2 : in    std_logic_vector(size - 1 downto 0);
    sel : in    std_logic;
    o   : out   std_logic_vector(size - 1 downto 0)
  );
end entity mux2;

architecture behavioral of mux2 is

begin

  process (sel, in2, in1) is
  begin

    if (sel = '1') then
      o <= in2;
    else
      o <= in1;
    end if;

  end process;

end architecture behavioral;
