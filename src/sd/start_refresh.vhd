library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity start_refresh is
  port (
   clk : in std_logic;
   start_refresh_sig : out std_logic
  );
end entity start_refresh;

architecture behavioral of start_refresh is

    signal flag : std_logic := '0';

begin

  process (clk) is
  begin

    if (rising_edge(clk)) then
        if flag = '0' then
            flag <= '1';
            start_refresh_sig <= '1';
        else
            start_refresh_sig <= '0';
        end if;
    end if;

  end process;

end architecture behavioral;

