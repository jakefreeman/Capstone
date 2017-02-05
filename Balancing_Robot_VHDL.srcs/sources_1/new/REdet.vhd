------------------------------------
-- mode name R_E_det
-- EE 331, Larry Piatt 2015
------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity REdet is
	port(
		clk 	: in std_logic;
		din		: in std_logic;
		dout	: out std_logic
	);
end;

architecture behavioral of REdet is

signal q1:std_logic;
signal q0:std_logic;


begin
	dout <= q0 AND not q1;
	process(clk) begin
		if rising_edge(clk) then
			q1 <= q0;
			q0 <= din;
		end if;
	end process;
end;
			

	
		