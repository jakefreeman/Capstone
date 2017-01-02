----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 01/01/2017 03:21:58 PM
-- Design Name: 
-- Module Name: unsigned_to_bcd - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Converts unsigned value to packed BCD (4-bits per BCD value)
-- Generics describe input length and output length
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity unsigned_to_bcd is
	Generic(
		input_length : integer := 24;
		number_digits : integer := 7
	);
	Port(
		value_in 	: in unsigned(input_length-1 downto 0);
		bcd_out		: out STD_LOGIC_VECTOR (number_digits*4-1 downto 0)
	);
end unsigned_to_bcd;

architecture Behavioral of unsigned_to_bcd is

function to_bcd(
	number		: unsigned;
	num_digits: integer
	) return unsigned is

	variable i_remainder 	: unsigned(3 downto 0);
	variable i_quotient		: unsigned(number'range);
	variable i_bcd				: unsigned(num_digits*4-1 downto 0);

	begin

	i_quotient := number;

	for i in 0 to num_digits-1 loop
		i_remainder := resize(i_quotient mod 10, 4);
		i_quotient := i_quotient/10;
		i_bcd(i*4+3 downto i*4) := i_remainder;
	end loop;
	return i_bcd;
end to_bcd;

begin

bcd_out <= std_logic_vector(to_bcd(value_in, number_digits));

end Behavioral;
