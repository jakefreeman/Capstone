----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 01/01/2017 05:16:58 PM
-- Design Name: 
-- Module Name: display_debounce - simulation
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for display_debounce top module
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_debounce_tb is
end;

architecture simulation of display_debounce_tb is

-- component declaration
component display_debounce_top is
	Port(
		clk 	: in STD_LOGIC;
		btnU 	: in STD_LOGIC;
		btnD 	: in STD_LOGIC;
		CPU_RESET		: in STD_LOGIC;
		an 		: out STD_LOGIC_VECTOR (7 downto 0);
		seg 	: out STD_LOGIC_VECTOR (6 downto 0)
	);
end component;

-- Signal Declarations
signal clock 	: STD_LOGIC := '0';
signal but_up : STD_LOGIC := '0';
signal but_dn	: STD_LOGIC := '0';
signal anode 	: STD_LOGIC_VECTOR(7 downto 0);
signal segment: STD_LOGIC_VECTOR(6 downto 0);
signal reset	: STD_LOGIC := '0';

begin

-- component instantiation
D_D_top_1: display_debounce_top port map(
		clk 	=> clock, 	
		btnU 	=> but_up, 
	  btnD 	=> but_dn,
		CPU_RESET 	=> reset,
	  an 		=> anode, 	
		seg 	=> segment
		);
		
process begin
	clock <= not clock;
	wait for 5 ns;
end process;
	
process begin
	reset <= '1';
	wait for 10 ns;
	reset <= '0'; 
	wait for 20 ns;
  but_up <= '1';
	wait for 10 ns;
	but_up <= '0';
	wait for 10 ns;
	but_up <= '1';
	wait for 11 ms;
	but_up <= '0';
	wait for 10 ms;
	but_dn <= '1';
	wait for 10 ns;
	but_dn <= '0';
	wait for 10 ns;
	but_dn <= '1';
	wait for 11 ms;
	but_dn <= '0';
	wait for 10 ms;
	wait for 10 ns;
	reset <= '1';
	wait for 10 ms;
	reset <= '0';
	wait for 10 ns;
	but_dn <= '1';
	wait for 10 ns;
	but_dn <= '0';
	wait for 10 ns;
	but_dn <= '1';
	wait for 11 ms;
	but_dn <= '0';
	wait for 10 ms;
	wait;
end process;

end;