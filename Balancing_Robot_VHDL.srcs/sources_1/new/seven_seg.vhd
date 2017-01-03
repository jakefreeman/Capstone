----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/28/2016 
-- Design Name: 
-- Module Name: seven_seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Converts binary coded decimimal to 7-segment display code
-- 
-- Dependencies: Active low cathodes (1 is off, 0 is on), common annode display
-- 							Input is packed (4-bit) BCD. ALso includes characters P,I,and D
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seven_seg is port (
    din : in std_logic_vector(3 downto 0);  --BCD input
    segout : out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
    );
end;

architecture Behavioral of seven_seg is

begin

-- 7-segment cathode signal assignments
--       Cathode   Signal
--       Letter     Bit
---------------------------     
--  _  |   a    |    0
-- |_| | f   b  |  5   1
-- |_| |   g    |    6  
--     | e   c  |  4   2
--     |   d    |    3

-- Cathodes are active low

segout  <=  "1000000" when din = "0000" else		  -- '0'
            "1111001" when din = "0001" else	    -- '1'
            "0100100" when din = "0010" else	    -- '2'
            "0110000" when din = "0011" else	    -- '3'
            "0011001" when din = "0100" else	    -- '4' 
            "0010010" when din = "0101" else	    -- '5'
            "0000010" when din = "0110" else	    -- '6'
            "1111000" when din = "0111" else	    -- '7'
            "0000000" when din = "1000" else	    -- '8'
            "0011000" when din = "1001" else	    -- '9'
            "0001100" when din = "1010" else			-- 'P'
            "1001111" when din = "1011" else			-- 'I'
            "0100001" when din = "1100" else			-- 'd'
            "1111111" when din = "1101" else
            "1111111" when din = "1110" else
            "1111111" when din = "1111" else "1111111";	--nothing is displayed when a number more than 9 is given as input.	

end Behavioral;
