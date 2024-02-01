# Clock Input Constraints
#########################
create_clock -period 16.66 [get_ports {clk_60}]

# PLL Constraints
#################
create_clock -period 20.0000 clk
create_clock -period 83.3333 out_12mhz

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_rxf_n}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_rxf_n}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_txe_n}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_txe_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {b1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {b1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {b2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {b2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {b3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {b3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {b4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {b4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {blank}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {blank}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {clk_out}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {clk_out}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_oe_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_oe_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_rd_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_rd_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_wr_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_wr_n}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {g1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {g1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {g2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {g2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {g3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {g3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {g4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {g4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {lat}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {lat}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {r1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {r1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {r2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {r2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {r3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {r3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {r4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {r4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {row_clk}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {row_clk}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {row_data}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {row_data}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {strip1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {strip1}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {strip2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {strip2}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {strip3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {strip3}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {strip4}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {strip4}]

# LVDS RX GPIO Constraints
############################
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[0]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[0]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[1]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[1]}]

# LVDS Rx Constraints
####################

# LVDS TX GPIO Constraints
############################
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[2]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[2]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[3]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[3]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[4]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[4]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[5]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[5]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[6]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[6]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {ftdi_data[7]}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {ftdi_data[7]}]

# LVDS Tx Constraints
####################

# Clock Latency Constraints
############################
# set_clock_latency -source -setup <board_max + 1.815> [get_ports {clk}]
# set_clock_latency -source -hold <board_min + 0.698> [get_ports {clk}]
# set_clock_latency -source -setup <board_max + 1.815> [get_ports {out_12mhz}]
# set_clock_latency -source -hold <board_min + 0.698> [get_ports {out_12mhz}]
# set_clock_latency -source -setup <board_max + 1.657> [get_ports {clk_60}]
# set_clock_latency -source -hold <board_min + 0.637> [get_ports {clk_60}]
