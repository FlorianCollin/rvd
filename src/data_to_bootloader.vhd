library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity data_to_bootloader is
  port (
    boot     : in    std_logic;
    rw_boot  : in    std_logic;
    adr_boot : in    std_logic_vector(1 downto 0);
    val_in   : in    std_logic_vector((data_length - 1) downto 0);
    val_out  : out   std_logic_vector((8 - 1) downto 0)
  );
end entity data_to_bootloader;

architecture behavioral of data_to_bootloader is

  constant octet_null : std_logic_vector(7 downto 0) := "00000000";

begin

  read_ins : process (adr_boot, rw_boot, boot, val_in) is
  begin

    if (boot='1') then
      if (rw_boot ='0') then

        case (adr_boot) is

          when "11" =>

            val_out <= val_in(31 downto 24);

          when "10" =>

            val_out <= val_in(23 downto 16);

          when "01" =>

            val_out <= val_in(15 downto 8);

          when others =>

            val_out <= val_in(7 downto 0);

        end case;

      else
        val_out <= octet_null;
      end if;
    else
      val_out <= octet_null;
    end if;

  end process read_ins;

end architecture behavioral;
