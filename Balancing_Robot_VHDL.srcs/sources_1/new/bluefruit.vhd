----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jake Freeman
-- 
-- Create Date: 04/12/2017 11:12:41 PM
-- Design Name: 
-- Module Name: bluefruit - Behavioral
-- Project Name: 
-- Target Devices: Adafruit Bluefruit LE UART Friend
-- Tool Versions: 
-- Description: Recieves button and RGB data from Adafruit Bluefruit
-- UART friend
-- 
-- Dependencies: Clock must run at 100Mhz
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

entity bluefruit is
    Port( 
		clk : in STD_LOGIC; -- 100Mhz
		rst	: in STD_LOGIC;
        Rx 	: in STD_LOGIC;
        CTS : out STD_LOGIC;
		-- Button Signals
		B1 	: out STD_LOGIC;
		B2 	: out STD_LOGIC;
		B3 	: out STD_LOGIC;
		B4 	: out STD_LOGIC;
		B5 	: out STD_LOGIC;
		B6 	: out STD_LOGIC;
		B7 	: out STD_LOGIC;
		B8 	: out STD_LOGIC;
		-- RGB signals: each can have values from 0-255
		Ro	: out STD_LOGIC_VECTOR(7 downto 0);
		Go 	: out STD_LOGIC_VECTOR(7 downto 0);
		Bo 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end bluefruit;

architecture Behavioral of bluefruit is

-- Signal Declarations
signal edge1        : std_logic := '0';
signal edge2        : std_logic := '0';
signal edge3        : std_logic := '0';

signal count        : unsigned(19 downto 0) := "00000000000000000000";
signal count_reset  : std_logic := '0';
signal ce           : std_logic := '0';

signal state        : std_logic_vector(1 downto 0) := "01";
signal next_state   : std_logic_vector(1 downto 0) := "01";

signal ascii        : std_logic_vector(7  downto 0) := "00000000";

signal char1		: std_logic_vector(7 downto 0) := "00000000";
signal char2		: std_logic_vector(7 downto 0) := "00000000";
signal char3		: std_logic_vector(7 downto 0) := "00000000";
signal char_count	: unsigned(2 downto 0) := "000";

signal button_flag	: std_logic := '0';
signal color_flag	: std_logic := '0';

signal i_B1			: std_logic := '0';
signal i_B2			: std_logic := '0';
signal i_B3			: std_logic := '0';
signal i_B4			: std_logic := '0';
signal i_B5			: std_logic := '0';
signal i_B6			: std_logic := '0';
signal i_B7			: std_logic := '0';
signal i_B8			: std_logic := '0';

signal i_R			: std_logic_vector(7 downto 0) := "00000000";
signal i_G			: std_logic_vector(7 downto 0) := "00000000";
signal i_B			: std_logic_vector(7 downto 0) := "00000000";

-- ASCII Constants											   ASCII 
constant exclam	: std_logic_vector(7 downto 0) := "00100001"; -- "!"
constant B		: std_logic_vector(7 downto 0) := "01000010"; -- "B"
constant C		: std_logic_vector(7 downto 0) := "01000011"; -- "C"
constant zero	: std_logic_vector(7 downto 0) := "00110000"; -- "0"
constant one 	: std_logic_vector(7 downto 0) := "00110001"; -- "1"
constant but1 	: std_logic_vector(7 downto 0) := "00110001"; -- "1"
constant but2	: std_logic_vector(7 downto 0) := "00110010"; -- "2"
constant but3	: std_logic_vector(7 downto 0) := "00110011"; -- "3"	
constant but4	: std_logic_vector(7 downto 0) := "00110100"; -- "4"
constant but5	: std_logic_vector(7 downto 0) := "00110101"; -- "5"
constant but6	: std_logic_vector(7 downto 0) := "00110110"; -- "6"
constant but7	: std_logic_vector(7 downto 0) := "00110111"; -- "7"
constant but8	: std_logic_vector(7 downto 0) := "00111000"; -- "8"


begin

process (clk) begin
	if rising_edge(clk) then
		edge1 <= Rx;
		edge2 <= edge1;
	end if;
end process;

edge3 <= (not edge1 and edge2);
  
process (clk, count_reset) begin -- 16-bit counter
	if (count_reset = '1') then
		count <= "00000000000000000000";
	elsif rising_edge(clk) then
		count <= (count + "00000000000000000001");
	end if;
end process;

--TODO: change times for 9600 Baud, now set for 115200
process (state, edge3, count) begin  -- two state state machine
	if (state = "01") then
		if (edge3 = '1') then
			next_state  <= "10";
			ce          <= '0';
			count_reset <= '1';
		else 
			next_state  <= "01";
			ce          <= '0';
			count_reset <= '0';
		end if;
    elsif (state = "10") then
		if (count = x"03D08") then -- counts to middle of first ascii data bit
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"065B8") then --  counts to middle of second ascii data bit
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"08E68") then
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"0B717") then
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"0DFC7") then
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"10876") then
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"13126") then
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"159D5") then
			next_state  <= "10";
			ce          <= '1';
			count_reset <= '0';
		elsif (count = x"18285") then
			next_state  <= "01";
			ce          <= '0';
			count_reset <= '0';
		else 
			next_state  <= "10";
			ce          <= '0';
			count_reset <= '0';
		end if;
	else
		next_state 	<= "01";
		ce 			<= '0';
		count_reset <= '0';
    end if;
