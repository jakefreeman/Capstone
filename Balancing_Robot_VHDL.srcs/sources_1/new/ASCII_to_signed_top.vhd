----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/03/2017 08:49:39 PM
-- Design Name: 
-- Module Name: ASCII_to_signed_top - Behavioral
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

entity ASCII_to_signed_top is
    Port (
		clk 	: in STD_LOGIC; -- clock
        JB 		: in STD_LOGIC; -- Serial Input 19200 Baud Serial Data
		rst_n	: in STD_LOGIC; -- active low reset
		dp		: out STD_LOGIC;
        an 		: out STD_LOGIC_VECTOR (7 downto 0); -- anode 
        seg 	: out STD_LOGIC_VECTOR (6 downto 0) --7 segment display
	);
end ASCII_to_signed_top;

architecture Behavioral of ASCII_to_signed_top is

component ASCII_to_signed is
    port(
    clk   	: in STD_LOGIC;             
    serIn  	: in STD_LOGIC;             
    reset   : in STD_LOGIC;             
    dout  	: out signed(17 downto 0);  
    load	: out STD_LOGIC    
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

component display_blink is
	Generic(
		clk_freq : integer;
		blnk_freq: integer;
		count_res: integer
	);
	Port( 
		clk 				: in STD_LOGIC;
		reset				: in STD_LOGIC;
		enable 			: in STD_LOGIC;
		anode_in 		: in STD_LOGIC_VECTOR(2 downto 0);
		an_blnk_sel : in STD_LOGIC_VECTOR(2 downto 0);
		anode_out 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end component;



-- Signal Declarations
signal i_value		: unsigned(17 downto 0);
signal i_bcd_single	: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal i_bcd		: STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
signal i_dis_count	: unsigned(2 downto 0) := "000";
signal rst			: STD_LOGIC := '0';
signal load			: STD_LOGIC;



begin

-- component instantiations
ASCII_to_signed_1: ASCII_to_signed port map(
    clk    => clk,    
    serIn  => JB, 
    reset  => rst,  
    unsigned(dout)   => i_value,	
    load   => load
    );

sev_seg_1: seven_seg
	port map(
		din => i_bcd_single,
		segout => seg
	);

display_counter_1: display_counter
	port map(
		clk => clk,
		rst => rst,
		count => i_dis_count
	);
	
to_bcd_1: unsigned_to_bcd
	generic map(
		input_length => 18,
		number_digits => 5
	)
	port map(
		value_in => i_value,
		bcd_out => i_bcd
	);

display_blink_1: display_blink
	generic map(
		clk_freq => 100000000,
		blnk_freq=> 3,
		count_res=> 25
	)
	Port Map(
		clk => clk,		
		reset	=> rst,	
		enable => '0',
		anode_in 	=> STD_LOGIC_VECTOR(i_dis_count),
		an_blnk_sel => "000",
		anode_out 	=> an	
	);

process (i_dis_count) begin
	case i_dis_count is
		when "000" => i_bcd_single <= i_bcd(3 downto 0); -- selects digit of BCD number
		when "001" => i_bcd_single <= i_bcd(7 downto 4);
		when "010" => i_bcd_single <= i_bcd(11 downto 8); 
		when "011" => i_bcd_single <= i_bcd(15 downto 12); 
		when "100" => i_bcd_single <= i_bcd(19 downto 16); 
		when "101" => i_bcd_single <= "0000";
		when "110" => i_bcd_single <= "0000";
		when "111" => i_bcd_single <= "0000";
		when others => i_bcd_single <= "0000";
	end case;
end process;

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

rst <= not rst_n;

end Behavioral;
