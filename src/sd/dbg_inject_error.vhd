library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity dbg_inject_error is
  port (
    error_message : out std_logic_vector(127 downto 0)
   
  );
end entity dbg_inject_error;

architecture behavioral of dbg_inject_error is

begin
  
  error_message <= x"0f0e0d0c0b0a09080706050403020100";

end architecture behavioral;

