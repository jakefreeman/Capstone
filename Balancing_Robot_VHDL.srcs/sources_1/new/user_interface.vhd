----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jacob Freeman
-- 
-- Create Date: 02/04/2017 10:52:44 AM
-- Design Name: 
-- Module Name: user_interface - Behavioral
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

entity user_interface is
    Port ( 
		clk 		: in STD_LOGIC;
		btnU		: in STD_LOGIC;
		btnD		: in STD_LOGIC;
        btnL 		: in STD_LOGIC;
        btnR 		: in STD_LOGIC;
        btnC 		: in STD_LOGIC;
        btnCpuReset : in STD_LOGIC;
		angle		: in signed(17 downto 0);
		dp			: out STD_LOGIC;
        rst 		: out STD_LOGIC;
        Kp 			: out signed(20 downto 0);
        Ki 			: out signed(20 downto 0);
        Kd 			: out signed(20 downto 0);
        set_point 	: out signed(17 downto 0);
		an			: out STD_LOGIC_VECTOR(7 downto 0);
		seg			: out STD_LOGIC_VECTOR(6 downto 0)
	);
end user_interface;

architecture Behavioral of user_interface is

---- Component Declarations ----
component REdet is
	port(
		clk : in STD_LOGIC;
		din : in STD_LOGIC;
		dout: out STD_LOGIC
	);
end component;

component debounce is
	Generic(
		counter_size : INTEGER --length of counter 100MHz clock counts to 1 million (x"F240") cycles for 10 ms
	);
  Port( 
		clk			: in STD_LOGIC; --clock
		button_in 	: in STD_LOGIC; --physical button input
		button_out 	: out STD_LOGIC --debounced button output
	);
end component;

component seven_seg is
	Port(
		din 	: in std_logic_vector(3 downto 0);  --BCD input
		segout 	: out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
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
		input_length 	: integer;
		number_digits 	: integer
	);
	Port(
		value_in 	: in unsigned(input_length-1 downto 0);
		bcd_out		: out STD_LOGIC_VECTOR (number_digits*4-1 downto 0)
	);
end component;

component display_blink is
	Generic(
		clk_freq 	: integer;
		blnk_freq	: integer;
		count_res	: integer
	);
	Port( 
		clk 		: in STD_LOGIC;
		reset		: in STD_LOGIC;
		enable 		: in STD_LOGIC;
		anode_in 	: in STD_LOGIC_VECTOR(2 downto 0);
		an_blnk_sel : in STD_LOGIC_VECTOR(2 downto 0);
		anode_out 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end component;



----- Signal Declarations -----
signal i_Kp : signed(20 downto 0) := (others => '0');
signal i_Ki	: signed(20 downto 0) := (others => '0');
signal i_Kd	: signed(20 downto 0) := (others => '0');

constant Kmax : signed(20 downto 0) := ('0' & x"F423F");

signal i_set_point : signed(17 downto 0) := ("00" & x"2328");

constant SPmax : signed(17 downto 0) := ("00" & x"4650");

signal i_button_up 		: STD_LOGIC := '0';
signal i_button_dn		: STD_LOGIC := '0';
signal i_button_c		: STD_LOGIC := '0';
signal i_button_l		: STD_LOGIC := '0';
signal i_button_r		: STD_LOGIC := '0';
signal i_button_rst		: STD_LOGIC := '0';

signal i_up 			: STD_LOGIC := '0';
signal i_dn				: STD_LOGIC := '0';
signal i_c				: STD_LOGIC := '0';
signal i_l				: STD_LOGIC := '0';
signal i_r				: STD_LOGIC := '0';
signal i_rst			: STD_LOGIC := '0';

signal i_dis_count		: unsigned(2 downto 0) := "000";

signal i_blink_enable	: STD_LOGIC := '0';
signal i_blink_select	: unsigned(2 downto 0);

signal i_bcd_single		: STD_LOGIC_VECTOR(3 downto 0);
signal i_bcd_p			: STD_LOGIC_VECTOR(23 downto 0);
signal i_bcd_i			: STD_LOGIC_VECTOR(23 downto 0);
signal i_bcd_d			: STD_LOGIC_VECTOR(23 downto 0);
signal i_bcd_sp			: STD_LOGIC_VECTOR(19 downto 0);
signal i_bcd_angle		: STD_LOGIC_VECTOR(19 downto 0);

-- State Declarations -- gray code
-- "000" display Kp 
-- "001" display Ki
-- "011" display Kd
-- "010" display set point
-- "110" display input angle
-- others are invalid
signal state			: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal next_state		: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');


begin

---- Component Instantiations ----
debounce_up: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 		=> clk,
		button_in 	=> btnU,
		button_out 	=> i_button_up
	);

