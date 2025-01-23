library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity imm_gen is
  port (
    imm_val     : in    std_logic_vector(24 downto 0);
    imm_type    : in    std_logic_vector(2 downto 0);
    imm_operand : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity imm_gen;

architecture behavioral of imm_gen is

  signal s_imm_operand : std_logic_vector((data_length - 1) downto 0);

begin

  process (imm_val, imm_type) is
  begin

    case imm_type is

      when "000" =>

        s_imm_operand <= (others => '0');                                                                                                                                                                                                                                                                                                                                        -- R_Type

      when "001" =>

        s_imm_operand <= imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24 downto 13);                                          -- I_Type check

      when "010" =>

        s_imm_operand <= imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24 downto 18) & imm_val(4 downto 0);                    -- S_Type

      when "011" =>

        s_imm_operand <= imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(0) & imm_val(23 downto 18) & imm_val(4 downto 1) & '0'; -- b_Type

      when "100" =>

        s_imm_operand <= imm_val(24 downto 5) & std_logic_vector(to_unsigned(0, 12));                                                                                                                                                                                                                                                                                            -- U_Type

      when "101" =>

        s_imm_operand <= imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(24) & imm_val(12 downto 5) & imm_val(13) & imm_val(23 downto 14) & '0';                                                                                                               -- j_Type

      when others =>

        s_imm_operand <= (others => '0');

    end case;

  end process;

  imm_operand <= std_logic_vector(s_imm_operand);

end architecture behavioral;
