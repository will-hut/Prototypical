module hub75_top(
    input wire clk,          // system clock
    input wire rst,

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

    output wire row_clk,     // row select shift register clock (A)
    output wire row_data,    // row select shift register data (C)
    output wire clk_out,     // main row clock
    output wire lat,         // row latch
    output wire blank

);

reg rst_sync1, rst_sync;

always @(posedge clk) begin
    rst_sync1 <= rst;
    rst_sync <= !rst_sync1;
end

wire fetchshift_start;
wire fetchshift_busy;

wire[2:0] bit;
wire[5:0] row;

wire [19:0] fb_rdata;
wire [13:0] fb_raddr;
wire fb_re;


// the main framebuffer that is read/written to
framebuffer fb(
    .wdata(20'b0),
    .waddr(14'b0),
    .wclk(1'b0),
    .we(1'b0),

    .rdata(fb_rdata),
    .raddr(fb_raddr),
    .rclk(clk),
    .re(fb_re),

    .selection(1'b0)
);



// handles the main transmission
hub75_mainfsm mainfsm(
    .sys_clk(clk),
    .rst(rst_sync),
    .fetchshift_busy(fetchshift_busy),

    .fetchshift_start(fetchshift_start),
    .bit_out(bit),
    .row_out(row),

    .lat(lat),
    .row_clk(row_clk),
    .row_data(row_data),
    .blank(blank)
);

// handles fetching the data from the framebuffer, doing gamma correction, putting it in a
// line buffer, and shifting it out to the panels
hub75_fetchshift fetchshift(
    .sys_clk(clk),
    .rst(rst_sync),
    .start(fetchshift_start),

    .bit_cnt(bit),
    .row_cnt(row),

    .fb_rdata(fb_rdata),
    .fb_raddr(fb_raddr),
    .fb_re(fb_re),

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