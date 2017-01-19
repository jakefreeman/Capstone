library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_top_tb is
end pwm_top_tb;

architecture Behavioral of pwm_top_tb is

component pwm_top is
	Port( 
		clk					: in STD_LOGIC;
		CPU_RESET		: in STD_LOGIC; --active low
		RGB1_Red 		: out STD_LOGIC;
		RGB1_Green 	: out STD_LOGIC;
		RGB1_Blue 	: out STD_LOGIC;
		led 				: out STD_LOGIC_VECTOR (2 downto 0)
		);
end component;

--Signal Declarations
signal i_clk				: STD_LOGIC := '0';
signal i_CPU_RESET	: STD_LOGIC := '1';
signal i_RGB1_Red 	: STD_LOGIC := '0';
signal i_RGB1_Green	: STD_LOGIC := '0';
signal i_RGB1_Blue 	: STD_LOGIC := '0';
signal i_led 				: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

begin

--Component Instantiations
dut1: pwm_top port map(
	clk					=> i_clk,					
	CPU_RESET		=> i_CPU_RESET,		
	RGB1_Red 		=> i_RGB1_Red, 		
	RGB1_Green 	=> i_RGB1_Green, 	
	RGB1_Blue 	=> i_RGB1_Blue, 			
	led 				=> i_led						
);

process begin
	i_clk <= not i_clk;
	wait for 5 ns;
end process;

process begin
	i_CPU_RESET <= '0';
	wait for 20 ns;
	i_CPU_RESET <= '1';
	wait;
end process;

end;