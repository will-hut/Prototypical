`timescale 10ns/100ps

module strips(
    input sys_clk,
    input full_ftdi,

	input [79:0] strip_rdata,
	output [6:0] strip_raddr,
	output strip_re,

    output reg strip1,
    output reg strip2,
    output reg strip3,
    output reg strip4

);

reg [2:0] state = IDLE;
reg [2:0] next_state;

// FULL FROM FTDI (SIGNAL 60) => (SIGNAL 50)
reg full1, full;
always @(posedge sys_clk) begin 
	full1 <= full_ftdi;
	full <= full1;
end

// COMBINATIONAL GAMMA CORRECTION ================================================================================
// this takes the read data and converts it to the 24-bit 
// gamma corrected color needed to shift out.

wire [19:0] strip1_in = strip_rdata[79:60];
wire [19:0] strip2_in = strip_rdata[59:40];
wire [19:0] strip3_in = strip_rdata[39:20];
wire [19:0] strip4_in = strip_rdata[19:0];

wire [7:0] strip1_red;
wire [7:0] strip1_green;
wire [7:0] strip1_blue;

wire [7:0] strip2_red;
wire [7:0] strip2_green;
wire [7:0] strip2_blue;

wire [7:0] strip3_red;
wire [7:0] strip3_green;
wire [7:0] strip3_blue;

wire [7:0] strip4_red;
wire [7:0] strip4_green;
wire [7:0] strip4_blue;

wire [23:0] strip1_out = {strip1_green, strip1_red, strip1_blue};
wire [23:0] strip2_out = {strip2_green, strip2_red, strip2_blue};
wire [23:0] strip3_out = {strip3_green, strip3_red, strip3_blue};
wire [23:0] strip4_out = {strip4_green, strip4_red, strip4_blue};



gamma_correction gc1(
	.red_in(strip1_in[19:13]),
	.green_in(strip1_in[12:6]),
	.blue_in(strip1_in[5:0]),
	.red_out(strip1_red),
	.green_out(strip1_green),
	.blue_out(strip1_blue)
);

gamma_correction gc2(
	.red_in(strip2_in[19:13]),
	.green_in(strip2_in[12:6]),
	.blue_in(strip2_in[5:0]),
	.red_out(strip2_red),
	.green_out(strip2_green),
	.blue_out(strip2_blue)
);

gamma_correction gc3(
	.red_in(strip3_in[19:13]),
	.green_in(strip3_in[12:6]),
	.blue_in(strip3_in[5:0]),
	.red_out(strip3_red),
	.green_out(strip3_green),
	.blue_out(strip3_blue)
);

gamma_correction gc4(
	.red_in(strip4_in[19:13]),
	.green_in(strip4_in[12:6]),
	.blue_in(strip4_in[5:0]),
	.red_out(strip4_red),
	.green_out(strip4_green),
	.blue_out(strip4_blue)
);

// SHIFT REGISTER ============================================================================================
// this serializes the 24-bit color info for each strip.

wire shift_latch;
wire shift_en;

reg [23:0] strip1_shift;
reg [23:0] strip2_shift;
reg [23:0] strip3_shift;
reg [23:0] strip4_shift;

wire strip1_shiftout = strip1_shift[23];
wire strip2_shiftout = strip2_shift[23];
wire strip3_shiftout = strip3_shift[23];
wire strip4_shiftout = strip4_shift[23];

always @(posedge sys_clk) begin
    if(shift_latch) begin
        strip1_shift <= strip1_out;
        strip2_shift <= strip2_out;
        strip3_shift <= strip3_out;
        strip4_shift <= strip4_out;
        
    end else if(shift_en) begin
        strip1_shift <= {strip1_shift[22:0], 1'b0};
        strip2_shift <= {strip2_shift[22:0], 1'b0};
        strip3_shift <= {strip3_shift[22:0], 1'b0};
        strip4_shift <= {strip4_shift[22:0], 1'b0};
    end
end

assign shift_latch = (state == LATCH);
assign shift_en = (state == LOOP);

// LED COUNTER ===================================================================================================

wire[6:0] led_cnt;
wire led_cnt_rst;
wire led_cnt_en;

wire led_end = (led_cnt == 7'd127);

counter #(.WIDTH(7)) led_counter (
    .clk(sys_clk),
    .rst(led_cnt_rst),
    .en(led_cnt_en),

    .out(led_cnt)
);

assign strip_raddr = led_cnt;
assign strip_re = (state == READ);

assign led_cnt_rst = (state == IDLE);
assign led_cnt_en = (state == LOOP) && (bit_end);

// BIT COUNTER ===================================================================================================

wire[4:0] bit_cnt;
wire bit_cnt_rst;
wire bit_cnt_en;

wire bit_end = (bit_cnt == 5'd23);

counter #(.WIDTH(5)) bit_counter (
    .clk(sys_clk),
    .rst(bit_cnt_rst),
    .en(bit_cnt_en),

    .out(bit_cnt)
);

assign bit_cnt_rst = (state == IDLE) || ((state == LOOP) && (bit_end));
assign bit_cnt_en = (state == LOOP);

// WAIT COUNTER ===================================================================================================

wire[11:0] wait_cnt;
wire wait_cnt_rst;
wire wait_cnt_en;

counter #(.WIDTH(12)) wait_counter (
    .clk(sys_clk),
    .rst(wait_cnt_rst),
    .en(wait_cnt_en),

    .out(wait_cnt)
);

assign wait_cnt_rst = (state == IDLE) || (state == LOOP);
assign wait_cnt_en = (state == WAIT0) || (state == WAIT1) || (state == WAITOFF) || (state == SHOW);

// MAIN STATE MACHINE =============================================================================================


localparam 
    IDLE = 3'd0,
    READ = 3'd1,
    LATCH = 3'd2,
            WAIT0 = 3'd3,   // both 0/1 bits high here
            WAIT1 = 3'd4,   // 1 bits high here
            WAITOFF = 3'd5, // no bits high here
            LOOP = 3'd6,    // increment counters
    
    SHOW = 3'd7
;

always @(posedge sys_clk) begin
    state <= next_state;
end

always @(*) begin
    case (state)
        IDLE            : next_state = full ? READ : IDLE;
        READ            : next_state = LATCH;
        LATCH           : next_state = WAIT0;
            WAIT0       : next_state = (wait_cnt == 12'd10) ? WAIT1 : WAIT0;     // 200ns  length for 0 bit
            WAIT1       : next_state = (wait_cnt == 12'd30) ? WAITOFF : WAIT1;   // 600ns  length for 1 bit
            WAITOFF     : next_state = (wait_cnt == 12'd55) ? LOOP : WAITOFF;    // 1100ns length in total
            LOOP        : next_state = bit_end ? (led_end ? SHOW : READ) : WAIT0;

        SHOW            : next_state = (wait_cnt == 12'd2750) ? IDLE : SHOW;

        default         : next_state = IDLE;
    endcase
end



// REGISTERED OUTPUTS =============================================================================================

wire strip1_comb = (state == WAIT0) || ((state == WAIT1) && strip1_shiftout == 1'b1);
wire strip2_comb = (state == WAIT0) || ((state == WAIT1) && strip2_shiftout == 1'b1);
wire strip3_comb = (state == WAIT0) || ((state == WAIT1) && strip3_shiftout == 1'b1);
wire strip4_comb = (state == WAIT0) || ((state == WAIT1) && strip4_shiftout == 1'b1);


always @(posedge sys_clk) begin
    strip1 <= strip1_comb;
    strip2 <= strip2_comb;
    strip3 <= strip3_comb;
    strip4 <= strip4_comb;
end

endmodule