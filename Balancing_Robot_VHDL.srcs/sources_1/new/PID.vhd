----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/01/2017 05:34:23 PM
-- Design Name: 
-- Module Name: PID - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;


entity PID is
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
end PID;

architecture Behavioral of PID is

signal clock		: STD_LOGIC;
signal reset		: STD_LOGIC;
signal input 		: signed(17 downto 0) := (others => '0');
signal prev_input	: signed(17 downto 0) := (others => '0');
--signal prev_input2	: signed(17 downto 0) := (others => '0');
signal output		: signed(38 downto 0) := (others => '0');
--signal prev_output	: signed(38 downto 0) := (others => '0');
signal error 		: signed(17 downto 0) := (others => '0');
signal prev_error 	: signed(17 downto 0) := (others => '0');
signal proportional : signed(17 downto 0) := (others => '0');
signal integral		: signed(17 downto 0) := (others => '0');
signal derivative	: signed(17 downto 0) := (others => '0');

signal pTerm		: STD_LOGIC_VECTOR(38 downto 0) := (others => '0');
signal iTerm		: STD_LOGIC_VECTOR(38 downto 0) := (others => '0');
signal dTerm		: STD_LOGIC_VECTOR(38 downto 0) := (others => '0');

constant CE 		: STD_LOGIC := '1';

signal temp_error_int	: signed (18 downto 0) := (others => '0');
signal error_int		: signed(17 downto 0) := (others => '0');

begin

MULT_MACRO_inst1:MULT_MACRO -- DSP48 DSP block multipliers.
generic map(
	DEVICE=>"7SERIES",	--TargetDevice:"VIRTEX5","7SERIES","SPARTAN6"
	LATENCY=>1, 		--Desired clock cycle latency, 0-4
	WIDTH_A=>21, 		--Multiplier A-input bus width,1-25
	WIDTH_B=>18) 		--Multiplier B-input bus width,1-18
port map(
	P=>pTerm,			--Multiplier ouput bus, width determined by WIDTH_P generic
	A=>STD_LOGIC_VECTOR(Kp),--Multiplier inputA bus,width determined by WIDTH_A generic
	B=>STD_LOGIC_VECTOR(proportional),--Multiplier inputB bus, width determined by WIDTH_B generic
	CE=>CE,				--1-bit active high input clock enable
	CLK=>clk,			--1-bit positive edge clock input
	RST=>reset			--1-bit input active high reset
);

MULT_MACRO_inst2:MULT_MACRO
generic map(
	DEVICE=>"7SERIES",	--TargetDevice:"VIRTEX5","7SERIES","SPARTAN6"
	LATENCY=>1, 		--Desired clock cycle latency, 0-4
	WIDTH_A=>21, 		--Multiplier A-input bus width,1-25
	WIDTH_B=>18) 		--Multiplier B-input bus width,1-18
port map(
	P=>iTerm,				--Multiplier ouput bus, width determined by WIDTH_P generic
	A=>STD_LOGIC_VECTOR(Ki),	--Multiplier inputA bus,width determined by WIDTH_A generic
	B=>STD_LOGIC_VECTOR(SHIFT_RIGHT(error_int,7)),--Multiplier inputB bus, width determined by WIDTH_B generic
	CE=>CE,				--1-bit active high input clock enable
	CLK=>clk,			--1-bit positive edge clock input
	RST=>reset			--1-bit input active high reset
);

MULT_MACRO_inst3:MULT_MACRO
generic map(
	DEVICE=>"7SERIES",	--TargetDevice:"VIRTEX5","7SERIES","SPARTAN6"
	LATENCY=>1, 		--Desired clock cycle latency, 0-4
	WIDTH_A=>21, 		--Multiplier A-input bus width,1-25
	WIDTH_B=>18) 		--Multiplier B-input bus width,1-18
port map(
	P=>dTerm,				--Multiplier ouput bus, width determined by WIDTH_P generic
	A=>STD_LOGIC_VECTOR(Kd),--Multiplier inputA bus,width determined by WIDTH_A generic
	B=>STD_LOGIC_VECTOR(derivative),	--Multiplier inputB bus, width determined by WIDTH_B generic
	CE=>CE,				--1-bit active high input clock enable
	CLK=>clk,			--1-bit positive edge clock input
	RST=>reset			--1-bit input active high reset
);

--------------- Velocity Form of PID ------------------
---- Load when d_ready is high
-- process(clk, rst, d_ready) begin
	-- if rising_edge(clk) then
		-- if (rst = '1') then
			-- input 		<= (others => '0');
			-- prev_output <= (others => '0');
			-- prev_input 	<= (others => '0');
			-- prev_input2	<= (others => '0');
			-- error 		<= (others => '0');
			-- prev_error 	<= (others => '0');		
		-- else
			-- if (d_ready = '1') then
				-- input 		<= d_in;
				-- prev_output <= output;
				-- prev_input 	<= input;
				-- prev_input2	<= prev_input;
				-- prev_error 	<= error;
				-- error 		<= (set - d_in);
			-- else 
				-- input 		<= input; 	
				-- prev_input 	<= prev_input; 
				-- prev_input2	<= prev_input2;
				-- prev_error 	<= prev_error; 
				-- error 		<= error; 	
			-- end if;
		-- end if;
	-- end if;
-- end process;

------------- Position form of PID ----------------
process(clk, rst, d_ready) begin
	if rising_edge(clk) then
		if (rst = '1') then
			input 		<= (others => '0');
			prev_input 	<= (others => '0');
			error 		<= (others => '0');
			prev_error 	<= (others => '0');		
			error_int 	<= (others => '0');	
			proportional<= (others => '0');	
			derivative  <= (others => '0');	
		else
			if (d_ready = '1') then
				input 		<= d_in;
				prev_input 	<= input;
				prev_error 	<= error;
				error 		<= (set - d_in);
				temp_error_int 	<= resize(error_int,19) + resize((set - d_in),19);
				if (temp_error_int > 131070) then
					error_int <= "011111111111111111";
				elsif (temp_error_int < -131070) then
					error_int <= "100000000000000000";
				else
					error_int <= temp_error_int(17 downto 0);
				end if;
				proportional<= SHIFT_RIGHT((set - d_in),2);	
				derivative <= SHIFT_LEFT(input - prev_input,2);
			else 
				input 		<= input; 	
				prev_input 	<= prev_input; 
				prev_error 	<= prev_error; 
				error 		<= error; 	
				proportional<= proportional;
				error_int 	<= error_int;
				derivative  <= derivative;
			end if;
		end if;
	end if;
end process;


process (clk, pTerm, iTerm, dTerm, set, d_in, rst, error) begin
	if (rising_edge(clk)) then
		if (rst = '1') then
			output <= (others => '0');
		elsif ((d_in - set) = "00000000000000000") then
			output <= (others => '0');
		elsif ((error > 4500) or (error < -4500)) then
			output <= (others => '0');
		else
			output <= signed(pTerm) + signed(iTerm) - signed(dTerm);
		end if;
	end if;
end process;


--proportional <= error - prev_error;	
--derivative <= input-SHIFT_LEFT(prev_input,1)+prev_input2;
--derivative <= SHIFT_RIGHT(input - prev_input,4);
--output <= prev_output + signed(pTerm) + signed(iTerm) - signed(dTerm);
--d_out <= output when output(38) = '0' else output(38) & ((not output(37 downto 0)) - 1); 
d_out <= output; 
--d_out <= output;
reset <= rst;
end Behavioral;
