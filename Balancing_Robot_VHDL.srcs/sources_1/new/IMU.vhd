----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 12/13/2016 11:24:26 AM
-- Design Name: 
-- Module Name: IMU - Behavioral
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

entity IMU is
		generic(
		divisor : integer := 50; --Clock divider frequency/2 for IMU Serial Clock
		cnt_length : integer := 6 --2^whatever is needed to count to divisor
		);
    port ( 
			rst				: in STD_LOGIC; --Synchronous reset
			clk 			: in STD_LOGIC; --100 MHz
      n_cs 			: in STD_LOGIC; --Active low chip select
      sdi 			: in STD_LOGIC; --Serial data in from IMU
      int_in 		: in STD_LOGIC; --interupt from IMU
			data_rdy 	: in STD_LOGIC; --angle out has been calculated and is ready
      sdo 			: out STD_LOGIC; --Serial data out to IMU
			angle_out : out signed(15 downto 0); --16-bit angle value
      sclk 			: out STD_LOGIC --1Mhz
			);
end IMU;

architecture Behavioral of IMU is

component clock_div is
	generic(
		divisor : integer;
		cnt_length : integer
		);
	port(
		clk : in STD_LOGIC; -- Clock unput
    rst : in STD_LOGIC; --Synchronous reset
    div_clk : out STD_LOGIC -- Divided Clock output
	);
end component;

signal div_clk : STD_LOGIC;

begin

CLK_DIV: clock_div
	generic map (
		divisor 		=> divisor,
		cnt_length 	=> cnt_length
	 )
	port map (
		clk 		=> clk,
		rst 		=> rst,
		div_clk => div_clk
		);

	process (clk,rst) begin
	end process;

sclk <= div_clk;
	
end Behavioral;
