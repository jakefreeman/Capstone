----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2016 04:47:38 PM
-- Design Name: 
-- Module Name: IMU-top - Behavioral
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

entity IMU_tb is
	Port (
	angle : out STD_LOGIC_VECTOR(15 downto 0)
	);
end IMU_tb;

architecture Behavioral of IMU_tb is

component IMU is 
		generic(
			divisor : integer; --Clock divider frequency/2 for IMU Serial Clock
			cnt_length : integer --2^whatever is needed to count to divisor
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
end component;

signal reset 			: STD_LOGIC :='0';
signal clock 			: STD_LOGIC :='0';
signal chip_select: STD_LOGIC :='0';
signal sdi 				: STD_LOGIC := '0'; 
signal int_in 		: STD_LOGIC := '0'; 
signal data_rdy 	: STD_LOGIC := '0'; 
signal sdo 				: STD_LOGIC := '0'; 
signal angle_out 	: signed(15 downto 0) := (others => '0');
signal sclk 			: STD_LOGIC := '0';
constant divisor 		: integer := 50;
constant cnt_length : integer := 6;

begin

IMU_UT: IMU 
generic map(
	divisor => divisor,
	cnt_length => cnt_length
	)
port map(
	rst				=> reset, 			
  clk 			=> clock, 			
  n_cs 			=> chip_select,
  sdi 			=> sdi, 				
  int_in 		=> int_in, 		
  data_rdy 	=> data_rdy, 	
  sdo 			=> sdo, 				
	angle_out => angle_out, 	
	sclk 			=> sclk 			
	);

process begin
	clock <= not clock;
	wait for 5 ns; -- 100MHz Clock
end process;

process begin
	wait for 10 ns;
	reset <= '1';
	wait for 20 ns;
	reset <= '0';
	wait;
	
end process;

end Behavioral;
