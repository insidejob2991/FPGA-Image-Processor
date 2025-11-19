# ******************************************************************
# FINAL CONSTRAINTS for Basys 3 Image Processing Project
# ******************************************************************

# --- CLOCK SIGNAL ---
# Master Clock (100 MHz on Basys 3)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin [get_ports clk]

# --- RESET SIGNAL ---
# Center Pushbutton (BTNC) for Reset
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# --- UART TX PIN ---
# Pmod JA Pin 1 (Used for serial data output to PC)
set_property PACKAGE_PIN V12 [get_ports tx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports tx_pin]

# --- LED OUTPUTS (8-bit led_output[7:0]) ---
# These pins are configured to display the output of your processing pipeline.
set_property PACKAGE_PIN U17 [get_ports {led_output[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[7]}]

set_property PACKAGE_PIN V17 [get_ports {led_output[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[6]}]

set_property PACKAGE_PIN V16 [get_ports {led_output[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[5]}]

set_property PACKAGE_PIN W16 [get_ports {led_output[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[4]}]

set_property PACKAGE_PIN W19 [get_ports {led_output[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[3]}]

set_property PACKAGE_PIN U19 [get_ports {led_output[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[2]}]

set_property PACKAGE_PIN W18 [get_ports {led_output[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[1]}]

set_property PACKAGE_PIN U14 [get_ports {led_output[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_output[0]}]