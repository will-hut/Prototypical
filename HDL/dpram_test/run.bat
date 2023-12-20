@echo off
iverilog -Wall -o out simple_dual_port_ram.v simple_dual_port_ram_tb.v
vvp out
gtkwave out.gtkw