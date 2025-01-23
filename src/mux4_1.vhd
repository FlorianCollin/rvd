library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity mux4_1 is
  port (
    in1    : in    std_logic_vector((data_length - 1) downto 0);
    in2    : in    std_logic_vector((data_length - 1) downto 0);
    in3    : in    std_logic_vector((data_length - 1) downto 0);
    in4    : in    std_logic_vector((data_length - 1) downto 0);
    sel    : in    std_logic_vector(1 downto 0);
    o : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity mux4_1;

architecture behavioral of mux4_1 is

begin

  process (sel, in4, in3, in2, in1) is
  begin

    case sel is

      when "00" =>

        o <= in1;

      when "01" =>

        o <= in2;

      when "10" =>

        o <= in3;

      when others =>

        o <= in4;

    end case;

  end process;

end architecture behavioral;

