----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2016 05:46:43 PM
-- Design Name: 
-- Module Name: clock_div - Behavioral
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

entity clock_div is
	generic (
	divisor : integer := 50; --number to divide clock by 
	cnt_length : integer := 6 --length of counter to allow for counting to divisor
	);
  port ( 
		clk : in STD_LOGIC; -- Clock unput
    rst : in STD_LOGIC; --Synchronous reset
    div_clk : out STD_LOGIC); -- Divided Clock output
end clock_div;

architecture Behavioral of clock_div is

signal count : unsigned(cnt_length-1 downto 0) := (others => '0');
signal i_div_clk : STD_LOGIC := '0';


begin

	process (clk) begin
		if rising_edge(clk) then
			if (rst='1') then
				count <= (others => '0');
				i_div_clk <= '0';
			elsif (count = divisor) then
				count <= (others => '0');
				i_div_clk <= not i_div_clk;
			else
				count <= count + 1;
				i_div_clk <= i_div_clk;
			end if;
		end if;
	end process;

div_clk <= i_div_clk;		

end Behavioral;
