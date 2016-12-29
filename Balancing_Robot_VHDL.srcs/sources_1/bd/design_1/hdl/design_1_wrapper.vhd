--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
--Date        : Mon Dec 26 23:28:25 2016
--Host        : LAPTOP-EVC94IFD running 64-bit major release  (build 9200)
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  end component design_1;
begin
design_1_i: component design_1
     port map (
      
    );
end STRUCTURE;
