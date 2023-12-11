module hub75_fetchshift(
    input wire sys_clk,
    input wire rst,
    input wire start,

    input wire [2:0] bit,
    input wire [7:0] row,

    output wire r1,          // R for top row scan
    output wire g1,          // G for top row scan
    output wire b1,          // B for top row scan
    output wire r2,          // R for bottom row scan
    output wire g2,          // G for bottom row scan
    output wire b2,          // B for bottom row scan
    output wire r3,          // R for top row scan (2nd panel)
    output wire g3,          // G for top row scan (2nd panel)
    output wire b3,          // B for top row scan (2nd panel)
    output wire r4,          // R for bottom row scan (2nd panel)
    output wire g4,          // G for bottom row scan (2nd panel)
    output wire b4,          // B for bottom row scan (2nd panel)
    output reg clk_out,     // Panel clock out (PIN OUTPUT)
    output wire busy
);

reg [2:0] state;
reg [2:0] next_state;

parameter COLS = 31;

localparam
    IDLE            = 3'd0,
    SHIFT           = 3'd1,
    PULSE           = 3'd2
;

wire[6:0] col_cnt_out;
wire col_cnt_rst;
wire col_cnt_en;
wire clk_out_comb;

counter #(.WIDTH(7)) col_cnt (
    .clk(sys_clk),
    .rst(col_cnt_rst),
    .en(col_cnt_en),

    .out(col_cnt_out)
);


always @(posedge sys_clk) begin
    if(rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


always @(*) begin
    case (state)
        IDLE            : next_state = start ? SHIFT : IDLE;
        SHIFT           : next_state = PULSE;
        PULSE           : next_state = (col_cnt_out == COLS) ? IDLE : SHIFT; // ~0 is the max value possible for N bits
        default         : next_state = IDLE;
    endcase
end

assign r1 = 1'b1;
assign g1 = 1'b1;
assign b1 = 1'b1;
assign r2 = 1'b1;
assign g2 = 1'b1;
assign b2 = 1'b1;
assign r3 = 1'b1;
assign g3 = 1'b1;
assign b3 = 1'b1;
assign r4 = 1'b1;
assign g4 = 1'b1;
assign b4 = 1'b1;

assign busy = (state != IDLE);
assign col_cnt_rst = (state == IDLE);
assign col_cnt_en = (state == PULSE);
assign clk_out_comb = (state == SHIFT);

always @(posedge sys_clk) begin
    clk_out <= clk_out_comb;
end

endmodule