@echo off
iverilog -Wall -o out -y ./ ftdi_top_tb.v
vvp out
gtkwave out.gtkw