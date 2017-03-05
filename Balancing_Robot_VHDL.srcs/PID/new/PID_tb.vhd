library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

entity PID_tb is
end PID_tb;

architecture simulation of PID_tb is

component PID is
    Port( 
	clk   	: in STD_LOGIC;
	rst	  	: in STD_LOGIC;
	d_ready : in STD_LOGIC;
	set	  	: in signed(17 downto 0);
    Kp    	: in signed(20 downto 0);
    Ki    	: in signed(20 downto 0);
    Kd    	: in signed(20 downto 0);
    d_in  	: in signed(17 downto 0);
    d_out 	: out signed(38 downto 0)
	);
end component;

signal tb_clk 		: STD_LOGIC := '0';
signal tb_rst 		: STD_LOGIC := '0';
signal tb_d_ready 	: STD_LOGIC := '0';
signal tb_set	  	: signed(17 downto 0) := (others => '0');
signal tb_Kp    	: signed(20 downto 0) := (others => '0');
signal tb_Ki    	: signed(20 downto 0) := (others => '0');
signal tb_Kd    	: signed(20 downto 0) := (others => '0');
signal tb_d_in  	: signed(17 downto 0) := (others => '0');
signal tb_d_0  		: signed(17 downto 0) := (others => '0');
signal tb_d_1 		: signed(17 downto 0) := (others => '0');
signal tb_d_2 		: signed(17 downto 0) := (others => '0');
signal tb_d_3 		: signed(17 downto 0) := (others => '0');
signal tb_d_4  		: signed(17 downto 0) := (others => '0');
signal tb_d_5  		: signed(17 downto 0) := (others => '0');
signal tb_d_6  		: signed(17 downto 0) := (others => '0');
signal tb_d_7  		: signed(17 downto 0) := (others => '0');
signal tb_d_out 	: signed(38 downto 0) := (others => '0');

begin

DUT1: PID port map(
	clk   	 => tb_clk,	
	rst	  	 => tb_rst, 		
	d_ready  => tb_d_ready, 	
	set	  	 => tb_set,	  	
	Kp    	 => tb_Kp,    	
	Ki    	 => tb_Ki,    	
	Kd    	 => tb_Kd,    	
	d_in  	 => tb_d_in,  	
	d_out 	 => tb_d_out
); 	

---- Generate 100 MHz clock
process begin
	tb_clk <= not tb_clk;
	wait for 5 ns;
end process;

process begin
	tb_rst <= '1';
	wait for 10 ns;
	tb_rst <= '0';
	wait for 10 ns;
	tb_Kp <= to_signed(7,21);
	tb_Ki <= to_signed(5,21);
	tb_Kd <= to_signed(2,21);
	wait for 10 ns;
	wait;
end process;

process begin
	wait for 200 ns;
	tb_d_ready <= '1';
	wait for 10 ns;
	tb_d_ready <= '0';
	wait for 200 ns;
	tb_d_ready <= '1';
	wait for 10 ns;
	tb_d_ready <= '0';	
end process;

process begin
	wait for 2000 ns;
	tb_set <= to_signed(1000,18);
	wait;
end process;	
	
process (tb_clk) begin
	if rising_edge(tb_clk) then
		if (tb_d_ready = '1') then
			tb_d_0<=tb_d_out(17 downto 0);
			tb_d_1<=tb_d_0;
			tb_d_2<=tb_d_1;
			tb_d_3<=tb_d_2;
			tb_d_4<=tb_d_3;
			tb_d_5<=tb_d_4;
			tb_d_6<=tb_d_5;
			tb_d_7<=tb_d_6;
			tb_d_in <= SHIFT_RIGHT((tb_d_0+tb_d_1+tb_d_2+tb_d_3+tb_d_4+tb_d_5+tb_d_6+tb_d_7),3);
		end if;
	end if;
end process;

end;
	