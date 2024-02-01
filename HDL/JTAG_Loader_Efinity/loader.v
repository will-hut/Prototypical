module loader (
input rstn,
input clkin,
input miso,
output sclk,
output nss,
output mosi,
input jtag_inst1_CAPTURE,
input jtag_inst1_DRCK,
input jtag_inst1_RESET,
input jtag_inst1_RUNTEST,
input jtag_inst1_SEL,
input jtag_inst1_SHIFT,
input jtag_inst1_TCK,
input jtag_inst1_TDI,
input jtag_inst1_TMS,
input jtag_inst1_UPDATE,
output jtag_inst1_TDO,
output wp_n,
output hold_n,
output osc_inst1_ENA
);

jtag2spi u_jtag2spi(
.rstn ( rstn ),
.clkin ( clkin ),
.miso ( miso ),
.sclk ( sclk ),
.nss ( nss ),
.mosi ( mosi ),
.jtag_inst1_CAPTURE ( jtag_inst1_CAPTURE ),
.jtag_inst1_DRCK ( jtag_inst1_DRCK ),
.jtag_inst1_RESET ( jtag_inst1_RESET ),
.jtag_inst1_RUNTEST ( jtag_inst1_RUNTEST ),
.jtag_inst1_SEL ( jtag_inst1_SEL ),
.jtag_inst1_SHIFT ( jtag_inst1_SHIFT ),
.jtag_inst1_TCK ( jtag_inst1_TCK ),
.jtag_inst1_TDI ( jtag_inst1_TDI ),
.jtag_inst1_TMS ( jtag_inst1_TMS ),
.jtag_inst1_UPDATE ( jtag_inst1_UPDATE ),
.jtag_inst1_TDO ( jtag_inst1_TDO ),
.wp_n ( wp_n ),
.hold_n ( hold_n ),
.osc_inst1_ENA ( osc_inst1_ENA )
);

endmodule
