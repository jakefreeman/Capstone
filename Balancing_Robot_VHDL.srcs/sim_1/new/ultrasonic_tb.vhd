----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/26/2016 11:15:13 PM
-- Design Name: 
-- Module Name: ultrasonic_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ultrasonic_tb is
--  Port ( );
end ultrasonic_tb;

architecture Behavioral of ultrasonic_tb is

component ultrasonic is 
	Port(
		rst					: in STD_LOGIC; --reset
		clk 				: in STD_LOGIC; --100 MHz clock
		sensor_in 	: in STD_LOGIC; --sensor signal, high time proportional to distance
		trigger_out : out STD_LOGIC; --10us pulse to trigger reading from sensor
		distance 		: out unsigned(8 downto 0)
	);
end component;

---- Signal Declarations ----
signal clock 	: std_logic := '0';
signal reset 	: std_logic := '0';
signal s_in 	: std_logic := '0';
signal t_out	: std_logic := '0';
signal dist 	: unsigned(8 downto 0);

begin

-- instantiate ultrasonic component
US_UT: ultrasonic port map(
	clk 				=> clock,
	rst 				=> reset,
	sensor_in 	=> s_in,
	trigger_out => t_out,
	distance 		=> dist
	);

-- Generate 100MHz clock
process begin
	clock <= not clock;
	wait for 5 ns; -- Clock period is 5ns
end process;

process begin 
	reset <= '1';
	wait for 20 ns;
	reset <= '0';
	wait for 11 us;
	s_in	<= '1';
	wait for 20000 us;
	s_in <= '0';
	wait;
end process;
	
	
	
end Behavioral;