debounce_dn: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 		=> clk,
		button_in 	=> btnD,
		button_out 	=> i_button_dn
	);
	
debounce_c: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 		=> clk,
		button_in 	=> btnC,
		button_out 	=> i_button_c
	);
	
debounce_l: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 		=> clk,
		button_in 	=> btnL,
		button_out 	=> i_button_l
	);

debounce_r: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 		=> clk,
		button_in 	=> btnR,
		button_out 	=> i_button_r
	);
	
debounce_rst: debounce 
	generic map(
		counter_size => 20
	)
	port map(
		clk 		=> clk,
		button_in 	=> i_button_rst,
		button_out 	=> i_rst
	);

REdet_u: REdet port map(
	clk 	=> clk,
	din 	=> i_button_up,
	dout 	=> i_up
	);

REdet_d: REdet port map(
	clk 	=> clk,
	din 	=> i_button_dn,
	dout 	=> i_dn
	);

REdet_l: REdet port map(
	clk 	=> clk,
	din 	=> i_button_l,
	dout 	=> i_l
	);
	
REdet_r: REdet port map(
	clk 	=> clk,
	din 	=> i_button_r,
	dout 	=> i_r
	);
	
REdet_c: REdet port map(
	clk 	=> clk,
	din 	=> i_button_c,
	dout 	=> i_c
	);
	
sev_seg_1: seven_seg
	port map(
		din => i_bcd_single,
		segout => seg
	);

display_counter_1: display_counter
	port map(
		clk => clk,
		rst => i_rst,
		count => i_dis_count
	);
	
to_bcd_1: unsigned_to_bcd
	generic map(
		input_length => 21,
		number_digits => 6
	)
	port map(
		value_in => unsigned(i_Kp),
		bcd_out => i_bcd_p
	);
	
to_bcd_2: unsigned_to_bcd
	generic map(
		input_length => 21,
		number_digits => 6
	)
	port map(
		value_in => unsigned(i_Ki),
		bcd_out => i_bcd_i
	);
	
to_bcd_3: unsigned_to_bcd
	generic map(
		input_length => 21,
		number_digits => 6
	)
	port map(
		value_in => unsigned(i_Kd),
		bcd_out => i_bcd_d
	);
	
to_bcd_4: unsigned_to_bcd
	generic map(
		input_length => 18,
		number_digits => 5
	)
	port map(
		value_in => unsigned(i_set_point),
		bcd_out => i_bcd_sp
	);
	
to_bcd_5: unsigned_to_bcd
	generic map(
		input_length => 18,
		number_digits => 5
	)
	port map(
		value_in => unsigned(angle),
		bcd_out => i_bcd_angle
	);

display_blink_1: display_blink
	generic map(
		clk_freq => 100000000,
		blnk_freq=> 3,
		count_res=> 25
	)
	Port Map(
		clk => clk,		
		reset	=> i_rst,	
		enable => i_blink_enable,
		anode_in 	=> STD_LOGIC_VECTOR(i_dis_count),
		an_blnk_sel => STD_LOGIC_VECTOR(i_blink_select),
		anode_out 	=> an	
	);

---- State Machine 	
process(i_c, state, next_state, i_rst) begin
	if (i_rst = '1') then
		next_state <= "000";
	elsif (state = "000") then
		if (i_c = '1') then
			next_state <= "001";
		else 
			next_state <= "000";
		end if;
	elsif (state = "001") then
		if (i_c = '1') then
			next_state <= "011";
		else
			next_state <= "001";
		end if;
	elsif (state = "011") then
		if (i_c = '1') then
			next_state <= "010";
		else
			next_state <= "011";
		end if;
	elsif (state = "010") then
		if (i_c = '1') then
			next_state <= "110";
		else
			next_state <= "010";
		end if;
	elsif (state = "110") then
		if (i_c = '1') then
			next_state <= "000";
		else
			next_state <= "110";
		end if;
	else
		next_state <= "000";
		assert (next_state /= "111" or next_state /= "101" or next_state /= "100") report "Invalid State" severity error;
	end if;
