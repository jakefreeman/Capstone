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
        seg 		: out STD_LOGIC_VECTOR (6 downto 0);
		pwm_out		: out STD_LOGIC;
		dir_1_out	: out STD_LOGIC;
		dir_2_out	: out STD_LOGIC;
		led			: out STD_LOGIC_VECTOR(15 downto 0)
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

component pwm is
	Generic(
		clk_freq 	: integer := 100000000; --100 MHz
		pwm_freq	: integer := 24414; --1kHz
		pwm_res		: integer := 12; --Duty cycle resolution
		count_res	: integer := 12 --this resolution should be able to count to clk_freq/pwm_freq
	);
	Port(
		clk 		: in STD_LOGIC;
		reset		: in STD_LOGIC;
		duty 		: in unsigned(pwm_res-1 downto 0); 
		pwm			: out STD_LOGIC
	);
end component;


signal i_reset 		: STD_LOGIC := '0';
signal i_angle 		: signed(17 downto 0) := (others => '0');
signal i_dp 		: STD_LOGIC := '0';

signal i_Kp 		: signed(20 downto 0) := (others => '0');
signal i_Ki 		: signed(20 downto 0) := (others => '0');
signal i_Kd 		: signed(20 downto 0) := (others => '0');
signal i_set_point 	: signed(17 downto 0) := (others => '0');
signal i_load		: STD_LOGIC := '0';
signal i_PID_out	: signed(38 downto 0) := (others => '0');
signal i_PID_dir	: STD_LOGIC := '0';
signal i_PID_mag	: unsigned(37 downto 0);


signal i_duty		: unsigned(11 downto 0) := (others => '0');
signal i_pwm		: STD_LOGIC := '0';

-- Start signal for process, take out later and make new component
signal pwm_min			: integer := 964; 
signal i_prev_PID_dir	: STD_LOGIC := '0';
signal i_count 			: unsigned(19 downto 0); -- needs to count to 1 million, or 10 ms

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
	Kp 			=> i_Kp,
	Ki 			=> i_Ki,
	Kd 			=> i_Kd,
	set_point 	=> i_set_point,
	an			=> an,
	seg			=> seg
);

PID_1: PID port map(
	clk 	=> clk,
	rst	  	=> i_reset,
	d_ready => i_load,
	set	  	=> i_set_point,
	Kp    	=> i_Kp,
	Ki    	=> i_Ki,
	Kd    	=> i_Kd,
	d_in  	=> i_angle,
	d_out 	=> i_PID_out
);
	
PWM_1: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 12, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> i_duty,
	pwm		=> i_pwm
);
	

ASCII_to_signed_1: ASCII_to_signed port map(
	clk   => clk,
    serIn => SerIn,
    reset => i_reset,
    dout  => i_angle,
    load  => i_load
);

process (clk, i_reset, i_PID_dir, i_prev_PID_dir) begin
	if rising_edge(clk) then
		if (i_reset = '1') then
			i_count <= (others => '0');
			i_duty <= (others => '0');
		elsif (i_PID_dir = not i_prev_PID_dir) then
			i_duty <= "101000000011";
			i_count <= (others => '0');
		elsif (i_count < 1000000) then
			i_duty <= "101000000011";
			i_count <= i_count + 1;
		else
			if (i_PID_mag > 2097151-pwm_min*2**9) then
				i_duty <= (others => '1');
			elsif (i_PID_mag(20 downto 9) < 10) then
				i_duty <= (others => '0');
			else
				i_duty <= i_PID_mag(20 downto 9) + pwm_min;
			end if;
			i_count <= "11110100001001000000";
		end if;
	end if;
end process;

process(clk) begin
	if rising_edge(clk) then
		i_prev_PID_dir <=i_PID_dir;
		i_PID_dir <= i_PID_out(38);
		i_PID_mag <= unsigned(i_PID_out(37 downto 0));
	end if;
end process;
		
			
	

dp <= i_dp;
--i_PID_dir <= i_PID_out(38);
--i_PID_mag <= unsigned(i_PID_out(37 downto 0));
--i_duty <= (others => '1') when (i_PID_mag > 1048576) else unsigned(i_PID_mag(20 downto 9) + 290);
-- pwm_out <= i_pwm;
-- dir_1_out <= i_PID_dir;
-- dir_2_out <= not i_PID_dir;

pwm_out <= '1';
dir_1_out <= i_pwm when (i_PID_out(38) = '1') else '0';
dir_2_out <= i_pwm when (i_PID_out(38) = '0') else '0';

LED(15 downto 4) <= STD_LOGIC_VECTOR(i_duty);
LED(3) <= '0';
LED(2) <= i_PID_out(38);
LED(1) <= i_pwm;
LED(0) <= not i_PID_out(38);
end Behavioral;
