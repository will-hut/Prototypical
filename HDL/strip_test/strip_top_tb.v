`timescale 10ns/100ps

module strip_top_tb(
);


//main inputs
reg clk;
reg full;

wire strip1;
wire strip2;
wire strip3;
wire strip4;

wire [79:0] strip_rdata;
wire [7:0] strip_raddr;
wire strip_re;


strips led_strips(
    .sys_clk(clk),
    .full_ftdi(full),

    .strip_rdata(strip_rdata),
    .strip_raddr(strip_raddr),
    .strip_re(strip_re),

    .strip1(strip1),
    .strip2(strip2),
    .strip3(strip3),
    .strip4(strip4)
);

dpram
#(
	.DATA_WIDTH(80),
	.ADDR_WIDTH(8),
	.OUTPUT_REG("FALSE"),
    .RAM_INIT_FILE("image.mem")
)
fb1
(
	.wdata(0),
	.waddr(0),
	.wclk(clk),
	.we(0),
    
    .rdata(strip_rdata),
	.raddr(strip_raddr),
	.rclk(clk),
	.re(strip_re)
);



initial begin
    // For iverilog
    $dumpfile("out.vcd");
    $dumpvars;

    //Initial values
    clk = 1'b0;
    full = 1'b0;

    #4 full = 1'b1;
    #7 full = 1'b0;

    #500000 $finish;
end

always #1 clk = ~clk;

endmodule