end process;

process(clk, i_rst) begin -- State/Next_state change only
	if rising_edge(clk) then
		if (i_rst = '1') then
			state <= "000";
		else
			state <= next_state;
		end if;
	end if;
end process;

---- Gain Counters
process(clk, i_up, i_dn, state, i_blink_select, i_rst) begin
	if rising_edge(clk) then
		if (i_rst = '1') then
			i_Kp <= (others => '0');
			i_Ki <= (others => '0');
			i_Kd <= (others => '0');
		else
			if (state = "000") then
				if (i_up = '1') then
					if (i_blink_select = "000") then
						if (i_Kp >= 999999) then 
							i_Kp <= Kmax;
						else
							i_Kp <= i_Kp + 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_Kp >= 999990) then
							i_Kp <= Kmax;
						else
							i_Kp <= i_Kp + 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_Kp >= 999900) then
							i_Kp <= Kmax;
						else
							i_Kp <= i_Kp + 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_Kp >= 999000) then
							i_Kp <= Kmax;
						else
							i_Kp <= i_Kp + 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_Kp >= 990000) then
							i_Kp <= Kmax;
						else
							i_Kp <= i_Kp + 10000;
						end if;
					elsif (i_blink_select = "101") then
						if (i_Kp >= 900000) then
							i_Kp <= Kmax;
						else
							i_Kp <= i_Kp + 100000;
						end if;
					else
						i_Kp <= i_Kp;
					end if;
				elsif (i_dn = '1') then
					if (i_blink_select = "000") then
						if (i_Kp <= 0) then 
							i_Kp <= (others => '0');
						else
							i_Kp <= i_Kp - 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_Kp <= 10) then
							i_Kp <= (others => '0');
						else
							i_Kp <= i_Kp - 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_Kp <= 100) then
							i_Kp <= (others => '0');
						else
							i_Kp <= i_Kp - 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_Kp <= 1000) then
							i_Kp <= (others => '0');
						else
							i_Kp <= i_Kp - 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_Kp <= 10000) then
							i_Kp <= (others => '0');
						else
							i_Kp <= i_Kp - 10000;
						end if;
					elsif (i_blink_select = "101") then
						if (i_Kp <= 100000) then
							i_Kp <= (others => '0');
						else
							i_Kp <= i_Kp - 100000;
						end if;
					else
						i_Kp <= i_Kp;
					end if;
				else
					i_Kp <= i_Kp;
				end if;
			elsif (state = "001") then
				if (i_up = '1') then
					if (i_blink_select = "000") then
						if (i_Ki >= 999999) then 
							i_Ki <= Kmax;
						else
							i_Ki <= i_Ki + 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_Ki >= 999990) then
							i_Ki <= Kmax;
						else
							i_Ki <= i_Ki + 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_Ki >= 999900) then
							i_Ki <= Kmax;
						else
							i_Ki <= i_Ki + 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_Ki >= 999000) then
							i_Ki <= Kmax;
						else
							i_Ki <= i_Ki + 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_Ki >= 990000) then
							i_Ki <= Kmax;
						else
							i_Ki <= i_Ki + 10000;
						end if;
					elsif (i_blink_select = "101") then
						if (i_Ki >= 900000) then
							i_Ki <= Kmax;
						else
							i_Ki <= i_Ki + 100000;
						end if;
					else
						i_Ki <= i_Ki;
					end if;
				elsif (i_dn = '1') then
					if (i_blink_select = "000") then
						if (i_Ki <= 0) then 
							i_Ki <= (others => '0');
						else
							i_Ki <= i_Ki - 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_Ki <= 10) then
							i_Ki <= (others => '0');
						else
							i_Ki <= i_Ki - 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_Ki <= 100) then
							i_Ki <= (others => '0');
						else
							i_Ki <= i_Ki - 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_Ki <= 1000) then
							i_Ki <= (others => '0');
						else
							i_Ki <= i_Ki - 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_Ki <= 10000) then
							i_Ki <= (others => '0');
						else
							i_Ki <= i_Ki - 10000;
						end if;
					elsif (i_blink_select = "101") then
						if (i_Ki <= 100000) then
							i_Ki <= (others => '0');
						else
							i_Ki <= i_Ki - 100000;
						end if;
					else
						i_Ki <= i_Ki;
					end if;
				else
					i_Ki <= i_Ki;
				end if;
			elsif (state = "011") then
				if (i_up = '1') then
					if (i_blink_select = "000") then
						if (i_Kd >= 999999) then 
							i_Kd <= Kmax;
						else
							i_Kd <= i_Kd + 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_Kd >= 999990) then
							i_Kd <= Kmax;
						else
							i_Kd <= i_Kd + 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_Kd >= 999900) then
							i_Kd <= Kmax;
						else
							i_Kd <= i_Kd + 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_Kd >= 999000) then
							i_Kd <= Kmax;
						else
							i_Kd <= i_Kd + 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_Kd >= 990000) then
							i_Kd <= Kmax;
						else
							i_Kd <= i_Kd + 10000;
						end if;
					elsif (i_blink_select = "101") then
						if (i_Kd >= 900000) then
							i_Kd <= Kmax;
						else
							i_Kd <= i_Kd + 100000;
						end if;
					else
						i_Kd <= i_Kd;
					end if;
				elsif (i_dn = '1') then
					if (i_blink_select = "000") then
						if (i_Kd <= 0) then 
							i_Kd <= (others => '0');
						else
							i_Kd <= i_Kd - 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_Kd <= 10) then
							i_Kd <= (others => '0');
						else
							i_Kd <= i_Kd - 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_Kd <= 100) then
							i_Kd <= (others => '0');
						else
							i_Kd <= i_Kd - 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_Kd <= 1000) then
							i_Kd <= (others => '0');
						else
							i_Kd <= i_Kd - 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_Kd <= 10000) then
							i_Kd <= (others => '0');
						else
							i_Kd <= i_Kd - 10000;
						end if;
					elsif (i_blink_select = "101") then
						if (i_Kd <= 100000) then
							i_Kd <= (others => '0');
						else
							i_Kd <= i_Kd - 100000;
						end if;
					else
						i_Kd <= i_Kd;
					end if;
				else
					i_Kd <= i_Kd;
				end if;
			else
				i_Kp <= i_Kp;
				i_Ki <= i_Ki;
				i_Kd <= i_Kd;
			end if;
		end if;
	end if;
