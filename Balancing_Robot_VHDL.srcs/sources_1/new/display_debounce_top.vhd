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
		btnC	: in STD_LOGIC;
		echo 	: in STD_LOGIC;
		CPU_RESET		: in STD_LOGIC;
		an 		: out STD_LOGIC_VECTOR (7 downto 0);
		seg 	: out STD_LOGIC_VECTOR (6 downto 0);
		trigger	: out STD_LOGIC
	);
end display_debounce_top;

architecture Behavioral of display_debounce_top is

---- Component Declarations ----
component debounce is
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

component unsigned_to_bcd is 
	Generic(
		input_length : integer;
		number_digits : integer
	);
	Port(
		value_in 	: in unsigned(input_length-1 downto 0);
		bcd_out		: out STD_LOGIC_VECTOR (number_digits*4-1 downto 0)
	);
end component;

component ultrasonic is
	Port(
		rst					: in STD_LOGIC; --reset
		clk 				: in STD_LOGIC; --100 MHz clock
		sensor_in 	: in STD_LOGIC; --sensor signal, high time proportional to distance
		trigger_out : out STD_LOGIC; --10us pulse to trigger reading from sensor
		distance 		: out unsigned(8 downto 0)
	);
end component;


---- Signal Declarations ----
signal i_button_up 			: STD_LOGIC := '0';
signal i_button_up_prev : STD_LOGIC := '0';
signal i_button_dn			: STD_LOGIC := '0';
signal i_button_dn_prev : STD_LOGIC := '0';
signal i_button_c				: STD_LOGIC := '0';
signal i_button_c_prev 	: STD_LOGIC := '0';


signal i_bcd_single			: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

signal i_dis_count			: unsigned(2 downto 0) := "000";

signal i_count					: unsigned(13 downto 0) := (others => '0'); --max value = 9999
signal i_bcd_1					: std_logic_vector(15 downto 0) := (others => '0');
signal i_bcd_2					: std_logic_vector(11 downto 0) := (others => '0');

signal i_reset					: STD_LOGIC := '0';

signal i_us_trigger			: STD_LOGIC := '0';
signal i_us_distance		: unsigned(8 downto 0) := (others => '0');

signal state						: STD_LOGIC := '0';
signal next_state				: STD_LOGIC := '0';

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
	
debounce_c: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 				=> clk,
		button_in 	=> btnC,
		button_out 	=> i_button_c
	);

sev_seg_1: seven_seg
	port map(
		din => i_bcd_single,
		segout => seg
	);

display_counter_1: display_counter
	port map(
		clk => clk,
		rst => i_reset,
		count => i_dis_count
	);
	
to_bcd_1: unsigned_to_bcd
	generic map(
		input_length => 14,
		number_digits => 4
	)
	port map(
		value_in => i_count,
		bcd_out => i_bcd_1
	);
	
to_bcd_2: unsigned_to_bcd
	generic map(
		input_length => 9,
		number_digits => 3
	)
	port map(
		value_in => i_us_distance,
		bcd_out => i_bcd_2
	);
	
us_sensor_1: ultrasonic
	port map(
		rst					=> i_reset,
		clk 				=> clk,
		sensor_in 	=> echo,
		trigger_out => i_us_trigger,
		distance 		=> i_us_distance		
	);

---- Processes ----

		
process(clk, i_button_up, i_button_up_prev, i_button_dn, i_button_dn_prev) begin
	if rising_edge(clk) then
		i_button_up_prev <= i_button_up;
		i_button_dn_prev <= i_button_dn;
		if (i_button_up_prev = '0' and i_button_up = '1') then --rising edge detector
		report "i_button_up rising edge";
			if (i_count = "10011100001111") then 
				i_count <= "00000000000000";
			else 
				i_count <= i_count + 1;
			end if;
		elsif (i_button_dn_prev = '0' and i_button_dn = '1') then --rising edge detector
			report "i_button_dn rising edge";
			if (i_count = "00000000000000") then 
				i_count <= "10011100001111";
			else 
				i_count <= i_count - 1;
			end if;
		else
			i_count <= i_count;
		end if;
	end if;
end process;

process(clk) begin
	if rising_edge(clk) then
			i_button_c_prev <= i_button_c;
	end if;
end process;

process(i_button_c,i_button_c_prev) begin
		if (state = '0') then
			if (i_button_c_prev = '0' and i_button_c = '1') then --rising edge detector
				next_state <= '1';
			else 
				next_state <= '0';
			end if;
		else--if state = '1'
			if (i_button_c_prev = '0' and i_button_c = '1') then --rising edge detector
				next_state <= '0';
			else
				next_state <= '1';
			end if;
		end if;
end process;

process(clk, i_reset) begin
	if rising_edge(clk) then
		if (i_reset = '1') then
			state <= '0';
		else
			state <= next_state;
		end if;
	end if;
end process;


---- Top Level Connections ----	
i_reset <= not CPU_RESET;
trigger <= i_us_trigger;

process (state, i_dis_count) begin
	if (state = '0') then
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_1(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_1(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_1(11 downto 8); 
			when "011" => i_bcd_single <= i_bcd_1(15 downto 12); 
			when "100" => i_bcd_single <= "0000";
			when "101" => i_bcd_single <= "0000";
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "0000";
			when others => i_bcd_single <= "0000";
		end case;
	else
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_2(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_2(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_2(11 downto 8); 
			when "011" => i_bcd_single <= "0000"; 
			when "100" => i_bcd_single <= "0000";
			when "101" => i_bcd_single <= "0000";
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "0000";
			when others => i_bcd_single <= "0000";
		end case;
	end if;
end process;


an <= "11111110" when i_dis_count = "000" else -- Selects anode of 7-segment display
      "11111101" when i_dis_count = "001" else 
      "11111011" when i_dis_count = "010" else
      "11110111" when i_dis_count = "011" else
      "11101111" when i_dis_count = "100" else
      "11011111" when i_dis_count = "101" else
      "10111111" when i_dis_count = "110" else
      "01111111" when i_dis_count = "111" else "00000000";


end Behavioral;
