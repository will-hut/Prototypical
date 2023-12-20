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


wire [19:0] rdata1;
wire [19:0] rdata2;

assign rdata = selection ? rdata1 : rdata2;

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
	.we(selection ? 0 : we),
    
    .rdata(rdata1),
	.raddr(raddr),
	.rclk(rclk),
	.re(selection ? re : 0)
);

dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(14),
	.OUTPUT_REG("FALSE"),
    .RAM_INIT_FILE("image2.mem")
)
fb2
(
	.wdata(wdata),
	.waddr(waddr),
	.wclk(wclk),
	.we(selection ? we : 0),
    
    .rdata(rdata2),
	.raddr(raddr),
	.rclk(rclk),
	.re(selection ? 0 : re)
);


endmodule