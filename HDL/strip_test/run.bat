@echo off
iverilog -Wall -o out -y ./ strip_top_tb.v
vvp out
gtkwave out.gtkw
pause