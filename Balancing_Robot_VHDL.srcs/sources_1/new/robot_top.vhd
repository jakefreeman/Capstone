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

entity robot_top is
    Port ( 
		clk 		: in STD_LOGIC;
        btnU 		: in STD_LOGIC;
        btnD 		: in STD_LOGIC;
        btnL 		: in STD_LOGIC;
        btnR 		: in STD_LOGIC;
        btnC 		: in STD_LOGIC;
        btnCpuReset : in STD_LOGIC;
        SerIn 		: in STD_LOGIC;
		SW0			: in STD_LOGIC;
		RGB1_Red	: out STD_LOGIC;
		RGB1_Green	: out STD_LOGIC;
		RGB2_Red	: out STD_LOGIC;
		RGB2_Green	: out STD_LOGIC;
		RGB2_Blue	: out STD_LOGIC;
		dp 			: out STD_LOGIC;
        an 			: out STD_LOGIC_VECTOR (7 downto 0);
        seg 		: out STD_LOGIC_VECTOR (6 downto 0);
		motor1_out_A: out STD_LOGIC;
		motor1_out_B: out STD_LOGIC;
		motor2_out_A: out STD_LOGIC;
		motor2_out_B: out STD_LOGIC;
		led			: out STD_LOGIC_VECTOR(15 downto 0);
		-- Ultrasonic Sensor ports
		sensor_in1	: in STD_LOGIC;
		sensor_in2	: in STD_LOGIC;
		trigger_out1: out STD_LOGIC;
		trigger_out2: out STD_LOGIC;
		-- Bluefruit Ports
		Rx 			: in STD_LOGIC;
        CTS 		: out STD_LOGIC
	);
end robot_top;

architecture Behavioral of robot_top is

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

component ultrasonic is 
	Port(
		rst			: in STD_LOGIC; --reset
		clk 		: in STD_LOGIC; --100 MHz clock
		sensor_in 	: in STD_LOGIC; --sensor signal, high time proportional to distance
		trigger_out : out STD_LOGIC; --10us pulse to trigger reading from sensor
		distance 	: out unsigned(8 downto 0)
	);
end component;

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


signal i_reset 		: STD_LOGIC := '0';
signal i_angle 		: signed(17 downto 0) := (others => '0');
signal i_dp 		: STD_LOGIC := '0';

signal i_Kp 		: signed(20 downto 0) := (others => '0');
signal i_Ki 		: signed(20 downto 0) := (others => '0');
signal i_Kd 		: signed(20 downto 0) := (others => '0');
signal i_set_point1	: signed(17 downto 0) := (others => '0');
signal i_set_point2	: signed(17 downto 0) := (others => '0');
signal i_set_point3	: signed(17 downto 0) := (others => '0');
signal i_load		: STD_LOGIC := '0';
signal i_PID_out	: signed(38 downto 0) := (others => '0');
signal i_PID_out1	: signed(38 downto 0) := (others => '0');
signal i_PID_out2	: signed(38 downto 0) := (others => '0');
signal i_PID_dir1	: STD_LOGIC := '0';
signal i_PID_dir2	: STD_LOGIC := '0';
signal i_PID_mag1	: unsigned(37 downto 0);
signal i_PID_mag2	: unsigned(37 downto 0);


signal i_duty1		: unsigned(11 downto 0) := (others => '0');
signal i_duty2		: unsigned(11 downto 0) := (others => '0');
signal i_pwm1		: STD_LOGIC := '0';
signal i_pwm2		: STD_LOGIC := '0';

-- Signals for Ultrasonic Sensors
signal i_trigger_out1	: STD_LOGIC := '0';
signal i_trigger_out2	: STD_LOGIC := '0';
signal i_us_distance1	: unsigned(8 downto 0) := "111111111";
signal i_us_distance2	: unsigned(8 downto 0) := "111111111";
signal i_RGB_Red_Duty	: unsigned(11 downto 0) := "000000000000";
signal i_RGB_Green_Duty	: unsigned(11 downto 0) := "000000000000";
signal i_RGB1_Red		: STD_LOGIC := '0';
signal i_RGB1_Green		: STD_LOGIC := '0';

