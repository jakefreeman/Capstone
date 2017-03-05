----------------------------------------------------------------------------------
-- Engineer: Jacob Freeman
-- 
-- Create Date: 04/14/2015 07:28:34 PM
-- Design Name: 
-- Module Name: ASCIItoBCD - Behavioral
-- Project Name: EE331 Project 1
-- Target Devices: Nexys 4
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

entity ASCII_to_signed is
 port(
    clk     : in  std_logic;
    serIn     : in  std_logic;
	reset	  : in  std_logic;
    dout      : out signed (17 downto 0);
    load      : out std_logic    
    );
end ASCII_to_signed;

architecture Behavioral of ASCII_to_signed is

-- Signal Declarations
signal ascii        : std_logic_vector(7  downto 0) := "00000000";
signal count        : unsigned(15 downto 0) := "0000000000000000";
signal count_reset  : std_logic := '0';
signal state        : std_logic_vector(1 downto 0) := "01";
signal next_state   : std_logic_vector(1 downto 0) := "01";
signal ce           : std_logic := '0';
signal bcd          : signed(4 downto 0) := "00000";
signal edge1         : std_logic := '0';
signal edge2         : std_logic := '0';
signal edge3         : std_logic := '0';

signal bcd_reg0		: signed(4 downto 0);
signal bcd_reg1		: signed(4 downto 0);
signal bcd_reg2		: signed(4 downto 0);
signal bcd_reg3		: signed(4 downto 0);
signal bcd_reg4		: signed(4 downto 0);
signal shift		: STD_LOGIC;
signal i_load		: STD_LOGIC;
signal i_load0		: STD_LOGIC;
signal i_load1		: STD_LOGIC;
signal i_load2		: STD_LOGIC;
signal i_load3		: STD_LOGIC;

signal tens			: signed(17 downto 0) := (others => '0');
signal hundreds		: signed(17 downto 0) := (others => '0');
signal thousands	: signed(17 downto 0) := (others => '0');
signal ten_thousands: signed(17 downto 0) := (others => '0');
signal i_value		: signed(17 downto 0) := (others => '0');

-- State Definitions
-- S0 = "01"
-- S1 = "10"

begin

  process (clk) begin
    if rising_edge(clk) then
      edge1 <= serIn;
      edge2 <= edge1;
    end if;
  end process;
  
  
  edge3 <= (not edge1 and edge2);
      

  process (clk, count_reset) begin -- 16-bit counter
    if (count_reset = '1') then
      count <= "0000000000000000";
    elsif rising_edge(clk) then
      count <= (count + "0000000000000001");
    end if;
  end process;
  
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
      if (count = "0000010100010110") then -- counts to middle of first ascii data bit
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0000100001111010") then --  counts to middle of second ascii data bit
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0000101111011110") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0000111101000010") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0001001010100110") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0001011000001010") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0001100101101110") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0001110011010010") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0010000000110110") then
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
  
  process(clk) begin -- when ce = '1', shifts the serial data bit into the 7-bit "ascii" signal
    if rising_edge(clk) then
      if (ce = '1') then
        ascii <= (serIn & ascii(7 downto 1));
      end if;
    end if;
  end process;
  
  process(clk)begin --  converts ascii to BCD, when ascii is not 0-9 or carriage return, sends all 1's. When carriage return, activates load signal
    if rising_edge(clk) then
      if (count = "0010000000110110" and state = "10") then
        if (ascii = "00110000") then
          bcd  <= "00000";
          shift <= '1';
        elsif (ascii = "00110001") then
          bcd  <= "00001";
          shift <= '1';
        elsif (ascii = "00110010") then
          bcd  <= "00010";
          shift <= '1';
        elsif (ascii = "00110011") then
          bcd  <= "00011";
          shift <= '1';
        elsif (ascii = "00110100") then
          bcd  <= "00100";
          shift <= '1';
        elsif (ascii = "00110101") then
          bcd  <= "00101";
          shift <= '1';
        elsif (ascii = "00110110") then
          bcd  <= "00110";
          shift <= '1';
        elsif (ascii = "00110111") then
          bcd  <= "00111";
          shift <= '1';
        elsif (ascii = "00111000") then
          bcd  <= "01000";
          shift <= '1';
        elsif (ascii = "00111001") then
          bcd  <= "01001";
          shift <= '1';
        elsif (ascii = "00001101") then
          i_load <= '1';
        else
          bcd   <= "11111";
          shift <= '0';
        end if;
      else
        shift <= '0';
        i_load  <= '0';
      end if;
    end if;
  end process;
  
  process(clk, reset, i_load3) begin
	if (reset = '1' or i_load3 = '1') then
		bcd_reg1 <= (others => '0');
		bcd_reg2 <= (others => '0');
		bcd_reg3 <= (others => '0');
		bcd_reg4 <= (others => '0');
	elsif rising_edge(clk) then
		if (shift = '1') then
			bcd_reg4 <= bcd_reg3;
			bcd_reg3 <= bcd_reg2;
			bcd_reg2 <= bcd_reg1;
			bcd_reg1 <= bcd;
		else
			bcd_reg4 <= bcd_reg4;
			bcd_reg3 <= bcd_reg3;
			bcd_reg2 <= bcd_reg2;
			bcd_reg1 <= bcd_reg1;
		end if;
	end if;
  end process;
  
  process(clk, reset) begin
	if (reset = '1') then
		tens      <= (others => '0');
		hundreds  <= (others => '0');
		thousands <= (others => '0');
		ten_thousands <= (others=> '0');
	elsif rising_edge(clk) then
		if (i_load = '1') then
			tens <= resize(bcd_reg1*"01010",18);
			hundreds <= resize(bcd_reg2*"01100100",18);
			thousands <= resize(bcd_reg3*"01111101000",18);
			ten_thousands <= resize(bcd_reg4*"010011100010000",18);
		else 
			tens <= tens;
			hundreds <= hundreds;
			thousands <= thousands;
			ten_thousands <= ten_thousands;
		end if;
	end if;
  end process;
  
  process(clk,reset) begin
	if (reset = '1') then
		i_load0 <= '0';
		i_load1 <= '0';
		i_load2 <= '0';
		i_load3 <= '0';		
	elsif rising_edge(clk) then
		i_load3 <= i_load2;
		i_load2 <= i_load1;
		i_load1 <= i_load0;
		i_load0 <= i_load;
	end if;
  end process;
  
  process(clk,reset) begin
	if (reset = '1') then
		i_value <= (others => '0');
	elsif rising_edge(clk) then
		if (i_load3 = '1') then
			i_value <= (tens)+(hundreds)+(thousands)+(ten_thousands);
		else
			i_value <= i_value;
		end if;
	end if;
  end process;
   
  
  bcd_reg0 <= (others => '0');
  load <= i_load3;
  dout <= i_value;
  
end Behavioral;
