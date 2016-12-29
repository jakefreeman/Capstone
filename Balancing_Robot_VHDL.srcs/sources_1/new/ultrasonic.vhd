----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 12/22/2016 03:22:30 PM
-- Design Name: 
-- Module Name: ultrasonic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Reads generic HC-SR04 ultrasonic sensors. Designed for 100MHz clock
-- Output is distance in centimeters 9-bit value range from 2 to 400 cm

-- Dependencies: 100 MHz clock
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- trigger length: 10us = x"00 03E8"
-- max time before expected echo return: 23.2ms = x"‭236680"
-- max echo return high-time: 11.76ms = x"11F396"
-- sensor refresh period: 60 ms = x"‭5B8D80‬"
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity ultrasonic is
	Port(
		rst					: in STD_LOGIC; --reset
		clk 				: in STD_LOGIC; --100 MHz clock
		sensor_in 	: in STD_LOGIC; --sensor signal, high time proportional to distance
		trigger_out : out STD_LOGIC; --10us pulse to trigger reading from sensor
		distance 		: out unsigned(8 downto 0)
	);
end ultrasonic;

architecture Behavioral of ultrasonic is

-------------- Signal Declarations --------------
signal i_count : unsigned(23 downto 0) := (others => '0'); --counts to 60ms, or 6 million clock cycles
--10us : x"00 03E8"
--60ms : x"‭5B 8D80‬"
signal i_trigger_out 	: STD_LOGIC := '0'; --internal trigger signal
signal i_edge0 				: STD_LOGIC := '0'; --edge detector
signal i_edge1 				: STD_LOGIC := '0'; --edge detector
signal i_edge_enable	: STD_LOGIC := '0'; --edge detect enable
signal i_rise	 				: unsigned(23 downto 0) := x"FFFFFF"; --count when echo return signal goes high
signal i_time  				: unsigned(23 downto 0) := x"000000"; --time returned signal is high in clock cycles
signal i_distance 		: unsigned(47 downto 0);
signal i_read_flag 		: STD_LOGIC := '0';

begin

counter: process(clk,rst) begin
	if rising_edge(clk) then
		if (rst = '1' or i_count = x"5B8D80") then
			i_count <= x"000000";
		else
			i_count <= i_count + 1;
		end if;
	end if;
end process;
		
trigger: process(clk,rst) begin
	if rising_edge(clk) then 
		if (rst = '1') then
			i_trigger_out <= '0';
		elsif (i_count <= x"0003E8") then
			i_trigger_out <= '1';
		else
			i_trigger_out <= '0';
		end if;
	end if;
end process;
		
get_distance: process(clk,rst) begin
	if rising_edge(clk) then
		i_edge0 <= i_edge1;
		i_edge1 <= sensor_in and i_edge_enable;
		if (rst = '1') then 
			i_read_flag <= '0';
			i_time <= (others => '0');
			i_edge0 <= '0';
			i_edge1 <= '0';
			i_edge_enable <= '1';
			i_rise <= (others => '0');
		end if;			
		if (i_edge0 = '0' and i_edge1 = '1') then
			i_rise <= i_count;
			i_read_flag <= '1';
		else
			i_rise <= i_rise;
		end if;
		if (i_edge0 = '1' and i_edge1 = '0') then 
			i_time <= i_count - i_rise;
		elsif (i_count = x"236A68" and i_read_flag = '0') then
			i_time <= x"23E72D";
			i_edge_enable <= '0';
		elsif (i_count = x"5B8D80") then
			i_read_flag <= '0';
			i_edge_enable <= '1';
		else
			i_time <= i_time;
		end if;
	end if;
end process;

-- process(i_time) begin
	-- if (i_time < 
	
i_distance <= (i_time*x"004268")/x"5F5E100";
distance <= i_distance(8 downto 0);
trigger_out <= i_trigger_out;
			

end Behavioral;
