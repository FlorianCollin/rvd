library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity impul is
  port (
    clk : in std_logic;
    val_in : in std_logic;
    val_out : out std_logic
  );
end entity impul;

architecture behavioral of impul is

    signal s : std_logic := '0';

begin

  process (clk, val_in) is
  begin

    if rising_edge(clk) then
        if val_in = '1' and s = '0' then
            s <= '1';
            val_out <= '1';

        elsif val_in = '1' and s = '1' then
            val_out <= '0';

        elsif val_in = '0' and s = '1' then
            -- val_out <= '0';
            s <= '0';

        end if;
    end if;
    
  end process;

end architecture behavioral;
