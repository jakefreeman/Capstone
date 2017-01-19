----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2017 08:07:08 PM
-- Design Name: 
-- Module Name: pwm_top - Behavioral
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

entity pwm_top is
	Port( 
		clk					: in STD_LOGIC;
		CPU_RESET		: in STD_LOGIC; --active low
		RGB1_Red 		: out STD_LOGIC;
		RGB1_Green 	: out STD_LOGIC;
		RGB1_Blue 	: out STD_LOGIC;
		led 				: out STD_LOGIC_VECTOR (2 downto 0)
		);
end pwm_top;

architecture Behavioral of pwm_top is

component pwm is
	Generic(
	clk_freq 	: integer;
	pwm_freq	: integer;
	pwm_res		: integer;
	count_res	: integer
	);
	Port(
		clk 	: in STD_LOGIC;
		reset	: in STD_LOGIC;
		duty 	: in unsigned(pwm_res-1 downto 0); --10-bit resolution
		pwm		: out STD_LOGIC
	);
end component;



signal count : unsigned(19 downto 0);
signal reset : STD_LOGIC;

signal duty0		: unsigned(9 downto 0);
signal duty1		: unsigned(9 downto 0);
signal duty2		: unsigned(9 downto 0);
signal cnt_dir0	: STD_LOGIC := '0'; -- '0' for up, '1' for down
signal cnt_dir1	: STD_LOGIC := '0';
signal cnt_dir2	: STD_LOGIC := '0';


signal pwm0		: STD_LOGIC;
signal pwm1		: STD_LOGIC;
signal pwm2		: STD_LOGIC;

begin

--Component Instantiations

pwm_1: pwm
	Generic Map(
		clk_freq => 100000000, 		
		pwm_freq => 1000,		
		pwm_res => 10,			
		count_res => 17	
	)
	Port Map(
		clk => clk,
		reset => reset,
		duty=> duty0,
		pwm => pwm0	
	);
	
pwm_2: pwm
	Generic Map(
		clk_freq => 100000000, 		
		pwm_freq => 1000,		
		pwm_res => 10,			
		count_res => 17	
	)
	Port Map(
		clk => clk,
		reset => reset,
		duty=> duty1,
		pwm => pwm1	
	);
	
pwm_3: pwm
	Generic Map(
		clk_freq => 100000000, 		
		pwm_freq => 1000,		
		pwm_res => 10,			
		count_res => 17	
	)
	Port Map(
		clk => clk,
		reset => reset,
		duty=> duty2,
		pwm => pwm2	
	);
	
process (clk, reset) begin
	if rising_edge(clk) then
		if (reset = '1') then
			count 		<= (others => '0');
			cnt_dir0	<= '0';
			cnt_dir1	<= '0';
			cnt_dir2	<= '0';
			duty0 		<= (others => '0');
			duty1 		<= to_unsigned(341,10);
			duty2 		<= to_unsigned(683,10);
		elsif (count = 0) then
			count <= count + 1;
			if (cnt_dir0 = '0') then
				if (duty0 = "0111111111") then
					cnt_dir0 <= not cnt_dir0;
					duty0 <= duty0 - 1;
				else
					cnt_dir0 <= cnt_dir0;
					duty0 <= duty0 + 1;
				end if;
			else
				if (duty0 = "00000000") then
					cnt_dir0 <= not cnt_dir0;
					duty0 <= duty0 + 1;
				else
					cnt_dir0 <= cnt_dir0;
					duty0 <= duty0 - 1;
				end if;
			end if;
			if (cnt_dir1 = '0') then
				if (duty1 = "0111111111") then
					cnt_dir1 <= not cnt_dir1;
					duty1 <= duty1 - 1;
				else
					cnt_dir1 <= cnt_dir1;
					duty1 <= duty1 + 1;
				end if;
			else
				if (duty1 = "00000000") then
					cnt_dir1 <= not cnt_dir1;
					duty1 <= duty1 + 1;
				else
					cnt_dir1 <= cnt_dir1;
					duty1 <= duty1 - 1;
				end if;
			end if;
			if (cnt_dir2 = '0') then
				if (duty2 = "0111111111") then
					cnt_dir2 <= not cnt_dir2;
					duty2 <= duty2 - 1;
				else
					cnt_dir2 <= cnt_dir2;
					duty2 <= duty2 + 1;
				end if;
			else
				if (duty2 = "00000000") then
					cnt_dir2 <= not cnt_dir1;
					duty2 <= duty2 + 1;
				else
					cnt_dir2 <= cnt_dir2;
					duty2 <= duty2 - 1;
				end if;
			end if;		
		else
			count <= count + 1;
			duty0 <= duty0;
			duty1 <= duty1;
			duty2 <= duty2;
		end if;
	end if;
end process;	

reset <= not CPU_RESET;

RGB1_Red 		<= pwm0;
RGB1_Green 	<= pwm1;
RGB1_Blue 	<= pwm2;

led(0) <= pwm0;
led(1) <= pwm1;
led(2) <= pwm2;

end Behavioral;
