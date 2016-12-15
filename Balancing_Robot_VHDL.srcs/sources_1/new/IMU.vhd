----------------------------------------------------------------------------------
-- Engineer: Jacob Freeman
-- 
-- Create Date: 12/13/2016 11:24:26 AM
-- Module Name: IMU - Behavioral
--
-- Description: Module for getting data from an MPU9250 IMU chip and calculating
-- single axis angle data. For use in two wheeled balancing robot. Performs init-
-- ial configuration and calibration.

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
			switch0		: in STD_LOGIC; --accel sensitivy setting switch
			switch1		: in STD_LOGIC; --accel sensitivy setting switch
			switch2		: in STD_LOGIC; --gyro sensitivy setting switch
			switch3		: in STD_LOGIC; --gyro sensitivy setting switch
			rst				: in STD_LOGIC; --Synchronous reset
			clk 			: in STD_LOGIC; --100 MHz
      n_cs 			: in STD_LOGIC; --Active low chip select
      sdi 			: in STD_LOGIC; --Serial data in from IMU
      int_in 		: in STD_LOGIC; --interupt from IMU
			data_rdy 	: in STD_LOGIC; --angle out has been calculated and is ready
      sdo 			: out STD_LOGIC; --Serial data out to IMU
			angle_out : out signed(15 downto 0); --16-bit angle value
      sclk 			: out STD_LOGIC --1Mhz clock for SPI communication
			);
end IMU;

architecture Behavioral of IMU is

-- Componet Declarations
component clock_div is
	generic(
		divisor 		: integer;
		cnt_length 	: integer
		);
	port(
		clk 		: in STD_LOGIC; -- Clock unput
    rst 		: in STD_LOGIC; --Synchronous reset
    div_clk : out STD_LOGIC -- Divided Clock output
	);
end component;



------------------- Signal Declarationws---------------------

-- IMU register value signals
signal reg107			: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --SPI setting register
signal reg28			: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --Accelerometer scale register 
signal reg29			: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --Accelerometer data rate and filter setting register
signal reg26			: STD_LOGIC_VECTOR(7 downto 0) := "00000001"; --Congifuration Register
signal reg27			: STD_LOGIC_VECTOR(7 downto 0) := "00000011"; --Gyroscope scale register
signal reg55			: STD_LOGIC_VECTOR(7 downto 0) := "00110010"; --Interrupt config register

-- Counter signals
signal div_clk 		: STD_LOGIC; --1MHz serial clock from clock_div component
signal count			: unsigned(23 downto 0) := (others => '0'); -- 24-bit counter signal
signal count_en		: STD_LOGIC := '0'; --counter enable
signal count_rst 	: STD_LOGIC := '0'; --counter reset

--State Signals -  nested state machine
signal state			: STD_LOGIC_VECTOR(7 downto 0);
signal next_state : STD_LOGIC_VECTOR(7 downto 0);


begin

reg28(4 downto 3) <= switch0 & switch1;
reg27(4 downto 3) <= switch2 & switch3;

-- Clock divider port map
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

	counter:process(clk, rst, count_rst) begin
		if (rst='1') then
			count <= 0;
		elsif (count_rst = '1') then
			count <= 0;
		elsif (count_en = '1') then
			count <= count + 1;
		else
			count <= count;
		end if;
	end process;
	
	SM:process(state, int, count) begin
		if (state=")
	end process;
	
	sclk <= div_clk; -- 1MHz serial clock from clock_div component
	
end Behavioral;
