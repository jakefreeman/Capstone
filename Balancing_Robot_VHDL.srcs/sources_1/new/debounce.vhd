----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 12/29/2016 05:26:47 PM
-- Design Name: debounce
-- Module Name: debounce - Behavioral
-- Project Name: 
-- Target Devices: Any
-- Tool Versions: 
-- Description: Debounces buttons. Generic sets counter top, setting length of time button must be pressed to count as engaged.
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
--use IEEE.NUMERIC_STD.ALL;

entity debounce is
		Generic(
			counter_size : INTEGER := 20; --length of counter 100MHz clock counts to 1 million (x"F240") cycles for 10 ms
			);
    Port( 
			clk					: in STD_LOGIC; --clock
			button_in 	: in STD_LOGIC; --physical button input
      button_out 	: out STD_LOGIC --debounced button output
		);
end debounce;

architecture Behavioral of debounce is

---- signal declarations ----
signal ff0 					: STD_LOGIC;
signal ff1 					: STD_LOGIC;
signal count_reset	: STD_LOGIC;
signal count 				: UNSIGNED(counter_size);

begin

count_reset <= ff0 xor ff1;

process(clk) begin
	if rising_edge(clk) then
		ff0 <= button_in;
		ff1 <= ff0;
		if (count_reset = '1') then
			count <= (others => '0');
		elsif (count(counter_size) = '0');
			count <= count + 1;
		else
			button_out <= ff1;
		end if;
	end if;
end process;	

end Behavioral;
