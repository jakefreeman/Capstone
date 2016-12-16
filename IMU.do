vlib work 

################################################################################
## Source Files
################################################################################
vcom -reportprogress 300 -work work Balancing_Robot_VHDL.srcs/sources_1/new/IMU.vhd
vcom -reportprogress 300 -work work Balancing_Robot_VHDL.srcs/sources_1/new/clock_div.vhd
###############################################################################
# Testbench Files
###############################################################################
vcom -reportprogress 300 -work work Balancing_Robot_VHDL.srcs/sim_1/new/IMU_tb.vhd


vsim -t 1ps IMU_tb

radix hexadecimal

add wave IMU_tb/*
add wave IMU_tb/IMU_UT/*



run 1000us