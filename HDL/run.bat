@echo off
iverilog -Wall -o out -y ./ hub75_top_tb.v
vvp out
gtkwave out.gtkw
pause