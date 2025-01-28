----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.11.2024 10:11:03
-- Design Name: 
-- Module Name: hamming_dec - Behavioral
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

entity hamming_dec is
    Port (  data_in : in std_logic_vector(37 downto 0);
            data_out : out std_logic_vector(31 downto 0);
            syndrome : out std_logic_vector(5 downto 0));
end hamming_dec;

architecture Behavioral of hamming_dec is

component hamming_enc is
    Port (  data_in : in STD_LOGIC_VECTOR(31 downto 0);
            data_out : out STD_LOGIC_VECTOR(37 downto 0));
end component hamming_enc;

signal s_data : std_logic_vector(31 downto 0) := (others => '0');
signal s_parity : std_logic_vector(5 downto 0) := (others => '0');
signal s_enc : std_logic_vector(37 downto 0);


begin

separation : process(data_in)
begin
    s_parity <= data_in(5 downto 0);
    s_data <= data_in(37 downto 6);
end process separation;

enc : hamming_enc
port map(   data_in => s_data,
            data_out => s_enc);

syndrome <= s_parity xor s_enc(5 downto 0);
data_out <= s_data;
end Behavioral;
