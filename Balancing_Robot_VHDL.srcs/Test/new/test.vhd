library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;


entity test is
end test;

architecture test of test is

signal clk 		: STD_LOGIC := '0';
signal a 		: signed(2 downto 0) := "000";
signal c		: unsigned(2 downto 0) := "000";
signal b		: signed(2 downto 0) := "000";
signal product	: STD_LOGIC_VECTOR(5 downto 0) := "000000";
signal rst		: STD_LOGIC := '0';

constant CE 	: STD_LOGIC := '1';

begin

MULT_MACRO_inst1:MULT_MACRO -- DSP48 DSP block multipliers.
generic map(
	DEVICE=>"7SERIES",	--TargetDevice:"VIRTEX5","7SERIES","SPARTAN6"
	LATENCY=>0, 		--Desired clock cycle latency, 0-4
	WIDTH_A=>3, 		--Multiplier A-input bus width,1-25
	WIDTH_B=>3) 		--Multiplier B-input bus width,1-18
port map(
	P=>product,			--Multiplier ouput bus, width determined by WIDTH_P generic
	A=>STD_LOGIC_VECTOR(a),--Multiplier inputA bus,width determined by WIDTH_A generic
	B=>STD_LOGIC_VECTOR(b),--Multiplier inputB bus, width determined by WIDTH_B generic
	CE=>CE,				--1-bit active high input clock enable
	CLK=>clk,			--1-bit positive edge clock input
	RST=>rst			--1-bit input active high reset
);

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
rst <= '1';
wait for 10 ns;
rst <= '0';
wait;
end process;

process begin
wait for 30 ns;
a <= a + 1;
c <= c + 1;
end process;

end test;
	