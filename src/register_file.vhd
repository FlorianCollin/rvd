library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity register_file is
  port (
    clk            : in    std_logic;
    reset          : in    std_logic;
    ce             : in    std_logic;
    init_reg       : in    std_logic;
    reg_file_write : in    std_logic;
    read_adr1      : in    std_logic_vector((5 - 1) downto 0);
    read_adr2      : in    std_logic_vector((5 - 1) downto 0);
    write_adr      : in    std_logic_vector((5 - 1) downto 0);
    data_write     : in    std_logic_vector((data_length - 1) downto 0);
    data_read1     : out   std_logic_vector((data_length - 1) downto 0);
    data_read2     : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity register_file;

architecture behavioral of register_file is

  constant bit_adr : integer := 5;

  type registerfile is array(0 to 31) of std_logic_vector(31 downto 0);

  signal registers : registerfile;

begin

  data_read1 <= registers(to_integer(unsigned(read_adr1)));
  data_read2 <= registers(to_integer(unsigned(read_adr2)));

  regfile : process (clk, reset) is
  begin

    if (reset = '1') then

      for i in 0 to 31 loop

        registers(i) <= (others => '0');

      end loop;

    elsif rising_edge(clk) then
      if (init_reg = '1') then

        for i in 0 to 31 loop

          registers(i) <= (others => '0');

        end loop;

      elsif (ce = '1') then
        if (reg_file_write = '1') then
          if (to_integer(unsigned(write_adr)) = 0) then                    -- C. JEGO 05/12/2023
            registers(to_integer(unsigned(write_adr))) <= (others => '0'); -- il ne faut pas écrire dans le registre x0
          else
            registers(to_integer(unsigned(write_adr))) <= data_write;
          end if;
        end if;
      end if;
    end if;

  end process regfile;

end architecture behavioral;
