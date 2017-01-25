----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2017 10:48:56 PM
-- Design Name: 
-- Module Name: display_debounce_tb - Behavioral
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

entity display_blink_tb is
--  Port ( );
end display_blink_tb;

architecture Behavioral of display_blink_tb is

component display_blink is
	Generic(
		clk_freq : integer;
		blnk_freq: integer;
		count_res: integer
	);
	Port( 
		clk 				: in STD_LOGIC;
		reset				: in STD_LOGIC;
		enable 			: in STD_LOGIC;
		anode_in 		: in STD_LOGIC_VECTOR(2 downto 0);
		an_blnk_sel : in STD_LOGIC_VECTOR(2 downto 0);
		anode_out 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

--Signal Declarations
signal clk 		: STD_LOGIC := '1';
signal rst		: STD_LOGIC := '0';
signal en			: STD_LOGIC	:= '0';
signal an_in	: unsigned(2 downto 0) := "000"; 
signal an_b_in: STD_LOGIC_VECTOR(2 downto 0) := "000";
signal an_out	: STD_LOGIC_VECTOR(7 downto 0) := "00000000";

begin

DUT1: display_blink
	Generic Map(
		clk_freq => 100000000,
		blnk_freq=> 5,
		count_res=> 25
	)
	Port Map(
		clk 				=> clk,		
	  reset				=> rst,	
	  enable 			=> en,
	  anode_in 		=> STD_LOGIC_VECTOR(an_in),
	  an_blnk_sel => an_b_in,
	  anode_out 	=> an_out	
	);

process begin
	clk <= not clk;
	wait for 5 ns; --100 MHz Clock
end process;

process begin
	an_in <= an_in + 1;
	wait for 1000 ns;
end process;

process begin
	rst <= '1';
	wait for 20 ns;
	rst <= '0';
	an_b_in <= "010";
	wait for 20 ns;
	en <= '1';
	wait for 200 ns;
	an_b_in <= "001";
	wait;
end process;
	
end Behavioral;
