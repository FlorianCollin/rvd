----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2024 10:23:11
-- Design Name: 
-- Module Name: tb_hamming_dec - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_hamming_dec is
end tb_hamming_dec;

architecture Behavioral of tb_hamming_dec is
component hamming_dec is
    Port (  data_in : in std_logic_vector(37 downto 0);
            data_out : out std_logic_vector(31 downto 0);
            syndrome : out std_logic_vector(5 downto 0));
end component hamming_dec;

signal s_data_in : std_logic_vector(37 downto 0) := "00000000000000000000000000001011100000";
signal s_data_out : std_logic_vector(31 downto 0);
signal s_syndrome : std_logic_vector(5 downto 0);
begin
dec : hamming_dec
port map(   data_in => s_data_in,
            data_out => s_data_out,
            syndrome => s_syndrome);
            
switch_bit : process
begin
    wait for 5ns;
    s_data_in(0) <= not s_data_in(0);
    wait for 5ns;
    for i in 1 to 37 loop
        s_data_in(i-1) <= not s_data_in(i-1);
        s_data_in(i) <= not s_data_in(i);
        wait for 5ns;
    end loop;
    s_data_in(37) <= not s_data_in(37);
    wait;
end process switch_bit;
end Behavioral;