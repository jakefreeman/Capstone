----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 01/01/2017 05:16:58 PM
-- Design Name: 
-- Module Name: unsigned_to_bcd_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for unsigned_to_bcd
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

entity unsigned_to_bcd_tb is
end;

architecture simulation of unsigned_to_bcd_tb is

-- component declaration
component unsigned_to_bcd is
	Generic(
		input_length : integer;
		number_digits : integer
	);
	Port(
		value_in 	: in unsigned(input_length-1 downto 0);
		bcd_out		: out STD_LOGIC_VECTOR (number_digits*4-1 downto 0)
	);
end component;

-- Signal Declarations
signal clock : STD_LOGIC := '0';
signal number : unsigned(15 downto 0);
signal bcd		: STD_LOGIC_VECTOR(15 downto 0);

begin

-- component instantiation
to_bcd_UT: unsigned_to_bcd generic map(
		input_length => 16,
		number_digits => 4
	)
	port map(
		value_in => number,
		bcd_out => bcd
	);
	
process begin
	number <= x"0064"; --100
	wait for 20 ns;
	number <= x"01F4"; --500
	wait for 20 ns;
	number <= x"03E8"; --1000
	wait for 20 ns;
	number <= x"0D05"; --3333
	wait for 20 ns;
	number <= x"270F"; --9999
	wait;
end process;

end;