--Signals for Bluefruit Connections
signal i_R			: std_logic_vector(7 downto 0) := (others => '0');
signal i_G			: std_logic_vector(7 downto 0) := (others => '0');
signal i_B			: std_logic_vector(7 downto 0) := (others => '0');
signal i_button1	: std_logic := '0';
signal i_button2	: std_logic := '0';
signal i_button3	: std_logic := '0';
signal i_button4	: std_logic := '0';
signal i_button5	: std_logic := '0';
signal i_button6	: std_logic := '0';
signal i_button7	: std_logic := '0';
signal i_button8	: std_logic := '0';

signal i_buttonU	: std_logic := '0';
signal i_buttonD	: std_logic := '0';
signal i_buttonR	: std_logic := '0';



begin

-- Component Instantiations
UI_1: user_interface port map(
	clk 		=> clk,
	btnU		=> i_buttonU,
	btnD		=> i_buttonD,
	btnL 		=> btnL,
	btnR 		=> i_buttonR,
	btnC 		=> btnC,
	btnCpuReset => btnCpuReset,
	angle		=> i_angle,
	dp			=> i_dp,
	rst 		=> i_reset,
	Kp 			=> i_Kp,
	Ki 			=> i_Ki,
	Kd 			=> i_Kd,
	set_point 	=> i_set_point1,
	an			=> an,
	seg			=> seg
);

PID_1: PID port map(
	clk 	=> clk,
	rst	  	=> i_reset,
	d_ready => i_load,
	set	  	=> i_set_point3,
	Kp    	=> i_Kp,
	Ki    	=> i_Ki,
	Kd    	=> i_Kd,
	d_in  	=> i_angle,
	d_out 	=> i_PID_out
);
	
PWM_Motor1: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 12, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> i_duty1,
	pwm		=> i_pwm1
);

PWM_Motor2: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 12, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> i_duty2,
	pwm		=> i_pwm2
);

PWM_R1: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 12, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> i_RGB_Red_Duty,
	pwm		=> i_RGB1_Red
);

PWM_G1: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 12, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> i_RGB_Green_Duty,
	pwm		=> i_RGB1_Green
);

ASCII_to_signed_1: ASCII_to_signed port map(
	clk   => clk,
    serIn => SerIn,
    reset => i_reset,
    dout  => i_angle,
    load  => i_load
);

US_SENSOR_1: ultrasonic Port Map(
	rst			=> i_reset,
	clk 		=> clk,
	sensor_in 	=> sensor_in1,
	trigger_out => i_trigger_out1,
	distance 	=> i_us_distance1
);

US_SENSOR_2: ultrasonic Port Map(
	rst			=> i_reset,
	clk 		=> clk,
	sensor_in 	=> sensor_in2,
	trigger_out => i_trigger_out2,
	distance 	=> i_us_distance2
);

--Bluefruit Instantiations
bluefruit_1: bluefruit port map(
	clk => clk,
	rst	=> i_reset,
    Rx 	=> Rx,
    CTS => CTS,
    B1 	=> i_button1,
    B2 	=> i_button2,
    B3 	=> i_button3,
    B4 	=> i_button4,
    B5 	=> i_button5, --Up
    B6 	=> i_button6, --Down
    B7 	=> i_button7, --Left
    B8 	=> i_button8, --Right
    Ro 	=> i_R,
    Go 	=> i_G,
    Bo 	=> i_B
);

PWM_R2: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 8, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> unsigned(i_R),
	pwm		=> RGB2_Red
);

PWM_G2: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 8, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> unsigned(i_G),
	pwm		=> RGB2_Green
);

PWM_B2: pwm Generic map(
	clk_freq  	=> 100000000, --100 MHz	
	pwm_freq	=> 24414, --1kHz	
	pwm_res		=> 8, --Duty cycle resolution	
	count_res   => 12 --this resolution should 
)
	Port map(
	clk 	=> clk,
	reset	=> i_reset,
	duty	=> unsigned(i_B),
	pwm		=> RGB2_Blue
);


