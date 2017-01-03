-- Counter
-- 2ms counter
library ieee; 
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
        
entity display_counter is   
    port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        count : out unsigned(2 downto 0) :="000"
        );
end;

architecture synth of display_counter is

signal q      : unsigned(19 downto 0) := x"00000";		-- 3 bit counter
signal q1     : unsigned(2 downto 0) := "000";
begin

  process(clk, rst) begin
    if (rst = '1') then
        q <= (others => '0');
				q1 <= "000";
    elsif rising_edge(clk) then 
      q <= q + 1;				-- single quotes for single BITS In BINARY. Not sure if works for Dec.
      if (q = x"186A0") then		-- count to 100,000
        q <= (others => '0');
        q1 <= (q1+1);
			end if;
    end if;
  end process;
  count <= q1;
end;


