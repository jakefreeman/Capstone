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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ASCIItoBCD is
 port(
    clock     : in  std_logic;
    serIn     : in  std_logic;
    dout      : out std_logic_vector (3 downto 0);
    shift     : out std_logic;
    load      : out std_logic    
    );
end ASCIItoBCD;

architecture Behavioral of ASCIItoBCD is

-- Signal Declarations
signal ascii        : std_logic_vector(7  downto 0) := "00000000";
signal count        : std_logic_vector(15 downto 0) := "0000000000000000";
signal count_reset  : std_logic := '0';
signal state        : std_logic_vector(1 downto 0) := "01";
signal next_state   : std_logic_vector(1 downto 0) := "01";
signal ce           : std_logic := '0';
signal bcd          : std_logic_vector(3 downto 0) := "1111";
signal edge1         : std_logic := '0';
signal edge2         : std_logic := '0';
signal edge3         : std_logic := '0';

-- State Definitions
-- S0 = "01"
-- S1 = "10"

begin

  process (clock) begin
    if rising_edge(clock) then
      edge1 <= serIn;
      edge2 <= edge1;
    end if;
  end process;
  
  
  edge3 <= (not edge1 and edge2);
      

  process (clock, count_reset) begin -- 16-bit counter
    if (count_reset = '1') then
      count <= "0000000000000000";
    elsif rising_edge(clock) then
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
      if (count = "0001111010000100") then -- counts to middle of first ascii data bit
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0011001011011101") then --  counts to middle of second ascii data bit
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0100011100110101") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0101101110001110") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "0110111111100111") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "1000010000111111") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "1001100010011000") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "1010110011110001") then
        next_state  <= "10";
        ce          <= '1';
        count_reset <= '0';
      elsif (count = "1100000101001001") then
        next_state  <= "01";
        ce          <= '0';
        count_reset <= '0';
      else 
        next_state  <= "10";
        ce          <= '0';
        count_reset <= '0';
      end if;
    end if;
  end process;
  
  process (clock) begin -- state register
    if rising_edge(clock) then
      state <= next_state;
    end if;
  end process;
  
  process(clock) begin -- when ce = '1', shifts the serial data bit into the 7-bit "ascii" signal
    if rising_edge(clock) then
      if (ce = '1') then
        ascii <= (serIn & ascii(7 downto 1));
      end if;
    end if;
  end process;
  
  process(clock)begin --  converts ascii to BCD, when ascii is not 0-9 or carriage return, sends all 1's. When carriage return, activates load signal
    if rising_edge(clock) then
      if (count = "1100000101001000" and state = "10") then
        if (ascii = "00110000") then
          bcd  <= "0000";
          shift <= '1';
        elsif (ascii = "00110001") then
          bcd  <= "0001";
          shift <= '1';
        elsif (ascii = "00110010") then
          bcd  <= "0010";
          shift <= '1';
        elsif (ascii = "00110011") then
          bcd  <= "0011";
          shift <= '1';
        elsif (ascii = "00110100") then
          bcd  <= "0100";
          shift <= '1';
        elsif (ascii = "00110101") then
          bcd  <= "0101";
          shift <= '1';
        elsif (ascii = "00110110") then
          bcd  <= "0110";
          shift <= '1';
        elsif (ascii = "00110111") then
          bcd  <= "0111";
          shift <= '1';
        elsif (ascii = "00111000") then
          bcd  <= "1000";
          shift <= '1';
        elsif (ascii = "00111001") then
          bcd  <= "1001";
          shift <= '1';
        elsif (ascii = "00001101") then
          load <= '1';
        else
          bcd   <= "1111";
          shift <= '1';
        end if;
      else
        shift <= '0';
        load  <= '0';
      end if;
    end if;
  end process;
  
  dout <= bcd;
  
end Behavioral;
