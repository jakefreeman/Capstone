library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ACII_to_signed_tb is 
end;

architecture testbench of ACII_to_signed_tb is

--Component top
  component ASCII_to_signed_top is
    port(
    clk   : in STD_LOGIC;                            
    JB    : in STD_LOGIC;                                
    rst_n : in STD_LOGIC;    
	dp	  : out STD_LOGIC;
    an    : out STD_LOGIC_VECTOR(7 downto 0);                   
    seg	  : out STD_LOGIC_VECTOR(6 downto 0)   
   );
  end component;

  -- Signal Declaration
  signal clk    : std_logic := '1';   -- Initial value of the clock
  signal serial : std_logic := '1';
  signal clear  : std_logic := '0';
  signal decimal: std_logic := '0';
  signal anode	: STD_LOGIC_VECTOR(7 downto 0);
  signal segment: STD_LOGIC_VECTOR(6 downto 0);
  
  begin
  
    -- instantiate Project1Top
Top_TB: ASCII_to_signed_top port map(
    clk     => clk,    
    JB  	=> serial, 
    rst_n   => clear,  
	dp		=> decimal,
    AN	 	=> anode,	
    seg		=> segment	
    );
    
    -- Generate clock signal (this is sequential since there is no sensitity list)
    process begin
        clk <= not clk;
        wait for 5 ns; -- Clock period is 10ns
    end process;
    
 -- Generate test data (this is sequential since there is no sensitity list)
    process begin
	
	
      clear <= '0';
      wait for 2000 ns;
      clear <= '1';
      wait for 2000 ns;
	  
	   -- Print a "1"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
	  wait for 52083 ns;
	  
	  --Print a "0"
	  serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
	  wait for 52083 ns;
	  
	  --Print a "0"
	  serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
	  wait for 52083 ns;
	  
	  --Print a "0"
	  serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
	  wait for 52083 ns;
	  
	   -- Print a "CR"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
	  wait for 52083 ns;
      
	  -- Print a "LF"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
	  
	  
      wait for 10ms;
	  
	  --Print a "0"
	  serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "1"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "2"
	  wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
	 

	  -- Print a "CR"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "LF"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
	  
	  
	  -- Print a "3"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- print a "4"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "5"
      wait for 52083ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
	  
	  -- Print a "CR"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "LF"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
      
	  -- print a "6"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "7"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- print an "8"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "CR"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "LF"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
	  
	  -- print a "9"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "CR"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
	  
	  	  -- print a "9"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      
	  -- Print a "CR"
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '1';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
      wait for 52083 ns;
      serial <= '0';
	  wait for 52083 ns;
      serial <= '1';
            
      wait; -- Wait forever.  Without this line the process will start over.
    end process;    
end;
