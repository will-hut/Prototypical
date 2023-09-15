`default_nettype none

module hub75_fetchshift(
    input sys_clk,
    input display_clk,
    input rst,
    input start,

    output r1,          // R for top row scan
    output g1,          // G for top row scan
    output b1,          // B for top row scan
    output r2,          // R for bottom row scan
    output g2,          // G for bottom row scan
    output b2,          // B for bottom row scan
    output r3,          // R for top row scan (2nd panel)
    output g3,          // G for top row scan (2nd panel)
    output b3,          // B for top row scan (2nd panel)
    output r4,          // R for bottom row scan (2nd panel)
    output g4,          // G for bottom row scan (2nd panel)
    output b4,          // B for bottom row scan (2nd panel)
    output reg clk_out, // Panel clock out
    output busy
);

reg [2:0] state;
reg [2:0] next_state;

parameter
    IDLE            = 3'd0,
    SHIFT           = 3'd1
;

wire[6:0] c0_out;
wire c0_rst;
wire c0_en;

counter #(.WIDTH(7)) c0 (
    .clk(sys_clk),
    .rst(c0_rst),
    .en(c0_en),

    .out(c0_out)
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
        SHIFT           : next_state = (c0_out == 7'b1111111) ? IDLE : SHIFT; // ~0 is the max value possible for N bits
        default         : next_state = IDLE;
    endcase
end

always @(posedge sys_clk) begin
    if(state != SHIFT) begin
        clk_out <= 1'b0;
    end else begin
        clk_out <= ~clk_out;
    end
end

assign r1 = 1'b0;
assign g1 = 1'b0;
assign b1 = 1'b0;
assign r2 = 1'b0;
assign g2 = 1'b0;
assign b2 = 1'b0;
assign r3 = 1'b0;
assign g3 = 1'b0;
assign b3 = 1'b0;
assign r4 = 1'b0;
assign g4 = 1'b0;
assign b4 = 1'b0;

assign busy = (state == SHIFT);
assign c0_rst = (state == IDLE);
assign c0_en = !display_clk;

endmodule