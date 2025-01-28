----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2024 10:22:30
-- Design Name: 
-- Module Name: hamming_enc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hamming_enc is
    Port (  data_in : in STD_LOGIC_VECTOR(31 downto 0);
            data_out : out STD_LOGIC_VECTOR(37 downto 0));
end hamming_enc;

architecture Behavioral of hamming_enc is
signal parity : std_logic_vector(5 downto 0);       
begin

codageHamming : process(data_in)
variable temp : std_logic;
begin
    parity(0) <= data_in(31) xor data_in(30) xor data_in(28) xor data_in(27) xor  data_in(25) xor data_in(23) xor data_in(21) xor data_in(20) xor data_in(18) xor data_in(16) xor data_in(14) xor data_in(12) xor data_in(10) xor data_in(8) xor data_in(6) xor data_in(5) xor data_in(3) xor data_in(1);
    parity(1) <= data_in(31) xor data_in(29) xor data_in(28) xor data_in(26) xor data_in(25) xor data_in(22) xor data_in(21) xor data_in(19) xor data_in(18) xor data_in(15) xor data_in(14) xor data_in(11) xor data_in(10) xor data_in(7) xor data_in(6) xor data_in(4) xor data_in(3) xor data_in(0);
    parity(2) <= data_in(30) xor data_in(29) xor data_in(28) xor data_in(24) xor data_in(23) xor data_in(22) xor data_in(21) xor data_in(17) xor data_in(16) xor data_in(15) xor data_in(14) xor data_in(9) xor data_in(8) xor data_in(7) xor data_in(6) xor data_in(2) xor data_in(1) xor data_in(0);
    parity(3) <= data_in(27) xor data_in(26) xor data_in(25) xor data_in(24) xor data_in(23) xor data_in(22) xor data_in(21) xor data_in(13) xor data_in(12) xor data_in(11) xor data_in(10) xor data_in(9) xor data_in(8) xor data_in(7) xor data_in(6);
    parity(4) <= data_in(20) xor data_in(19) xor data_in(18) xor data_in(17) xor data_in(16) xor data_in(15) xor data_in(14) xor data_in(13) xor data_in(12) xor data_in(11) xor data_in(10) xor data_in(9) xor data_in(8) xor data_in(7) xor data_in(6);
    parity(5) <= data_in(5) xor data_in(4) xor data_in(3) xor data_in(2) xor data_in(1) xor data_in(0);
end process codageHamming;
data_out <= data_in & parity;
end Behavioral;