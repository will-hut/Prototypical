@echo off
iverilog -Wall -o out counter.v hub75_top.v hub75_top_tb.v hub75_mainfsm.v hub75_fetchshift.v
vvp out
gtkwave out.gtkw