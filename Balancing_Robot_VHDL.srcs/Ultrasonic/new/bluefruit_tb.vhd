library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity bluefruit_tb is
end bluefruit_tb;

architecture simulation of bluefruit_tb is

component bluefruit is
    Port( 
		clk : in STD_LOGIC;
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
		Ro 	: out STD_LOGIC_VECTOR(7 downto 0);
		Go 	: out STD_LOGIC_VECTOR(7 downto 0);
		Bo 	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

--Signal Declarations
signal clock 	: std_logic := '0';
signal reset 	: std_logic := '0';
signal serial	: std_logic := '1';
signal CTS 		: std_logic := '0';

signal button1	: std_logic := '0';
signal button2	: std_logic := '0';
signal button3	: std_logic := '0';
signal button4	: std_logic := '0';
signal button5	: std_logic := '0';
signal button6	: std_logic := '0';
signal button7	: std_logic := '0';
signal button8	: std_logic := '0';

signal Red		: std_logic_vector(7 downto 0) := "00000000";
signal Green	: std_logic_vector(7 downto 0) := "00000000";
signal Blue		: std_logic_vector(7 downto 0) := "00000000";

--"00100001"; -- "!"
--"01000010"; -- "B"
--"01000011"; -- "C"
--"00110000"; -- "0"
--"00110001"; -- "1"
--"00110001"; -- "1"
--"00110010"; -- "2"
--"00110011"; -- "3"	
--"00110100"; -- "4"
--"00110101"; -- "5"
--"00110110"; -- "6"
--"00110111"; -- "7"
--"00111000"; -- "8"
begin

--Component Instantiation
dut1: bluefruit port map(
	clk => clock,
	rst	=> reset,
    Rx 	=> serial,
    CTS => CTS,
    B1 	=> button1,
    B2 	=> button2,
    B3 	=> button3,
    B4 	=> button4,
    B5 	=> button5,
    B6 	=> button6,
    B7 	=> button7,
    B8 	=> button8,
    Ro 	=> red,
    Go 	=> green,
    Bo 	=> blue
);

process begin
	clock <= not clock;
	wait for 5 ns;
end process;

process begin
	reset <= '1';
	wait for 20 ns;
	reset <= '0';
	wait for 50 ns;
	
	-- ASCII "B" --Just to show what happens when an initial value is not "!"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
		-- ASCII "!"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
		-- ASCII "B"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
			-- ASCII "1"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
				-- ASCII "1"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
	
	
	
		-- ASCII nonsense
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
		-- ASCII "!"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
		-- ASCII "B"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
			-- ASCII "1"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
				-- ASCII "1"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
	
	
	
			-- ASCII "!"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
		-- ASCII "B"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
			-- ASCII "1"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	
				-- ASCII "1"
	serial <= '0'; -- Start bit
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '1';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '0';
	wait for 101460 ns;
	serial <= '1'; -- Stop bit
	wait for 101460 ns;
	wait;
end process;
end;