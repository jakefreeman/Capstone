----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2017 11:46:25 AM
-- Design Name: 
-- Module Name: bluefruit_top - Behavioral
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

entity bluefruit_top is
    Port ( 
		clk 		: in STD_LOGIC;
        btnCpuReset : in STD_LOGIC;
        Rx 			: in STD_LOGIC;
        CTS 		: out STD_LOGIC;
        RGB2_Red 	: out STD_LOGIC;
        RGB2_Blue 	: out STD_LOGIC;
        RGB2_Green 	: out STD_LOGIC;
        led 		: out STD_LOGIC_VECTOR (7 downto 0)
	);
end bluefruit_top;

architecture Behavioral of bluefruit_top is

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

component pwm is
	Generic(
		clk_freq 	: integer := 100000000; --100 MHz
		pwm_freq	: integer := 24414; --1kHz
		pwm_res		: integer := 8; --Duty cycle resolution
		count_res	: integer := 12 --this resolution should be able to count to clk_freq/pwm_freq
	);
	Port(
		clk 		: in STD_LOGIC;
		reset		: in STD_LOGIC;
		duty 		: in unsigned(pwm_res-1 downto 0); 
		pwm			: out STD_LOGIC
	);
end component;

signal i_rst 	: std_logic := '0';
signal i_R		: std_logic_vector(7 downto 0) := (others => '0');
signal i_G		: std_logic_vector(7 downto 0) := (others => '0');
signal i_B		: std_logic_vector(7 downto 0) := (others => '0');

begin

--Component Instantiation
bluefruit_1: bluefruit port map(
	clk => clk,
	rst	=> i_rst,
    Rx 	=> Rx,
    CTS => CTS,
    B1 	=> led(0),
    B2 	=> led(1),
    B3 	=> led(2),
    B4 	=> led(3),
    B5 	=> led(4),
    B6 	=> led(5),
    B7 	=> led(6),
    B8 	=> led(7),
    Ro 	=> i_R,
    Go 	=> i_G,
    Bo 	=> i_B
);

PWM_R: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 8, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_rst,
	duty	=> unsigned(i_R),
	pwm		=> RGB2_Red
);

PWM_G: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 8, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_rst,
	duty	=> unsigned(i_G),
	pwm		=> RGB2_Green
);

PWM_B: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 8, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_rst,
	duty	=> unsigned(i_B),
	pwm		=> RGB2_Blue
);

i_rst <= not BtnCpuReset;
end Behavioral;
