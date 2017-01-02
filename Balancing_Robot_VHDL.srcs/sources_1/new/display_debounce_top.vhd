----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2017 08:41:24 PM
-- Design Name: 
-- Module Name: display_debounce_top - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_debounce_top is
	Port(
		clk 	: in STD_LOGIC;
		btnU 	: in STD_LOGIC;
		btnD 	: in STD_LOGIC;
		an 		: out STD_LOGIC_VECTOR (7 downto 0);
		seg 	: out STD_LOGIC_VECTOR (6 downto 0)
	);
end display_debounce_top;

architecture Behavioral of display_debounce_top is

---- Component Declarations ----
component debouce is
	Generic(
		counter_size : INTEGER --length of counter 100MHz clock counts to 1 million (x"F240") cycles for 10 ms
	);
  Port( 
		clk					: in STD_LOGIC; --clock
		button_in 	: in STD_LOGIC; --physical button input
    button_out 	: out STD_LOGIC --debounced button output
	);
end component;

component seven_seg is
	Port(
		din : in std_logic_vector(3 downto 0);  --BCD input
		segout : out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
	);
end component;

component display_counter is
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;
		count : out unsigned(2 downto 0)
  );
end component;

component unsinged_to_bcd is 
	Generic(
		input_length : integer;
		number_digits : integer
	);
	Port(
		value_in 	: in unsigned(input_length-1 downto 0);
		bcd_out		: out STD_LOGIC_VECTOR (number_digits*4-1 downto 0)
	);
end component;


---- Signal Declarations ----
signal i_button_up 	: STD_LOGIC;
signal i_button_dn	: STD_LOGIC;

signal i_seg 				: STD_LOGIC_VECTOR(6 downto 0);
signal i_bcd_single	: STD_LOGIC_VECTOR(3 downto 0);

signal i_reset			: STD_LOGIC := '0';
signal i_dis_count	: STD_LOGIC_VECTOR(3 downto 0);

signal i_count			: unsigned(13 downto 0); --max value = 9999
signal i_bcd				: std_logic_vector(15 downto 0);

signal state				: std_logic_vector(1 downto 0);
signal next_state		: std_logic_vector(1 downto 0);

begin

---- Component Instantiations ----
debounce_up: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 				=> clk,
		button_in 	=> btnU,
		button_out 	=> i_button_up
	);

debounce_dn: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 				=> clk,
		button_in 	=> btnD,
		button_out 	=> i_button_dn
	);

sev_seg_1: seven_seg
	port map(
		din => i_bcd_single,
		segout => i_seg
	);

display_counter_1: display_counter
	port map(
		clk => clk,
		rst => i_reset,
		count => i_dis_count
	);
	
to_bcd_1: unsigned_to_bcd
	generic map(
		input_length => 13,
		number_digits => 4
	)
	port map(
		value_in => i_count,
		bcd_out => i_bcd
	);

---- Processes ----

--State Machine for button inputs
process(i_button_up, i_button_dn) begin
	if (state="00") then
		if (i_button_up = '1') then
			if (i_count = "1011100001111") then
				i_count <= (others => '0');
			else
				i_count <= i_count + '1';
			end if;
		next_state <= "01";
		elsif (i_button_dn = '1') then
			if (i_count = "0000000000000") then
				i_count <= "1011100001111";
			else
				i_count <= i_count - '1';
			end if;
		next_state <= "10";
		end if;
	elsif (state = "01") then
		if (i_button_up = '0') then
			next_state <= "00";
		else
			next_state <= "01";
		end if;
	elsif (state = "10") then 
		if (i_button_dn = '0') then
			next_state <= "00";
		else
			next_state <= "10";
		end if;
	else
		next_state <= "00";
	end if;
end process;

-- State changer
process(clk) begin
	if rising_edge(clk) then
		if i_reset = '1' then
			state <= "00";
		else
			state <= next_state;
		end if;
	end if;
end process;
		
	

---- Top Level Connections ----	
i_bcd_single <= i_bcd(3 downto 0) when i_dis_count = "000" else -- selects digit of BCD number
								i_bcd(7 downto 4) when i_dis_count = "001" else
								i_bcd(11 downto 8) when i_dis_count = "010" else
								i_bcd(15 downto 12) when i_dis_count = "011" else
								"0000" when i_dis_count = "100" else 
								"0000" when i_dis_count = "101" else
								"0000" when i_dis_count = "110" else 
								"0000" when i_dis_count = "111";
								
an <= "11111110" when d0 = "000" else -- Selects anode of 7-segment display
      "11111101" when d0 = "001" else 
      "11111011" when d0 = "010" else
      "11110111" when d0 = "011" else
      "11101111" when d0 = "100" else
      "11011111" when d0 = "101" else
      "10111111" when d0 = "110" else
      "01111111" when d0 = "111";

seg <= i_seg;

end Behavioral;
