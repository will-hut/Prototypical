module hub75_fetchshift(
    input wire sys_clk,
    input wire rst,
    input wire start,

    input wire [2:0] bit_cnt,
    input wire [7:0] row_cnt,

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

reg [2:0] state;
reg [2:0] next_state;

parameter COLS = 127;

localparam
    IDLE            = 3'd0,
    SHIFT           = 3'd1,
    PULSE           = 3'd2
;

wire[6:0] col_cnt;
wire col_cnt_rst;
wire col_cnt_en;
wire clk_out_comb;

counter #(.WIDTH(7)) col_counter (
    .clk(sys_clk),
    .rst(col_cnt_rst),
    .en(col_cnt_en),

    .out(col_cnt)
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
        PULSE           : next_state = (col_cnt == COLS) ? IDLE : SHIFT;
        default         : next_state = IDLE;
    endcase
end

always @(posedge sys_clk) begin
    r1 <= (row_cnt) == 0;
    g1 <= (row_cnt) == 1;
    b1 <= (row_cnt) == 2;
    r2 <= (col_cnt) == 0;
    g2 <= (col_cnt) == 1;
    b2 <= (col_cnt) == 2;
    r3 <= 1'b1;
    g3 <= 1'b1;
    b3 <= 1'b1;
    r4 <= 1'b1;
    g4 <= 1'b1;
    b4 <= 1'b1;
end


assign busy = (state != IDLE);
assign col_cnt_rst = (state == IDLE);
assign col_cnt_en = (state == PULSE);
assign clk_out_comb = (state == PULSE);

always @(posedge sys_clk) begin
    clk_out <= clk_out_comb;
end

endmodule