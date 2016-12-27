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
      sdi 			: in STD_LOGIC; --Serial data in from IMU
      int_in 		: in STD_LOGIC; --interupt from IMU
			data_rdy 	: in STD_LOGIC; --angle out has been calculated and is ready
      n_cs 			: out STD_LOGIC; --Active low chip select
			sdo 			: out STD_LOGIC; --Serial data out to IMU
			angle_out : out signed(15 downto 0); --16-bit angle value
      sclk 			: out STD_LOGIC --1Mhz clock for SPI communication
			);
end IMU;

architecture Behavioral of IMU is

------------------- Signal Declarationws---------------------

-- IMU register addresses for reading and writing
constant add_26		: STD_LOGIC_VECTOR(6 downto 0) := "0011010"; --Congifuration Register
constant add_27   : STD_LOGIC_VECTOR(6 downto 0) := "0011011"; --Gyroscope scale register
constant add_28   : STD_LOGIC_VECTOR(6 downto 0) := "0011100"; --Accelerometer scale register 
constant add_29   : STD_LOGIC_VECTOR(6 downto 0) := "0011101"; --Accelerometer data rate and filter setting register
constant add_55   : STD_LOGIC_VECTOR(6 downto 0) := "0100101"; --Interrupt config register
constant add_106  : STD_LOGIC_VECTOR(6 downto 0) := "1101010"; --SPI setting register

-- IMU register value signals
constant reg26		: STD_LOGIC_VECTOR(7 downto 0) := "00000001"; --Congifuration Register
signal   reg27		: STD_LOGIC_VECTOR(7 downto 0) := "00000011"; --Gyroscope scale register
signal   reg28		: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --Accelerometer scale register 
constant reg29		: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --Accelerometer data rate and filter setting register
constant reg55		: STD_LOGIC_VECTOR(7 downto 0) := "00110010"; --Interrupt config register
constant reg106		: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --SPI setting register


-- Counter signals
signal count			: unsigned(23 downto 0) := (others => '0'); -- 24-bit counter signal
signal count_en		: STD_LOGIC := '0'; --counter enable
signal count_rst 	: STD_LOGIC := '0'; --counter reset

--State Signals - one-hot encoded
signal setup_flag	: STD_LOGIC := '1';
signal state			: STD_LOGIC_VECTOR(7 downto 0) := "00000001";
signal next_state : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
signal state_count: unsigned(7 downto 0) := "00000000";
signal state_id		: STD_LOGIC_VECTOR(7 downto 0) := "00000001";
constant i_read		: STD_LOGIC_VECTOR(7 downto 0) := "00000010";
constant i_write	: STD_LOGIC_VECTOR(7 downto 0) := "00000100";
constant i_wait		: STD_LOGIC_VECTOR(7 downto 0) := "00001000";


--Other internal signal
signal i_data 	: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --address/reg value to be sent to IMU. Updates every write/read cycle
signal i_accel	: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --accelerometer data
signal i_gyro		: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --gyroscope data
signal i_IMU_in	: STD_LOGIC_VECTOR(7 downto 0) := "00000000"; --data from IMU, accel or gryo data
signal i_rd_wr	: STD_LOGIC := '0'; --read(1)/write(0) signal
signal i_n_cs 	: STD_LOGIC := '1'; --active low chip select
signal i_sdo		: STD_LOGIC := '0'; --serial out to IMU
signal i_sclk		: STD_LOGIC := '1'; --serial clock to IMU


begin

reg27(4 downto 3) <= switch2 & switch3;
reg28(4 downto 3) <= switch0 & switch1;
	

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
		if (state="00000001") then --wait 100ms
			count_en <= '1';
			i_n_cs <= '1';
			if (count = x"000032") then -- change 
				next_state <= "00000010"; --counts for 100ms
				count_rst <= '1';
			else
				next_state <= "00000001";
				count_rst <= '0';
			end if;
		elsif (state="00000010") then -- write 
			count_en <= '1';
			i_n_cs <= '0';
			if (count < x"000032") then
				next_state <= state;
				count_rst <= '0';
				i_sclk <= i_sclk;
				i_sdo <= i_sdo;
			elsif (count = x"00032") then --first falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(7);
			elsif (count = x"000064") then --first rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000096") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(6);
			elsif (count = x"0000C8") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"0000FA") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(5);
			elsif (count = x"00012C") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"00015E") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(4);
			elsif (count = x"000190") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"0001C2") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(3);
			elsif (count = x"0001F4") then --first rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000226") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(2);
			elsif (count = x"000258") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"00028A") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(1);
			elsif (count = x"0002BC") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count =x"0002EE") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_sdo <= i_data(0);
			elsif (count = x"000320") then --last rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_sdo <= i_sdo;
			elsif (count = x"000352") then
				next_state <= "00000100";
				count_rst <= '1';
				i_sclk <= i_sclk;
				i_sdo <= i_sdo;
			else
				next_state <= state;
				count_rst <= '0';
				i_sclk <= i_sclk;
				i_sdo <= i_sdo;
			end if;
		elsif (state = "00000100") then -- read
			count_en <= '1';
			i_n_cs <= '0';
			if (count < x"000032") then
				next_state <= state;
				count_rst <= '0';
				i_sclk <= i_sclk;
				i_IMU_in <= i_IMU_in;
			elsif (count = x"00032") then --first falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"000064") then --first rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(7) <= sdi;
			elsif (count = x"000096") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"0000C8") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(6) <= sdi;
			elsif (count = x"0000FA") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"00012C") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(5) <= sdi;
			elsif (count = x"00015E") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"000190") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(4) <= sdi;
			elsif (count = x"0001C2") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"0001F4") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(3) <= sdi;
			elsif (count = x"000226") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_n_cs <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"000258") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(2) <= sdi;
			elsif (count = x"00028A") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"0002BC") then --next rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(1) <= sdi;
			elsif (count =x"0002EE") then --next falling edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '0';
				i_IMU_in <= i_IMU_in;
			elsif (count = x"000320") then --last rising edge of sclk
				next_state <= state;
				count_rst <= '0';
				i_sclk <= '1';
				i_IMU_in(0) <= sdi;
			elsif (count = x"000352") then --end of cycle
				next_state <= "00001000";
				count_rst <= '1';
				i_sclk <= i_sclk;
				i_IMU_in <= i_IMU_in;
			else
				next_state <= state; --waiting
				count_rst <= '0';
				i_sclk <= i_sclk;
				i_IMU_in <= i_IMU_in;
			end if;		
		elsif (state = "00001000") then -- waiting for data
			count_en <= '0';
			count_rst <= '1';
			i_n_cs <= '1';
			i_sclk <= i_sclk;
			i_IMU_in <= i_IMU_in;
			i_sdo <= i_sdo;
			if (int_in = '1') then
				next_state <= "00000010"; -- change later
			else
				next_state <= state;
			end if;
		end if;
					
	end process;
	
	process (state_count) begin
	end process;
	
	
	SM_REGISTER:process(clk) begin
		if rising_edge(clk) then
			if (rst = '1') then
				state <= "00000001";
			else
				state <= next_state;
			end if;
			if (state /= next_state) then
				state_count <= state_count + 1;
			else
				state_count <= state_count;
			end if;
		end if;
	end process;
	
	sclk <= i_sclk; -- 1MHz serial clock from clock_div component
	sdo <= i_sdo; --Serial out to IMU
	n_cs <= i_n_cs;
	
end Behavioral;
