module hub75_fetchshift(
    input wire sys_clk,
    input wire rst,
    input wire start,

    input wire [2:0] bit_cnt,
    input wire [5:0] row_cnt,


    input wire [19:0] fb_rdata,
    output wire [13:0] fb_raddr,
    output wire fb_re,

    output reg r1,          // R for top row scan
    output reg g1,          // G for top row scan
    output reg b1,          // B for top row scan
    output reg r2,          // R for bottom row scan
    output reg g2,          // G for bottom row scan
    output reg b2,          // B for bottom row scan
    output reg r3,          // R for top row scan (2nd panel)
    output reg g3,          // G for top row scan (2nd panel)
    output reg b3,          // B for top row scan (2nd panel)
    output reg r4,          // R for bottom row scan (2nd panel)
    output reg g4,          // G for bottom row scan (2nd panel)
    output reg b4,          // B for bottom row scan (2nd panel)
    output reg clk_out,     // Panel clock out (PIN OUTPUT)
    output wire busy
);

reg [3:0] state;
reg [3:0] next_state;

parameter COLS = 127;

// COLUMN FETCH COUNTER =======================================================================
// this counts up to (NUM_COLS*4) to grab the 4 r,g,b signals 
// that need to be sent per panel clock 

wire[8:0] col_fetch_cnt;
wire col_fetch_cnt_rst;
wire col_fetch_cnt_en;

counter #(.WIDTH(9)) col_fetch_counter (
    .clk(sys_clk),
    .rst(col_fetch_cnt_rst),
    .en(col_fetch_cnt_en),

    .out(col_fetch_cnt)
);

// FRAMEBUFFER ACCESS =======================================================================
// these are the signals directly involved in the reading from the framebuffer.

assign fb_re = (state == FETCH_READ) || (state == FETCH_READ2) || (state == FETCH_READ3) || (state == FETCH_READ4);
assign fb_raddr = {row_cnt, col_fetch_cnt};
wire [23:0] packed_rgb = {red_out, green_out, blue_out};

// GAMMA CORRECTOR ======================================================================
// this is fully combinational and corrects the gamma on the 
// incoming 20bpp (7-7-6) color and turns it 24bpp color 

wire [7:0] red_out;
wire [7:0] green_out;
wire [7:0] blue_out;


gamma_correction gc(
	.red_in(fb_rdata[19:13]),
	.green_in(fb_rdata[12:6]),
	.blue_in(fb_rdata[5:0]),
	.red_out(red_out),
	.green_out(green_out),
	.blue_out(blue_out)
);

assign col_fetch_cnt_rst = (state == IDLE);
assign col_fetch_cnt_en = (state == FETCH_READ) || (state == FETCH_READ2) || (state == FETCH_READ3) || (state == FETCH_READ4);

// SHIFT REGISTER ===========================================================================
// this packs 4 24-bit pixels into a 96-bit value to be sent to the line buffer.

wire shiftreg_en;
reg [95:0] shiftreg_out;

always @(posedge sys_clk) begin
    if(shiftreg_en) begin
        shiftreg_out <= {shiftreg_out[71:0], packed_rgb};
    end
end

assign shiftreg_en = (state == FETCH_READ2) || (state == FETCH_READ3) || (state == FETCH_READ4) || (state == FETCH_READ5);

// LINE BUFFER WRITE COUNTER =======================================================================
// this counts up to (NUM_COLS*4) to grab the 4 r,g,b signals 
// that need to be sent per panel clock 

wire[6:0] lb_write_cnt;
wire lb_write_cnt_rst;
wire lb_write_cnt_en;

counter #(.WIDTH(7)) lb_write_counter (
    .clk(sys_clk),
    .rst(lb_write_cnt_rst),
    .en(lb_write_cnt_en),

    .out(lb_write_cnt)
);

assign lb_write_cnt_rst = (state == IDLE);
assign lb_write_cnt_en = (state == FETCH_READ7);


// COLUMN OUT COUNTER =======================================================================
// this counts up to NUM_COLS and manages the data being sent out to the panel
wire[6:0] col_cnt;
wire col_cnt_rst;
wire col_cnt_en;

counter #(.WIDTH(7)) col_counter (
    .clk(sys_clk),
    .rst(col_cnt_rst),
    .en(col_cnt_en),

    .out(col_cnt)
);