end process;

---- Set Point Counters
process(clk, i_up, i_dn, state, i_blink_select, i_rst) begin
	if rising_edge(clk) then
		if (i_rst = '1') then
			i_set_point <= "00" & x"2328";
		else
			if (state = "010") then
				if (i_up = '1') then
					if (i_blink_select = "000") then
						if (i_set_point >= 17999) then 
							i_set_point <= SPmax;
						else
							i_set_point <= i_set_point + 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_set_point >= 17990) then
							i_set_point <= SPmax;
						else
							i_set_point <= i_set_point + 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_set_point >= 17900) then
							i_set_point <= SPmax;
						else
							i_set_point <= i_set_point + 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_set_point >= 17000) then
							i_set_point <= SPmax;
						else
							i_set_point <= i_set_point + 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_set_point >= 7000) then
							i_set_point <= SPmax;
						else
							i_set_point <= i_set_point + 10000;
						end if;
					else
						i_set_point <= i_set_point;
					end if;
				elsif (i_dn = '1') then
					if (i_blink_select = "000") then
						if (i_set_point <= 0) then 
							i_set_point <= (others => '0');
						else
							i_set_point <= i_set_point - 1;
						end if;							
					elsif (i_blink_select = "001") then
						if (i_set_point <= 10) then
							i_set_point <= (others => '0');
						else
							i_set_point <= i_set_point - 10;
						end if;
					elsif (i_blink_select = "010") then
						if (i_set_point <= 100) then
							i_set_point <= (others => '0');
						else
							i_set_point <= i_set_point - 100;
						end if;
					elsif (i_blink_select = "011") then
						if (i_set_point <= 1000) then
							i_set_point <= (others => '0');
						else
							i_set_point <= i_set_point - 1000;
						end if;
					elsif (i_blink_select = "100") then
						if (i_set_point <= 10000) then
							i_set_point <= (others => '0');
						else
							i_set_point <= i_set_point - 10000;
						end if;
					else
						i_set_point <= i_set_point;
					end if;
				else
					i_set_point <= i_set_point;
				end if;
			else
				i_set_point <= i_set_point;
			end if;
		end if;
	end if;
