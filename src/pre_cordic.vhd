library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity pre_cordic is
  port (
    sel_func_alu : in    std_logic_vector(3 downto 0);
    operand      : in    std_logic_vector(31 downto 0);
    inport       : out   std_logic;
    z0           : out   std_logic_vector(31 downto 0);
    root         : out   std_logic
  );
end entity pre_cordic;

architecture behavioral of pre_cordic is

begin

  process (sel_func_alu) is
  begin

    case sel_func_alu is

      when "0001" =>                                  -- corcos

        inport <= '1';
        root   <= '1';
        z0     <= operand;

      when "0010" =>                                  -- corsin

        inport <= '1';
        root   <= '1';
        z0     <= operand;

      when "0011" =>                                  -- cortan

        inport <= '1';
        root   <= '1';
        z0     <= operand;

      when "0110" =>                                  -- arctan

        inport <= '0';
        root   <= '0';
        z0     <= std_logic_vector(TO_SIGNED(0, 32));

      when "0111" =>                                  -- module

        inport <= '0';
        root   <= '0';
        z0     <= std_logic_vector(TO_SIGNED(0, 32));

      when others =>

        inport <= '0';
        root   <= '0';
        z0     <= std_logic_vector(TO_SIGNED(0, 32));

    end case;

  end process;

end architecture behavioral;
