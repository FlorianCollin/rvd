library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity data_to_processing is
  port (
    mem_read_depth : in    std_logic_vector(3 downto 0);
    val_in         : in    std_logic_vector((data_length - 1) downto 0);
    offset         : in    std_logic_vector(1 downto 0);
    val_out        : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity data_to_processing;

architecture behavioral of data_to_processing is

  constant octet_null                : std_logic_vector(7 downto 0) := "00000000";
  signal   octet_signed_offset_0     : std_logic_vector(7 downto 0);
  signal   octet_signed_offset_1     : std_logic_vector(7 downto 0);
  signal   octet_signed_offset_2     : std_logic_vector(7 downto 0);
  signal   octet_signed_offset_3     : std_logic_vector(7 downto 0);
  signal   half_word_signed_offset_0 : std_logic_vector(7 downto 0);
  signal   half_word_signed_offset_1 : std_logic_vector(7 downto 0);

begin

  octet_signed_offset_0     <= val_in(7) & val_in(7) & val_in(7) & val_in(7) & val_in(7) & val_in(7) & val_in(7) & val_in(7);
  octet_signed_offset_1     <= val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15);
  octet_signed_offset_2     <= val_in(23) & val_in(23) & val_in(23) & val_in(23) & val_in(23) & val_in(23) & val_in(23) & val_in(23);
  octet_signed_offset_3     <= val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31);
  half_word_signed_offset_0 <= val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15) & val_in(15);
  half_word_signed_offset_1 <= val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31) & val_in(31);

  read_data : process (mem_read_depth, val_in, octet_signed_offset_0, octet_signed_offset_1, octet_signed_offset_2, octet_signed_offset_3, half_word_signed_offset_0, half_word_signed_offset_1, offset) is
  begin

    case (mem_read_depth) is

      when "0001" =>

        case offset is

          when "01" =>

            val_out <= octet_signed_offset_1 & octet_signed_offset_1 & octet_signed_offset_1 & val_in(15 downto 8);  -- lb Offset 1

          when "10" =>

            val_out <= octet_signed_offset_2 & octet_signed_offset_2 & octet_signed_offset_2 & val_in(23 downto 16); -- lb Offset 2

          when "11" =>

            val_out <= octet_signed_offset_3 & octet_signed_offset_3 & octet_signed_offset_3 & val_in(31 downto 24); -- lb Offset 3

          when others =>

            val_out <= octet_signed_offset_0 & octet_signed_offset_0 & octet_signed_offset_0 & val_in(7 downto 0);   -- lb Offset 0

        end case;

      when "0011" =>

        case offset(1) is

          when '1' =>

            val_out <= half_word_signed_offset_1 & half_word_signed_offset_1 & val_in(31 downto 16);                 -- lh Offset 1

          when others =>

            val_out <= half_word_signed_offset_0 & half_word_signed_offset_0 & val_in(15 downto 0);                  -- lh Offset 0

        end case;

      when "0111" =>

        val_out <= val_in;                                                                                           -- lw

      when "1001" =>

        case offset is

          when "01" =>

            val_out <= octet_null & octet_null & octet_null & val_in(15 downto 8);                                   -- lbu Offset 1

          when "10" =>

            val_out <= octet_null & octet_null & octet_null & val_in(23 downto 16);                                  -- lbu Offset 2

          when "11" =>

            val_out <= octet_null & octet_null & octet_null & val_in(31 downto 24);                                  -- lbu Offset 3

          when others =>

            val_out <= octet_null & octet_null & octet_null & val_in(7 downto 0);                                    -- lbu Offset 0

        end case;

      when "1011" =>

        case offset(1) is

          when '1' =>

            val_out <= octet_null & octet_null & val_in(31 downto 16);                                               -- lhu Offset 1

          when others =>

            val_out <= octet_null & octet_null & val_in(15 downto 0);                                                -- lhu Offset 0

        end case;

      when others =>

        val_out <= octet_null & octet_null & octet_null & octet_null;

    end case;

  end process read_data;

end architecture behavioral;
