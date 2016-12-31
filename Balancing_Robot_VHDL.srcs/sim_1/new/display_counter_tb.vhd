------------------------------------
-- 2ms counter test bench
-- EE 331, Larry Piatt, Jacob Freeman 2015
------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity display_counter_tb is
end;

architecture behavioral of display_counter_tb is

component counter is
	port(
    clk   : in  std_logic;
    rst   : in  std_logic;
    count : out std_logic_vector :="000"
  );
end component;

signal clock  :std_logic := '0';
signal reset  :std_logic := '0';
signal cnt    :std_logic_vector(2 downto 0) := "000";

begin

	test_counter : counter port map(
		clk   => clock,
		rst   => reset,
		count => cnt
);

	process begin
		clock <= not clock;
		wait for 5 ns;
	end process;

	

end;
	
	
	
	
	