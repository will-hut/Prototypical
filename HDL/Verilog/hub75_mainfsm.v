`timescale 10ns/100ps

module hub75_mainfsm(
    input wire sys_clk,
    input wire fetchshift_busy,

    output wire fetchshift_start,
    output wire [2:0] bit_out,
    output wire [5:0] row_out,
    
    output reg lat,         // PIN OUTPUT
    output reg row_clk,     // PIN OUTPUT
    output reg row_data,    // PIN OUTPUT
    output reg blank        // PIN OUTPUT
);

parameter ROWS = 31;
parameter BITS = 7;

parameter SHOW_LEN = 8;

reg [15:0] delay_len;


// COUNTER INSTANTIATIONS ============================================================================================

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

wire [5:0] row_cnt;
wire row_cnt_en;
wire row_cnt_rst;

counter #(.WIDTH(6)) row_counter (
    .clk(sys_clk),
    .rst(row_cnt_rst),
    .en(row_cnt_en),

    .out(row_cnt)
);

reg [4:0] state = IDLE;
reg [4:0] next_state;

// STATES ============================================================================================================

localparam
    IDLE                        = 5'd0,     // default state
    PRELOAD                     = 5'd1,     // trigger first data shift out
    PRELOAD_WAIT                = 5'd2,     // wait for initial data to be shifted out
    FRAME_BEGIN                 = 5'd3,     // start of frame (for bit counter reset)
        ROW_BEGIN               = 5'd4,     // start of row (y/2 rows due to 2 rows at a time)
            BIT_BEGIN           = 5'd5,    // start of bit
                ROWADDR_DATA1   = 5'd6,     // load row address data (1 if first row, 0 otherwise)
                ROWADDR_DATA2   = 5'd7,     // setup/hold delay
                ROWADDR_CLK1    = 5'd8,     // clock row address data
                ROWADDR_CLK2    = 5'd9,     // setup/hold delay
                ROWADDR_WAIT1   = 5'd10,
                ROWADDR_WAIT2   = 5'd11,

                ROWADDR_LAT1    = 5'd12,
                ROWADDR_LAT2    = 5'd13,
                ROWADDR_WAIT3   = 5'd14,

                SHOWLOAD_START  = 5'd15,    // trigger fetchshift to grab next row, show current row
                SHOWLOAD_WAIT   = 5'd16,    // wait until fetchshift done (TODO: also add in delay logic)
            BIT_INC             = 5'd17,    // increment bit counter
        ROW_INC                 = 5'd18     // increment row counter
;

// STATE MACHINE DEFINITION ==========================================================================================

always @(posedge sys_clk) begin
    state <= next_state;
end

// STATE TRANSITIONS =================================================================================================

always @(*) begin
    case (state)
        IDLE                            : next_state = PRELOAD;
        PRELOAD                         : next_state = PRELOAD_WAIT;
        PRELOAD_WAIT                    : next_state = fetchshift_busy ? PRELOAD_WAIT : BIT_INC; // wait for preload to finish
        FRAME_BEGIN                     : next_state = ROW_BEGIN;
            ROW_BEGIN                   : next_state = BIT_BEGIN; 
                BIT_BEGIN               : next_state = (bit_cnt == 1) ? ROWADDR_DATA1 : ROWADDR_LAT1; 
                    ROWADDR_DATA1       : next_state = ROWADDR_DATA2;
                    ROWADDR_DATA2       : next_state = ROWADDR_CLK1;
                    ROWADDR_CLK1        : next_state = ROWADDR_CLK2;
                    ROWADDR_CLK2        : next_state = ROWADDR_WAIT1;
                    ROWADDR_WAIT1       : next_state = ROWADDR_WAIT2;
                    ROWADDR_WAIT2       : next_state = ROWADDR_LAT1;

                    ROWADDR_LAT1        : next_state = ROWADDR_LAT2;
                    ROWADDR_LAT2        : next_state = ROWADDR_WAIT3;
                    ROWADDR_WAIT3       : next_state = SHOWLOAD_START;
    
                    SHOWLOAD_START      : next_state = SHOWLOAD_WAIT;
                    SHOWLOAD_WAIT       : next_state = (fetchshift_busy || show_wait) ? SHOWLOAD_WAIT : BIT_INC;
                BIT_INC                 : next_state = (bit_cnt == BITS) ? ROW_INC : BIT_BEGIN;
            ROW_INC                     : next_state = (row_cnt == ROWS) ? FRAME_BEGIN : ROW_BEGIN;
            
        default                         : next_state = IDLE;
    endcase
end

// BIT WAIT TABLE ====================================================================================================

always @(*) begin
    case(bit_cnt)
        8'd0:       delay_len <= SHOW_LEN * 128;
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

wire show_wait = delay_cnt < delay_len;


// ASSIGNMENTS ========================================================================================================

// these externalize the counters to allow other modules to know 
// where in the sequence it is
assign bit_out = bit_cnt;
assign row_out = row_cnt;

// these are the direct combinational signals derived from the state that need 
// to be sent to the panel. they get registered for stability
wire lat_comb = (state == ROWADDR_LAT1) || (state == ROWADDR_LAT2);
wire row_clk_comb = (state == ROWADDR_CLK1) || (state == ROWADDR_CLK2);
wire row_data_comb = ((state == ROWADDR_DATA1) || (state == ROWADDR_DATA2) || (state == ROWADDR_CLK1) || (state == ROWADDR_CLK2)) 
                        && (row_cnt == 0);

wire blank_comb = !(state == SHOWLOAD_WAIT) || !(show_wait);

// this triggers the external fetchshift fsm
assign fetchshift_start = (state == PRELOAD) || (state == SHOWLOAD_START);

// these synchronize the counters
assign delay_cnt_en = (state == SHOWLOAD_WAIT);
assign delay_cnt_rst = (state == SHOWLOAD_START);

assign bit_cnt_en = (state == BIT_INC);
assign bit_cnt_rst = (state == ROW_BEGIN) || (state == IDLE);

assign row_cnt_en = (state == ROW_INC);
assign row_cnt_rst = (state == FRAME_BEGIN)  || (state == IDLE);

// EXTERNAL SYNCHRONIZERS ==============================================================================================

always @(posedge sys_clk) begin
    row_clk <= row_clk_comb;
    row_data <= row_data_comb;
    lat <= lat_comb;
    blank <= blank_comb;
end

endmodule

