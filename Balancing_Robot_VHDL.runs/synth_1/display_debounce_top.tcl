# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
debug::add_scope template.lib 1
set_msg_config -id {Common-41} -limit 4294967295
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.cache/wt [current_project]
set_property parent.project_path C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/IMU.vhd
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/ultrasonic.vhd
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/seven_seg.vhd
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/debounce.vhd
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/unsigned_to_bcd.vhd
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/display_debounce_top.vhd
  C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/sources_1/new/display_counter.vhd
}
read_xdc C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/display_debounce_top/new/display_debouce_const.xdc
set_property used_in_implementation false [get_files C:/Users/fvjak.LAPTOP-EVC94IFD/Dropbox/Capstsone/Balancing_Robot_VHDL/Balancing_Robot_VHDL.srcs/display_debounce_top/new/display_debouce_const.xdc]

synth_design -top display_debounce_top -part xc7a100tcsg324-1
write_checkpoint -noxdef display_debounce_top.dcp
catch { report_utilization -file display_debounce_top_utilization_synth.rpt -pb display_debounce_top_utilization_synth.pb }
