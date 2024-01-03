`timescale 10ns/100ps

module framebuffer(
	input sys_clk,
	input clk_60,

    input [19:0] wdata,
    input [13:0] waddr,
    input we,

    output [19:0] rdata,
    input [13:0] raddr,
    input re,

	input frame_start, // SYS CLOCK DOMAIN
	input full_ftdi, //FTDI CLOCK DOMAIN
	output swapped_ftdi //FTDI CLOCK DOMAIN
);

// buffer swap
always @(posedge sys_clk) begin
	if(frame_start && full) begin
		selection <= ~selection;
	end
end


// CROSS DOMAIN (SIGNAL 60) => (SIGNAL 50)
reg full1, full;
always @(posedge sys_clk) begin 
	full1 <= full_ftdi;
	full <= full1;
end


// CROSS DOMAIN (LEVELCHANGE 50) => (FLAG 60)
reg sel_ftdi2, sel_ftdi1, sel_ftdi;
always @(posedge clk_60) begin 
	sel_ftdi2 <= selection;
	sel_ftdi1 <= sel_ftdi2;
	sel_ftdi <= sel_ftdi1;
end
assign swapped_ftdi = sel_ftdi ^ sel_ftdi1; // turn level change into flag


wire [19:0] rdata1;
wire [19:0] rdata2;

reg selection = 1'b0;
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
	.wclk(clk_60),
	.we(selection ? 1'b0 : we),
    
    .rdata(rdata1),
	.raddr(raddr),
	.rclk(sys_clk),
	.re(selection ? re : 1'b0)
);

dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(14),
	.OUTPUT_REG("FALSE"),
    .RAM_INIT_FILE("image.mem")
)
fb2
(
	.wdata(wdata),
	.waddr(waddr),
	.wclk(clk_60),
	.we(selection ? we : 1'b0),
    
    .rdata(rdata2),
	.raddr(raddr),
	.rclk(sys_clk),
	.re(selection ? 1'b0 : re)
);


endmodule