# input clock
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN F22 [get_ports clk]
create_clock -period 50.000 -name clk -waveform {0.000 25.000} [get_ports clk]
