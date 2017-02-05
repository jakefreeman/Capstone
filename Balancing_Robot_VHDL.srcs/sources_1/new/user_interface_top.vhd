----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jake Freeman
-- 
-- Create Date: 02/04/2017 07:53:22 PM
-- Design Name: 
-- Module Name: user_interface_top - Behavioral
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

entity user_interface_top is
    Port ( 
		clk 		: in STD_LOGIC;
        btnU 		: in STD_LOGIC;
        btnD 		: in STD_LOGIC;
        btnL 		: in STD_LOGIC;
        btnR 		: in STD_LOGIC;
        btnC 		: in STD_LOGIC;
        btnCpuReset : in STD_LOGIC;
        SerIn 		: in STD_LOGIC;
		dp 			: out STD_LOGIC;
        an 			: out STD_LOGIC_VECTOR (7 downto 0);
        seg 		: out STD_LOGIC_VECTOR (6 downto 0)
	);
end user_interface_top;

architecture Behavioral of user_interface_top is

component user_interface is
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
end component;

component ASCII_to_signed is
 port(
    clk       : in  std_logic;
    serIn     : in  std_logic;
	reset	  : in  std_logic;
    dout      : out signed (17 downto 0);
    load      : out std_logic    
    );
end component;

signal i_reset : STD_LOGIC := '0';
signal i_angle : signed(17 downto 0) := (others => '0');
signal i_dp : STD_LOGIC := '0';

begin

-- Component Instantiations
UI_1: user_interface port map(
	clk 		=> clk,
	btnU		=> btnU,
	btnD		=> btnD,
	btnL 		=> btnL,
	btnR 		=> btnR,
	btnC 		=> btnC,
	btnCpuReset => btnCpuReset,
	angle		=> i_angle,
	dp			=> i_dp,
	rst 		=> i_reset,
	Kp 			=> open,
	Ki 			=> open,
	Kd 			=> open,
	set_point 	=> open,
	an			=> an,
	seg			=> seg
);

ASCII_to_signed_1: ASCII_to_signed port map(
	clk   => clk,
    serIn => SerIn,
    reset => i_reset,
    dout  => i_angle,
    load  => open
);

dp <= i_dp;

end Behavioral;
