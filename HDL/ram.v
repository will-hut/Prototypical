`timescale 10ns/100ps

module ram(
	input sys_clk,
	input clk_60,

    input [19:0] ftdi_wdata,
    input [14:0] ftdi_waddr,
    input ftdi_we,

    output [19:0] fb_rdata,
    input [13:0] fb_raddr,
    input fb_re,

	output [79:0] strip_rdata,
	input [7:0] strip_raddr,
	input strip_re,

	input frame_start, // SYS CLOCK DOMAIN
	input full_ftdi, //FTDI CLOCK DOMAIN
	output swapped_ftdi //FTDI CLOCK DOMAIN
);

wire [19:0] fb_rdata1;
wire [19:0] fb_rdata2;

wire [19:0] strip_rdata1;
wire [19:0] strip_rdata2;
wire [19:0] strip_rdata3;
wire [19:0] strip_rdata4;

assign strip_rdata = {strip_rdata1, strip_rdata2, strip_rdata3, strip_rdata4};

reg selection = 1'b0;

// BUFFER SWAP LOGIC ===================================================================

always @(posedge sys_clk) begin
	if(frame_start && full) begin
		selection <= ~selection;
	end
end


// FULL FROM FTDI (SIGNAL 60) => (SIGNAL 50)
reg full1, full;
always @(posedge sys_clk) begin 
	full1 <= full_ftdi;
	full <= full1;
end


// SWAPPED TO FTDI (LEVELCHANGE 50) => (FLAG 60)
reg sel_ftdi2, sel_ftdi1, sel_ftdi;
always @(posedge clk_60) begin 
	sel_ftdi2 <= selection;
	sel_ftdi1 <= sel_ftdi2;
	sel_ftdi <= sel_ftdi1;
end

assign swapped_ftdi = sel_ftdi ^ sel_ftdi1; // turn level change into flag


// FRAME DOUBLE BUFFER =================================================================

wire panel_we = !ftdi_waddr[14] && ftdi_we;
assign fb_rdata = selection ? fb_rdata1 : fb_rdata2;


dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(14),
	.OUTPUT_REG("FALSE"),
    .RAM_INIT_FILE("image.mem")
)
fb1
(
	.wdata(ftdi_wdata),
	.waddr(ftdi_waddr[13:0]),
	.wclk(clk_60),
	.we(!selection && panel_we),
    
    .rdata(fb_rdata1),
	.raddr(fb_raddr),
	.rclk(sys_clk),
	.re(selection ? fb_re : 1'b0)
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
	.wdata(ftdi_wdata),
	.waddr(ftdi_waddr[13:0]),
	.wclk(clk_60),
	.we(selection && panel_we),
    
    .rdata(fb_rdata2),
	.raddr(fb_raddr),
	.rclk(sys_clk),
	.re(!selection ? fb_re : 1'b0)
);

// LED STRIP BUFFERS ===================================================================

wire [1:0] strip_select = ftdi_waddr[8:7];
wire strip_we = ftdi_waddr[14] && ftdi_we;

dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(7),
	.OUTPUT_REG("FALSE")
)
strip1
(
	.wdata(ftdi_wdata),
	.waddr(ftdi_waddr[6:0]),
	.wclk(clk_60),
	.we((strip_select == 2'd0) && strip_we),
    
    .rdata(strip_rdata1),
	.raddr(strip_raddr),
	.rclk(sys_clk),
	.re(strip_re)
);

dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(7),
	.OUTPUT_REG("FALSE")
)
strip2
(
	.wdata(ftdi_wdata),
	.waddr(ftdi_waddr[6:0]),
	.wclk(clk_60),
	.we((strip_select == 2'd1) && strip_we),
    
    .rdata(strip_rdata2),
	.raddr(strip_raddr),
	.rclk(sys_clk),
	.re(strip_re)
);

dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(7),
	.OUTPUT_REG("FALSE")
)
strip3
(
	.wdata(ftdi_wdata),
	.waddr(ftdi_waddr[6:0]),
	.wclk(clk_60),
	.we((strip_select == 2'd2) && strip_we),
    
    .rdata(strip_rdata3),
	.raddr(strip_raddr),
	.rclk(sys_clk),
	.re(strip_re)
);

dpram
#(
	.DATA_WIDTH(20),
	.ADDR_WIDTH(7),
	.OUTPUT_REG("FALSE")
)
strip4
(
	.wdata(ftdi_wdata),
	.waddr(ftdi_waddr[6:0]),
	.wclk(clk_60),
	.we((strip_select == 2'd3) && strip_we),
    
    .rdata(strip_rdata4),
	.raddr(strip_raddr),
	.rclk(sys_clk),
	.re(strip_re)
);


endmodule