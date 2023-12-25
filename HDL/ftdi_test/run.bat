@echo off
iverilog -Wall -o out ftdi_top.v ftdi_top_tb.v
vvp out
gtkwave out.gtkw
pause