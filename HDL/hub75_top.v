`default_nettype none

module hub75_top(
    input clk,          // system clock
    input rst,

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

    output row_clk,     // row select shift register clock (A)
    output row_data,    // row select shift register data (C)
    output clk_out, // main row clock
    output lat,         // row latch
    output blank

);

reg display_clk;

assign row_clk = 1'b0;
assign row_data = 1'b0;
assign lat = 1'b0;
assign blank = 1'b0;


// create half-speed clock from sysclock for display timing
always @(negedge clk) begin
    if(rst) begin
        display_clk <= 1'b0;
    end else begin
        display_clk <= ~display_clk;
    end
end

wire fetchshift_start;
wire fetchshift_busy;

// handles the main transmission
hub75_mainfsm mainfsm(
    .sys_clk(clk),
    .display_clk(display_clk),
    .rst(rst),
    .fetchshift_busy(fetchshift_busy),

    .fetchshift_start(fetchshift_start)
);

// handles fetching the data and shifting it out to the panels
hub75_fetchshift fetchshift(
    .sys_clk(clk),
    .display_clk(display_clk),
    .rst(rst),
    .start(fetchshift_start),

    .r1(r1),
    .g1(g1),
    .b1(b1),
    .r2(r2),
    .g2(g2),
    .b2(b2),
    .r3(r3),
    .g3(g3),
    .b3(b3),
    .r4(r4),
    .g4(g4),
    .b4(b4),
    .clk_out(clk_out),
    .busy(fetchshift_busy)
);



endmodule