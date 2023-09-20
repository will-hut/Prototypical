`default_nettype none

module hub75_mainfsm(
    input sys_clk,
    input display_clk,
    input rst,
    input fetchshift_busy,

    output fetchshift_start,
    
    output lat,
    output row_clk,
    output row_data,
    output blank
);

parameter ROWS = 64;

parameter SHOW_LEN = 128;

reg [15:0] delay_len;


// COUNTER INSTANTIATIONS =============================================================================================


wire[15:0] delay_cnt;
wire delay_cnt_en;
wire delay_cnt_rst;

counter #(.WIDTH(16)) delay_counter (
    .clk(sys_clk),
    .rst(delay_cnt_rst),
    .en(delay_cnt_en),

    .out(delay_cnt)
);

wire[2:0] bit_cnt;
wire bit_cnt_en;
wire bit_cnt_rst;

counter #(.WIDTH(3)) bit_counter (
    .clk(sys_clk),
    .rst(bit_cnt_rst),
    .en(bit_cnt_en),

    .out(bit_cnt)
);

wire [7:0] row_cnt;
wire row_cnt_en;
wire row_cnt_rst;

counter #(.WIDTH(8)) row_counter (
    .clk(sys_clk),
    .rst(row_cnt_rst),
    .en(row_cnt_en),

    .out(row_cnt)
);

reg [3:0] state;
reg [3:0] next_state;

// STATES =============================================================================================================

localparam
    IDLE            = 4'd0, // default state
    PREFETCH        = 4'd1, // trigger first data shift out
    PREFETCH_WAIT   = 4'd2, // wait for it to be done 
    PREFETCH_END    = 4'd3,  // end of prefetch (increment bit counter)

    FRAME_START     = 4'd4, // beginning of frame

        ROW_START       = 4'd5, // beginning of row

            ROW_DATA        = 4'd6, // write data bit to row shift register (or not)
            ROW_CLK         = 4'd7, // clock row shift register (maintain data bit)

            BIT_START       = 4'd8, // beginning of bit slice

                ROW_LATCH       = 4'd9, // latch row and also trigger next data fetch
                ROW_LATCH_DELAY = 4'd10, // wait for delay 
                ROW_WAIT        = 4'd11, // unblank and wait specified amount of time per bit

            BIT_END         = 4'd12, // end of bit slice

        ROW_END         = 4'd13, // end of row

    FRAME_END       = 4'd14 // end of frame
;

always @(posedge sys_clk) begin
    if(rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// STATE TRANSITIONS ==================================================================================================

always @(*) begin
    case (state)
        IDLE            : next_state = PREFETCH;
        PREFETCH        : next_state = PREFETCH_WAIT;
        PREFETCH_WAIT   : next_state = (!fetchshift_busy && display_clk) ? PREFETCH_END : PREFETCH_WAIT; // sit here until data shifted out
        PREFETCH_END    : next_state = FRAME_START;

        FRAME_START     : next_state = ROW_START;

            ROW_START       : next_state = ROW_DATA;

                ROW_DATA        : next_state = ROW_CLK;
                ROW_CLK         : next_state = BIT_START;

                BIT_START       : next_state = ROW_LATCH;

                    ROW_LATCH       : next_state = ROW_LATCH_DELAY;
                    ROW_LATCH_DELAY : next_state = ROW_WAIT;
                    ROW_WAIT        : next_state = (!fetchshift_busy && display_clk && (delay_cnt == delay_len)) ? BIT_END : ROW_WAIT;
                    // TODO: create bit depth logic that either keeps it in this state or moves to ROW_END depending on delay counter (and also busy for sanity check)
                    // also need to create delay counter target that changes based on current bit count
                    // look at old display controller case statement

                BIT_END         : next_state = (bit_cnt == 3'd7) ? ROW_END : BIT_START;

            ROW_END         : next_state = (row_cnt == (ROWS-1)) ? FRAME_END : ROW_START;

        FRAME_END       : next_state = FRAME_START;

        default         : next_state = IDLE;
    endcase
end

// BIT WAIT TABLE ========================================================================================================

always @(*) begin
    case(bit_cnt)
        8'd0:       delay_len <= SHOW_LEN * 128; // just compensate for the off-by-one here lol
        8'd1:       delay_len <= SHOW_LEN;
        8'd2:       delay_len <= SHOW_LEN * 2;
        8'd3:       delay_len <= SHOW_LEN * 4;
        8'd4:       delay_len <= SHOW_LEN * 8;
        8'd5:       delay_len <= SHOW_LEN * 16;
        8'd6:       delay_len <= SHOW_LEN * 32;
        8'd7:       delay_len <= SHOW_LEN * 64;
        default:    delay_len <= SHOW_LEN;
    endcase
end


// ASSIGNMENTS ========================================================================================================

assign lat = (state == ROW_LATCH);
assign row_clk = (state == ROW_CLK);
assign row_data = ( (state == ROW_DATA) || (state == ROW_CLK) ) && (row_cnt == 8'd1);
assign blank = !(state == ROW_WAIT);

assign fetchshift_start = (state == PREFETCH) || (state == ROW_LATCH);

assign delay_cnt_en = display_clk;
assign delay_cnt_rst = !(state == ROW_WAIT);

assign bit_cnt_en = (state == PREFETCH_END) || (state == BIT_END);
assign bit_cnt_rst = (state == PREFETCH_WAIT) || (state == ROW_END);

assign row_cnt_en = (state == ROW_END);
assign row_cnt_rst = !( (state == ROW_START) || (state == ROW_DATA)  || (state == ROW_CLK) || (state == BIT_START) || 
                        (state == ROW_LATCH) || (state == ROW_LATCH_DELAY) || (state == ROW_WAIT) || (state == BIT_END) || (state == ROW_END) );


endmodule

