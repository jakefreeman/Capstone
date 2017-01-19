----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2017 03:58:16 PM
-- Design Name: pwm
-- Module Name: pwm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Creates a pulse-width modulated signal. Clock and pwm frequencies,duty cycle resolution, and counter resolution can be set with generics.
-- 
-- Dependencies: Duty cycle resolution is in bits. Therefore the duty cycle of the signal is calculated with 2^n numbers and not as a percentage. If resolution
-- resolution is 10, then 1023 is 100%; if the resolution is 8-bits, then 255 is 100%, etc.
--
-- PWM frequency must be much lower than clock frequency. Will throw error if pwm_freq > clk_freq/10. The resolution of the duty cycle is limited by 
-- the number of clock cycles per pwm cycle. This shouldn't be an issue unless the clock is very slow or PWM very fast. 
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

entity pwm is
	Generic(
		clk_freq 	: integer := 100000000; --100 MHz
		pwm_freq	: integer := 1000; --1kHz
		pwm_res		: integer := 10; --Duty cycle resolution
		count_res	: integer := 32 --this resolution should be able to count to clk_freq/pwm_freq
	);
	Port(
		clk 	: in STD_LOGIC;
		reset	: in STD_LOGIC;
		duty 	: in unsigned(pwm_res-1 downto 0); --10-bit resolution
		pwm		: out STD_LOGIC
	);
end pwm;

architecture Behavioral of pwm is
-- input assertions to ensure normal operation
--assert 10*pwm_freq < clk_freq report "PWM frequency must be less than 1/10th of the clock frequency" severity error;

constant pwm_period		: integer := clk_freq/pwm_freq;
constant tick_period	: integer := pwm_period/2**pwm_res;

signal i_count0	: unsigned(count_res-1 downto 0);
signal i_count1	: unsigned(count_res-1 downto 0);
signal i_tick		: unsigned(pwm_res-1 downto 0);
signal i_cnt_rst: STD_LOGIC;
signal i_pwm		: STD_LOGIC;

begin

process(clk, reset) begin
	if rising_edge(clk) then
		if (reset = '1') then
			i_count0 <= (others => '0');
			i_count1 <= (others => '0');
			i_tick <= (others => '0');
			i_pwm <= '0';
			i_cnt_rst <= '0';
		elsif (i_cnt_rst = '1') then
			i_count0 <= (others => '0');
			i_count1 <= (others => '0');
			i_tick <= (others => '0');
			i_pwm <= '1';
			i_cnt_rst <= '0';
		elsif (i_count1=tick_period) then
			i_tick <= i_tick + 1;
			i_count1 <= (others => '0');
		elsif (i_tick >= duty) then
			i_pwm <= '0';
			i_count1 <= i_count1 + 1;
			i_count0 <= i_count0 + 1;
		elsif (i_count0 = pwm_period) then
			i_cnt_rst <= '1';
		else
			i_count0 <= i_count0 + 1;
			i_count1 <= i_count1 + 1;
		end if;
	end if;
end process;

pwm <= i_pwm;

end Behavioral;
