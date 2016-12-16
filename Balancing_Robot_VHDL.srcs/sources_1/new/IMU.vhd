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

--State Signals - one-hot encoded
signal state			: STD_LOGIC_VECTOR(7 downto 0) := "00000001";
signal next_state : STD_LOGIC_VECTOR(7 downto 0) := "00000001";

--Other internal signal
signal i_n_cs : STD_LOGIC := '1'; --active low chip select
signal i_sdo	: STD_LOGIC := '0'; --serial out to IMU
signal i_sclk	: STD_LOGIC := '1'; --serial clock to IMU


begin

i_n_cs <= '1';
reg28(4 downto 3) <= switch0 & switch1;
reg27(4 downto 3) <= switch2 & switch3;

	counter:process(clk, rst, count_rst,count_en) begin
	  if rising_edge(clk) then
			if (rst='1') then
				count <= x"000000";
			elsif (count_rst = '1') then
				count <= x"000000";
			elsif (count_en = '1') then
				count <= count + 1;
			else
				count <= count;
			end if;
		end if;
	end process;
	
	IMU_SM:process(state, int_in, count) begin
		if (state="00000001") then
			count_en <= '1';
			i_n_cs <= '1';
			if (count = x"00000F") then -- change 
				next_state <= "00000010"; --counts for 100ms
				count_rst <= '1';
			else
				next_state <= "00000001";
				count_rst <= '0';
			end if;
		elsif (state="00000010") then
			count_en <= '1';
			if (count < x"0000C8") then
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= i_sclk;
				i_sdo <= i_sdo;
			elsif (count = x"000C8") then --first falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(7);
			elsif (count = x"000190") then --first rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000258") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(6);
			elsif (count = x"000320") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"0003E8") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(5);
			elsif (count = x"000480") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000578") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(4);
			elsif (count = x"000640") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000708") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(3);
			elsif (count = x"0007D0") then --first rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000898") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(2);
			elsif (count = x"000960") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"A28") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(1);
			elsif (count = x"000AF0") then
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count =x"000BB8") then 
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_sdo <= reg107(0);
			elsif (count = x"000C80") then 
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000D48") then
				next_state <= "00000100";
				count_rst <= '1';
				i_n_cs <= '1';
				i_sclk <= i_sclk;
				i_sdo <= i_sdo;
			else
				next_state <= "00000010"; -- Change Later
				i_n_cs <= '0';
				i_sclk <= i_sclk;
				i_sdo <= i_sdo;
			end if;
		end if;
					
	end process;
	
	SM_REGISTER:process(clk) begin
		if rising_edge(clk) then
			if (rst = '1') then
				state <= "00000001";
			else
				state <= next_state;
			end if;
		end if;
	end process;
	
	sclk <= i_sclk; -- 1MHz serial clock from clock_div component
	sdo <= i_sdo; --Serial out to IMU
	
end Behavioral;
