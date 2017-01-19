library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_tb is
end pwm_tb;

architecture testbench of pwm_tb is

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

signal clock 	: STD_LOGIC := '1';
signal reset 	: STD_LOGIC := '1';
signal duty 	: unsigned(7 downto 0) := (others => '0');
signal pwm_tb	: STD_LOGIC := '0';

begin

pwm_1: pwm
	Generic Map(
		clk_freq => 100000000, 		
		pwm_freq => 20000,		
		pwm_res => 8,			
		count_res => 17	
	)
	Port Map(
		clk => clock,
		reset => reset,
		duty=> duty,
		pwm => pwm_tb	
	);
	
process begin
	clock <= not clock;
	wait for 5 ns; -- 10 ns clock cycle 
end process;

process begin
	reset <= '1';
	wait for 400 ns;
	reset <= '0';
	duty <= to_unsigned(128,8);
	wait for 2 ms;
	duty <= to_unsigned(63,8);
	wait for 2 ms;
	duty <= to_unsigned(191,8);
	wait;
end process;

end;