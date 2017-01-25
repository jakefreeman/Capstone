----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jake Freeman
-- 
-- Create Date: 01/23/2017 05:36:45 PM
-- Design Name: 
-- Module Name: display_blink - Behavioral
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

entity display_blink is
	Generic(
		clk_freq : integer := 100000000; --100MHz
		blnk_freq: integer := 3; --3Hz
		count_res: integer := 25
	);
	Port( 
		clk 				: in STD_LOGIC;
		reset				: in STD_LOGIC;
		enable 			: in STD_LOGIC;
		anode_in 		: in STD_LOGIC_VECTOR(2 downto 0);
		an_blnk_sel : in STD_LOGIC_VECTOR(2 downto 0);
		anode_out 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end display_blink;

architecture Behavioral of display_blink is

--signal declarations
constant i_count_max : integer := clk_freq/blnk_freq;

signal i_count 			: unsigned(count_res- 1 downto 0) := (others => '0');
signal i_blink 			: STD_LOGIC := '1';
signal i_blink_array: STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
signal i_anode 			: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

process(clk,reset) begin
  if rising_edge(clk) then
		if(reset = '1') then
			i_count <= (others => '0');
			i_blink <= '0';
		elsif(i_count = i_count_max) then
			i_blink <= not i_blink;
			i_count <= (others => '0');
		else
			i_count <= i_count + 1;
		end if;
	end if;
end process;

i_blink_array <= "00000000" when i_blink = '1' else "11111111";

i_anode <= "11111110" when anode_in = "000" else 
           "11111101" when anode_in = "001" else 
           "11111011" when anode_in = "010" else
           "11110111" when anode_in = "011" else
           "11101111" when anode_in = "100" else
           "11011111" when anode_in = "101" else
           "10111111" when anode_in = "110" else
           "01111111" when anode_in = "111" else "00000000";


anode_out <= i_anode or i_blink_array when anode_in = an_blnk_sel else i_anode;


end Behavioral;
