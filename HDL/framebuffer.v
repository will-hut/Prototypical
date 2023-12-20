module framebuffer(
    input [19:0] wdata,
    input [13:0] waddr,
    input wclk,
    input we,

    output [19:0] rdata,
    input [13:0] raddr,
    input rclk,
    input re,

    input selection
);



dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(14),
	.OUTPUT_REG("FALSE"),
    .RAM_INIT_FILE("image.mem")
)
fb1
(
	.wdata(wdata),
	.waddr(waddr),
	.wclk(wclk),
	.we(we),
    
    .rdata(rdata),
	.raddr(raddr),
	.rclk(rclk),
	.re(re)
);


endmodule