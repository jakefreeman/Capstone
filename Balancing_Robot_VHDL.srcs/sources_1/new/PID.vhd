----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/01/2017 05:34:23 PM
-- Design Name: 
-- Module Name: PID - Behavioral
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

entity PID is
    Port( 
	clk   : in STD_LOGIC;
	set	  : in signed(11 downto 0);
    Kp    : in STD_LOGIC_VECTOR (19 downto 0);
    Ki    : in STD_LOGIC_VECTOR (19 downto 0);
    Kd    : in STD_LOGIC_VECTOR (19 downto 0);
    d_in  : in STD_LOGIC;
    d_out : out STD_LOGIC
	);
end PID;

architecture Behavioral of PID is

begin


end Behavioral;
