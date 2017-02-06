library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test is
end test;

architecture test of test is

signal clk 		: STD_LOGIC := '0';
signal a 		: signed(2 downto 0) := "000";
signal c		: unsigned(2 downto 0) := "000";
signal b		: signed(2 downto 0) := "000";

begin

process begin
	clk <= not clk;
	wait for 5 ns;
end process;

process (clk) begin	
	if rising_edge(clk) then
		if (a(2) = '1') then
			b <= (a(2) & not a(1 downto 0));
		else
			b <= a;
		end if;
	end if;
end process;

process begin
wait for 10 ns;
a <= a + 1;
c <= c + 1;
end process;

end test;
	