end process;

---- Display Blink Digit Selector
process(i_l,i_r,clk,i_rst) begin
	if rising_edge(clk) then
		if (i_rst='1') then
			i_blink_select <= (others => '0');
		elsif (i_l = '1') then 
			i_blink_select <= i_blink_select + 1;
		elsif (i_r = '1') then 
			i_blink_select <= i_blink_select - 1;
		else
			i_blink_select <= i_blink_select;
		end if;
	end if;
end process;

---- Display Blink Enable
process(state, i_rst) begin
	if (i_rst =  '1') then
		i_blink_enable <= '0';
	else
		if (state /= "110") then
			i_blink_enable <= '1';
		else
			i_blink_enable <= '0';
		end if;
	end if;
end process;

---- Decimal Point Display Logic
process (i_dis_count) begin
	case i_dis_count is
		when "000" => dp <= '1';
		when "001" => dp <= '1';
		when "010" => dp <= '0';
		when "011" => dp <= '1';
		when "100" => dp <= '1';
		when "101" => dp <= '1';
		when "110" => dp <= '1';
		when "111" => dp <= '1';
		when others => dp <= '1';
	end case;
end process;

---- Display Value Logic (Chooses which value to send to display)
process (state, i_dis_count) begin
	if (state = "000") then
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_p(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_p(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_p(11 downto 8); 
			when "011" => i_bcd_single <= i_bcd_p(15 downto 12); 
			when "100" => i_bcd_single <= i_bcd_p(19 downto 16); 
			when "101" => i_bcd_single <= i_bcd_p(23 downto 20);
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "1010"; --"P"
			when others => i_bcd_single <= "0000";
		end case;
	elsif (state = "001") then
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_i(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_i(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_i(11 downto 8); 
			when "011" => i_bcd_single <= i_bcd_i(15 downto 12); 
			when "100" => i_bcd_single <= i_bcd_i(19 downto 16); 
			when "101" => i_bcd_single <= i_bcd_i(23 downto 20);
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "1011"; --"I"
			when others => i_bcd_single <= "0000";
		end case;
	elsif (state = "011") then
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_d(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_d(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_d(11 downto 8); 
			when "011" => i_bcd_single <= i_bcd_d(15 downto 12); 
			when "100" => i_bcd_single <= i_bcd_d(19 downto 16); 
			when "101" => i_bcd_single <= i_bcd_d(23 downto 20);
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "1100"; --"d"
			when others => i_bcd_single <= "0000";
		end case;
	elsif (state = "010") then
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_sp(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_sp(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_sp(11 downto 8); 
			when "011" => i_bcd_single <= i_bcd_sp(15 downto 12); 
			when "100" => i_bcd_single <= i_bcd_sp(19 downto 16); 
			when "101" => i_bcd_single <= "0000";
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "1101"; --"S"
			when others => i_bcd_single <= "0000";
		end case;
	elsif (state = "110") then
		case i_dis_count is
			when "000" => i_bcd_single <= i_bcd_angle(3 downto 0); -- selects digit of BCD number
			when "001" => i_bcd_single <= i_bcd_angle(7 downto 4);
			when "010" => i_bcd_single <= i_bcd_angle(11 downto 8); 
			when "011" => i_bcd_single <= i_bcd_angle(15 downto 12); 
			when "100" => i_bcd_single <= i_bcd_angle(19 downto 16); 
			when "101" => i_bcd_single <= "0000";
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "1110"; --"A"
			when others => i_bcd_single <= "0000";
		end case;
	else
		case i_dis_count is
			when "000" => i_bcd_single <= "0000";-- selects digit of BCD number
			when "001" => i_bcd_single <= "0000";
			when "010" => i_bcd_single <= "0000"; 
			when "011" => i_bcd_single <= "0000"; 
			when "100" => i_bcd_single <= "0000"; 
			when "101" => i_bcd_single <= "0000";
			when "110" => i_bcd_single <= "0000";
			when "111" => i_bcd_single <= "0000";
			when others => i_bcd_single <= "0000";
		end case;	
	end if;
end process;


Kp <= i_Kp;
Ki <= i_Ki;
Kd <= i_Kd;
set_point <= i_set_point;

i_button_rst <= not btnCpuReset;
rst <= i_rst; -- reset output gets output from debounced "not btnCpuReset"

end Behavioral;