end process;

process (clk) begin -- state register
    if rising_edge(clk) then
		state <= next_state;
    end if;
end process;

process (clk) begin -- when ce = '1', shifts the serial data bit into the 7-bit "ascii" signal
    if rising_edge(clk) then
		if (ce = '1') then
			ascii <= (Rx & ascii(7 downto 1)); 
		end if;
    end if;
end process;

process(clk, rst) begin
	if rising_edge(clk) then
		if (rst='1') then
			char_count <= "000";
			button_flag <= '0';
			color_flag <= '0';
		elsif (count = x"18285") then -- same as last count
			if (ascii = exclam) then
				char_count <= "000";
				button_flag <= '0';
				color_flag <= '0';
			elsif (ascii = B and char_count = "000") then
				button_flag <= '1';
				color_flag <= '0';
			elsif (ascii = C and char_count = "000") then
				button_flag <= '0';
				color_flag <= '1';
			else
				button_flag <= button_flag;
				color_flag <= color_flag;
				if (button_flag = '1') then
					if (char_count = "000") then
						char1 <= ascii;
						char_count <= char_count + 1;
					elsif (char_count = "001") then
						char2 <= ascii;
						char_count <= char_count + 1;
					else
						char1 <= char1;
						char2 <= char2;
						char_count <= char_count;
					end if;
				elsif (color_flag = '1') then
					if (char_count = "000") then
						char1 <= ascii;
						char_count <= char_count + 1;
					elsif (char_count = "001") then
						char2 <= ascii;
						char_count <= char_count + 1;
					elsif (char_count = "010") then
						char3 <= ascii;
						char_count <= char_count + 1;
					else
						char1 <= char1;
						char2 <= char2;
						char3 <= char3;
						char_count <= char_count;
					end if;
				end if;
			end if;
		else
			button_flag <= button_flag;
			color_flag <= color_flag;
			char1 <= char1;
			char2 <= char2;
			char3 <= char3;
			char_count <= char_count;
		end if;
	end if;
end process;

process(clk) begin
	if rising_edge(clk) then
		if (button_flag = '1' and char_count = "010") then
			if (char2 = zero) then
				if (char1 = but1) then
					i_B1 <= '0';
				elsif (char1 = but2) then
					i_B2 <= '0';	
				elsif (char1 = but3) then
					i_B3 <= '0';	
				elsif (char1 = but4) then
					i_B4 <= '0';
				elsif (char1 = but5) then
					i_B5 <= '0';
				elsif (char1 = but6) then
					i_B6 <= '0';
				elsif (char1 = but7) then
					i_B7 <= '0';
				elsif (char1 = but8) then
					i_B8 <= '0';
				else
					i_B1 <= i_B1;
					i_B2 <= i_B2;
					i_B3 <= i_B3;
					i_B4 <= i_B4;
					i_B5 <= i_B5;
					i_B6 <= i_B6;
					i_B7 <= i_B7;
					i_B8 <= i_B8;
				end if;
			elsif(char2 = one) then
				if (char1 = but1) then
					i_B1 <= '1';
				elsif (char1 = but2) then
					i_B2 <= '1';	
				elsif (char1 = but3) then
					i_B3 <= '1';	
				elsif (char1 = but4) then
					i_B4 <= '1';
				elsif (char1 = but5) then
					i_B5 <= '1';
				elsif (char1 = but6) then
					i_B6 <= '1';
				elsif (char1 = but7) then
					i_B7 <= '1';
				elsif (char1 = but8) then
					i_B8 <= '1';
				else
					i_B1 <= i_B1;
					i_B2 <= i_B2;
					i_B3 <= i_B3;
					i_B4 <= i_B4;
					i_B5 <= i_B5;
					i_B6 <= i_B6;
					i_B7 <= i_B7;
					i_B8 <= i_B8;
				end if;
			end if;
		elsif (color_flag = '1' and char_count = "011") then
			i_R <= char1;
			i_G <= char2;
			i_B <= char3;
		else
			i_B1 <= i_B1;
			i_B2 <= i_B2;
			i_B3 <= i_B3;
            i_B4 <= i_B4;
            i_B5 <= i_B5;
            i_B6 <= i_B6;
            i_B7 <= i_B7;
            i_B8 <= i_B8;
			i_R <= i_R;
			i_G <= i_G;
			i_B <= i_B;
		end if;
	end if;
end process;

B1 <= i_B1;
B2 <= i_B2;
B3 <= i_B3;
B4 <= i_B4;
B5 <= i_B5;
B6 <= i_B6;
B7 <= i_B7;
B8 <= i_B8;
Ro <= i_R;
Go <= i_G;
Bo <= i_B;
CTS <= '0';			
			
end Behavioral;
