library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity select_resultat is
  port (
    xn           : in    std_logic_vector(31 downto 0);
    yn           : in    std_logic_vector(31 downto 0);
    zn           : in    std_logic_vector(31 downto 0);
    sel_func_alu : in    std_logic_vector(3 downto 0);
    resultat     : out   std_logic_vector(31 downto 0)
  );
end entity select_resultat;

architecture behavioral of select_resultat is

begin

  process (sel_func_alu) is
  begin

    case sel_func_alu is

      when("0001") =>                                   -- corcos

        resultat <= xn;

      when("0010") =>                                   -- corsin

        resultat <= yn;

      when("0011") =>                                   -- cortan

        resultat <= xn;

      when("0110") =>                                   -- arctan

        resultat <= zn;

      when("0111") =>                                   -- module

        resultat <= xn;

      when others =>

        resultat <= std_logic_vector(to_signed(0, 32));

    end case;

  end process;

end architecture behavioral;
