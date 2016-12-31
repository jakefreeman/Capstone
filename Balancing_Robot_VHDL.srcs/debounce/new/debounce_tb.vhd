----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 12/29/2016 05:26:47 PM
-- Design Name: debounce_tb
-- Module Name: debounce_tb - Behavioral
-- Project Name: 
-- Target Devices: Any
-- Tool Versions: 
-- Description: Testbench for debounce module
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

entity debounce_tb is
end;

architecture Behavioral of debounce_tb is

component debounce is
		Generic(
			counter_size : INTEGER --length of counter 100MHz clock counts to 1 million (x"F240") cycles for 10 ms
			);
    Port( 
			clk					: in STD_LOGIC; --clock
			button_in 	: in STD_LOGIC; --physical button input
      button_out 	: out STD_LOGIC --debounced button output
		);
end component;

-- Signal Declarations
signal clock : STD_LOGIC := '1';
signal btn_in: STD_LOGIC := '0';
signal btn_out: STD_LOGIC :='0';
constant size : integer := 20;

begin

-- instantiation
Debouce_UT: debounce 
	generic map(
		counter_size => size
	)
	port map(
		clk 				=> clock,
		button_in		=> btn_in,
		button_out	=> btn_out
	);
	
-- Generate Clock
process begin
	clock <= not clock;
	wait for 5 ns; -- 10ns clock period for 100MHz clock
end process;

-- Generate Test Data

process begin
	wait for 10 ns;
	btn_in <= '1';
	wait for 13 ns;
	btn_in <= '0';
	wait for 34 ns;
	btn_in <= '1';
	wait for 6 ns;
	btn_in <= '0';
	wait for 55 ns;
	btn_in <= '1';
	wait for 50 ns;
	btn_in <= '0';
	wait for 50 ns;
	btn_in <= '1';
	wait for 10 ms;
	btn_in <= '0';
	wait for 34 ns;
	btn_in <= '1';
	wait for 6 ns;
	btn_in <= '0';
	wait for 55 ns;
	btn_in <= '1';
	wait for 50 ns;
	btn_in <= '0';
	wait;
end process;

end;