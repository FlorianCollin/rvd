library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity selector is
  port (
    i0          : in    std_logic_vector((data_length - 1) downto 0);
    i1          : in    std_logic_vector((data_length - 1) downto 0);
    i2          : in    std_logic_vector((data_length - 1) downto 0);
    ce          : out    std_logic;
    r           : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity selector;

architecture behavioral of selector is

begin

error_det : process(i0, i1, i2) is
begin
    if ((i0 = i1) and (i1 = i2)) then
        r <= i0;
        ce <= '0';
    elsif (i0 /= i1) and (i1 = i2) then
        r <= i1;
        ce <= '1';
    elsif ((i0 = i1) and (i1 /= i2)) then
        r <= i0;
        ce <= '1';
    else
        r <= i0;
        ce <= '1';
    end if;
end process;

end architecture behavioral;