assign col_cnt_rst = (state == IDLE);
assign col_cnt_en = (state == PULSE);


// LINE BUFFER ==============================================================================
// stores one complete line

wire [95:0] lb_rdata;
wire lb_we = (state == FETCH_READ6);
wire lb_re = (state == OUT_BEGIN) || (state == SHIFT) || (state == PULSE);

dpram
#(
	.DATA_WIDTH(96),
	.ADDR_WIDTH(7),
	.OUTPUT_REG("FALSE")
)
line_buffer
(
	.wdata(shiftreg_out),
	.waddr(lb_write_cnt),
	.wclk(sys_clk),
	.we(lb_we),
    
    .rdata(lb_rdata),
	.raddr(col_cnt),
	.rclk(sys_clk),
	.re(lb_re)
);

wire [7:0] r1_byte = lb_rdata[7:0];
wire [7:0] g1_byte = lb_rdata[15:8];
wire [7:0] b1_byte = lb_rdata[23:16];
wire [7:0] r2_byte = lb_rdata[31:24];
wire [7:0] g2_byte = lb_rdata[39:32];
wire [7:0] b2_byte = lb_rdata[47:40];
wire [7:0] r3_byte = lb_rdata[55:48];
wire [7:0] g3_byte = lb_rdata[63:56];
wire [7:0] b3_byte = lb_rdata[71:64];
wire [7:0] r4_byte = lb_rdata[79:72];
wire [7:0] g4_byte = lb_rdata[87:80];
wire [7:0] b4_byte = lb_rdata[95:88];

// MAIN STATE MACHINE ===================================================================

localparam
    IDLE            = 4'd0,
    START           = 4'd1, // branches to either fetch (bit == 0) or just shift
        FETCH_START1    = 4'd2, // start read
        FETCH_START2    = 4'd3, // start read 2
        FETCH_READ      = 4'd4,
        FETCH_READ2     = 4'd5,
        FETCH_READ3     = 4'd6,
        FETCH_READ4     = 4'd7,
        FETCH_READ5     = 4'd8,
        FETCH_READ6     = 4'd9, // wen should go high here
        FETCH_READ7     = 4'd10, 

        OUT_BEGIN       = 4'd11,
        SHIFT           = 4'd12, // shift out data
        PULSE           = 4'd13  // increment counter and clock
;

always @(posedge sys_clk) begin
    if(rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


always @(*) begin
    case (state)
        IDLE            : next_state = start ? START : IDLE;
        START           : next_state = (bit_cnt == 0) ? FETCH_START1 : OUT_BEGIN;
            FETCH_START1    : next_state = FETCH_START2;
            FETCH_START2    : next_state = FETCH_READ;
            FETCH_READ      : next_state = FETCH_READ2;
            FETCH_READ2     : next_state = FETCH_READ3;
            FETCH_READ3     : next_state = FETCH_READ4;
            FETCH_READ4     : next_state = FETCH_READ5;
            FETCH_READ5     : next_state = FETCH_READ6;
            FETCH_READ6     : next_state = FETCH_READ7;
            FETCH_READ7     : next_state = (col_fetch_cnt == 9'd0) ? OUT_BEGIN : FETCH_READ; // extra increment wraps back around to 0

            OUT_BEGIN       : next_state = SHIFT;
            SHIFT           : next_state = PULSE;
            PULSE           : next_state = (col_cnt == COLS) ? IDLE : SHIFT;
        default         : next_state = IDLE;
    endcase
end

assign busy = (state != IDLE);

// EXTERNAL SIGNALS =================================================================

wire clk_out_comb = (state == PULSE);

always @(posedge sys_clk) begin
    r1 <= b4_byte[bit_cnt];
    g1 <= g4_byte[bit_cnt];
    b1 <= r4_byte[bit_cnt];
    r2 <= b3_byte[bit_cnt];
    g2 <= g3_byte[bit_cnt];
    b2 <= r3_byte[bit_cnt];

    r3 <= b2_byte[bit_cnt];
    g3 <= g2_byte[bit_cnt];
    b3 <= r2_byte[bit_cnt];
    r4 <= b1_byte[bit_cnt];
    g4 <= g1_byte[bit_cnt];
    b4 <= r1_byte[bit_cnt];

    clk_out <= clk_out_comb;
end

endmodule