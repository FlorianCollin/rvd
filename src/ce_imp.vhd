library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity mux2_1 is
  port (
    clk, ce, reset : in std_logic;
    debug : in std_logic;
    sig_enable : out std_logic
  );
end entity mux2_1;

architecture behavioral of mux2_1 is
    signal mem             : std_logic;
    signal debug_enable    : std_logic;
    signal s_select_result : std_logic;
begin

    process (reset, clk) is
        begin
      
          if (reset='1') then
            mem          <= '0';
            debug_enable <= '0';
          elsif (clk='1' and clk'event) then
            mem          <= ce;
            debug_enable <= (mem xor ce) and ce;
          end if;
      
        end process;
      
        process (debug, ce, debug_enable) is
        begin
      
          if (debug='1') then
            sig_enable <= debug_enable;
          else                          -- Mouad Rabiai
            sig_enable <= ce;           -- Mouad Rabiai
          end if;
      
        end process;

end architecture behavioral;

