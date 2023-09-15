`default_nettype none

module hub75_mainfsm(
    input sys_clk,
    input display_clk,
    input rst,
    input fetchshift_busy,

    output fetchshift_start
);


wire[7:0] delay_cnt;
wire delay_cnt_en;
wire delay_cnt_rst;

counter #(.WIDTH(8)) delay_counter (
    .clk(sys_clk),
    .rst(delay_cnt_rst),
    .en(delay_cnt_en),

    .out(delay_cnt)
);

wire[3:0] bit_cnt;
wire bit_cnt_en;
wire bit_cnt_rst;

counter #(.WIDTH(4)) bit_counter (
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

localparam
    IDLE            = 4'd0, // default state
    PREFETCH        = 4'd1, // trigger first data shift out
    PREFETCH_WAIT   = 4'd2, // wait for it to be done 

    FRAME_START     = 4'd3, // beginning of frame

        ROW_START       = 4'd4, // beginning of row

            ROW_DATA        = 4'd5, // write data bit to row shift register (or not)
            ROW_CLK         = 4'd6, // clock row shift register (maintain data bit)
            ROW_LATCH       = 4'd7, // latch row and also trigger next data fetch
            ROW_WAIT        = 4'd8, // unblank and wait specified amount of time per bit

        ROW_END         = 4'd9, // end of row

    FRAME_END       = 4'd10 // end of frame
;

parameter BITS = 8
parameter ROWS = 64



always @(posedge sys_clk) begin
    if(rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        IDLE            : next_state = PREFETCH;
        PREFETCH        : next_state = PREFETCH_WAIT;
        PREFETCH_WAIT   : next_state = (!fetchshift_busy && display_clk) ? FRAME_START : PREFETCH_WAIT // sit here until data shifted out

        FRAME_START     : next_state = ROW_START;

            ROW_START       : next_state = ROW_DATA;

                ROW_DATA        : next_state = ROW_CLK;
                ROW_CLK         : next_state = ROW_LATCH;
                ROW_LATCH       : next_state = ROW_WAIT;
                ROW_WAIT        : // TODO: create bit depth logic that either keeps it in this state or moves to ROW_END depending on delay counter (and also busy for sanity check)

            ROW_END         : // TODO: jump back to ROW_START or go to FRAME_END depending on row counter

        FRAME_END       : next_state = FRAME_START


        default         : next_state = IDLE;
    endcase
end

assign fetchshift_start = (state == FRAME_START);





endmodule

