library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.constants_pkg.all;

entity inst_register is
  port (
    clk          : in    std_logic;
    reset        : in    std_logic;
    ce           : in    std_logic;
    init_counter : in    std_logic;
    load_plus4   : in    std_logic;
    val_counter  : in    std_logic_vector((data_length - 1) downto 0);
    adr_inst     : out   std_logic_vector((data_length - 1) downto 0)
  );
end entity inst_register;

architecture behavioral of inst_register is

  signal s_addr : std_logic_vector((data_length - 1) downto 0);

begin

  process (clk, reset) is
  begin

    if (reset = '1') then
      adr_inst <= (others => '0');
    elsif rising_edge(clk) then
      if (init_counter = '1') then
        adr_inst <= (others => '0');
      elsif (ce = '1') then
        if (load_plus4 = '1') then
          adr_inst <= val_counter;
        end if;
      end if;
    end if;

  end process;

end architecture behavioral;