process(clk, i_reset, i_us_distance1, i_us_distance2, SW0) begin
	if rising_edge(clk) then	
		if (SW0 = '1') then
			if (i_us_distance1 < 10) then
				i_set_point2 <= i_set_point1 + 75;
			elsif (i_us_distance2 < 10) then
				i_set_point2 <= i_set_point1 - 75;
			elsif (i_us_distance1 < 20) then 
				i_set_point2 <= i_set_point1 + 25;
			elsif (i_us_distance2 < 20) then 
				i_set_point2 <= i_set_point1 - 25;
			else
				i_set_point2 <= i_set_point1;
			end if;
		else
			i_set_point2 <= i_set_point1;
		end if;
		if (i_us_distance1 < 10) or (i_us_distance2 < 10) then
			i_RGB_Red_Duty <= "001111111111";
			i_RGB_Green_Duty <= "000000000000";
		elsif (i_us_distance1 < 20) or (i_us_distance2 < 20) then
			i_RGB_Red_Duty <= "001111111111";
			i_RGB_Green_Duty <= "001111111111";
		else
			i_RGB_Red_Duty <= "000000000000";
			i_RGB_Green_Duty <= "001111111111"; 
		end if;
	end if;
end process;		

process (clk, i_reset, i_button1, i_button5, i_button6) begin
	if rising_edge(clk) then
		if (i_button5 = '1') then
			if (i_button1 = '1') then
				i_set_point3 <= i_set_point2 + 200;
			else
				i_set_point3 <= i_set_point2 + 100;
			end if;
		elsif ( i_button6 = '1') then
			if (i_button1 = '1') then
				i_set_point3 <= i_set_point2 - 200;
			else
				i_set_point3 <= i_set_point2 - 100;
			end if;
		else
			i_set_point3 <= i_set_point2;
		end if;
	end if;
end process;
	

process (clk, i_button1, i_button7, i_button8) begin
	if rising_edge(clk) then
		if (i_button7 = '1') then
			LED(3) <= '1';
			if (i_button1 = '1') then
				i_PID_out1 <= i_PID_out + 240000;
				i_PID_out2 <= i_PID_out- 240000;
			else
				i_PID_out1 <= i_PID_out + 160000;
				i_PID_out2 <= i_PID_out - 160000;
			end if;
		elsif (i_button8 = '1') then
			LED(3) <= '1';
			if (i_button1 = '1') then
				i_PID_out1 <= i_PID_out - 240000;
				i_PID_out2 <= i_PID_out + 240000;
			else
				i_PID_out1 <= i_PID_out - 160000;
				i_PID_out2 <= i_PID_out + 160000;
			end if;
		else
			LED(3) <= '0';
			i_PID_out1 <= i_PID_out;
			i_PID_out2 <= i_PID_out;
		end if;
	end if;
end process;
				
dp <= i_dp;

i_buttonU <= btnU or i_button2;
i_buttonD <= btnD or i_button4;
i_buttonR <= btnR or i_button3;


i_PID_dir1 <= i_PID_out1(38);
i_PID_mag1 <= unsigned(i_PID_out1(37 downto 0)) when (i_PID_out1(38) = '0') else unsigned(not i_PID_out1(37 downto 0) - 1);
i_duty1 <= (others => '1') when (i_PID_mag1 > 2097151) else unsigned(i_PID_mag1(20 downto 9));
i_PID_dir2 <= i_PID_out2(38);
i_PID_mag2 <= unsigned(i_PID_out2(37 downto 0)) when (i_PID_out2(38) = '0') else unsigned(not i_PID_out2(37 downto 0) - 1);
i_duty2 <= (others => '1') when (i_PID_mag2 > 2097151) else unsigned(i_PID_mag2(20 downto 9));

--dir_1_out <= i_pwm when (i_PID_out(38) = '1') else '0';
--dir_2_out <= i_pwm when (i_PID_out(38) = '0') else '0';
motor1_out_A <= i_pwm1 when (i_PID_out1(38) = '1') else '0';
motor1_out_B <= i_pwm1 when (i_PID_out1(38) = '0') else '0';
motor2_out_A <= i_pwm2 when (i_PID_out2(38) = '1') else '0';
motor2_out_B <= i_pwm2 when (i_PID_out2(38) = '0') else '0';

LED(15 downto 4) <= STD_LOGIC_VECTOR(i_duty1);
--LED(3) <= '0';
LED(2) <= i_PID_out(38);
LED(1) <= i_pwm1;
LED(0) <= not i_PID_out(38);

trigger_out1 <= i_trigger_out1;
trigger_out2 <= i_trigger_out2;

RGB1_Red <= i_RGB1_Red;
RGB1_Green <= i_RGB1_Green;

end Behavioral;
