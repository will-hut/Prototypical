`timescale 10ns/100ps

module hub75_top(
    input wire clk,          // system clock
    input wire clk_60,       // 60MHz clock from FTDI

    input wire [7:0] ftdi_data,     // input data bus from FTDI
    input wire ftdi_rxf_n,          // when high, cant read (no data available)
    input wire ftdi_txe_n,          // when high, cant write (fifo full)
    output wire ftdi_rd_n,          // set low to begin reading data
    output wire ftdi_wr_n,          // set low to begin writing data
    output wire ftdi_oe_n,          // set low to drive data on bus (one clock period before rd_n low)



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
    output wire blank,       // row blanking signal

    output wire debug
);

wire fetchshift_start;
wire fetchshift_busy;

wire frame_start;

wire[2:0] bit;
wire[5:0] row;

wire [19:0] fb_rdata;
wire [13:0] fb_raddr;
wire fb_re;

wire [19:0] fb_wdata;
wire [13:0] fb_waddr;
wire fb_we;


// handles the FTDI USB input as well as switching between framebuffers
wire full_ftdi;
wire swapped_ftdi;
ftdi ftdi_in(
    .clk_60(clk_60),
    .data_in(ftdi_data),
    .rxf_n(ftdi_rxf_n),
    .txe_n(ftdi_txe_n),
    .rd_n(ftdi_rd_n),
    .wr_n(ftdi_wr_n),
    .oe_n(ftdi_oe_n),

    .fb_wdata(fb_wdata),
    .fb_waddr(fb_waddr),
    .fb_we(fb_we),

    .full(full_ftdi),
    .swapped(swapped_ftdi)
);


// the main framebuffer that is read/written to
framebuffer fb(
    .sys_clk(clk),
    .clk_60(clk_60),

    .wdata(fb_wdata),
    .waddr(fb_waddr),
    .we(fb_we),

    .rdata(fb_rdata),
    .raddr(fb_raddr),
    .re(fb_re),

    .frame_start(frame_start),
    .full_ftdi(full_ftdi),
    .swapped_ftdi(swapped_ftdi)
);

assign debug = full_ftdi;


// handles the main transmission
hub75_mainfsm mainfsm(
    .sys_clk(clk),
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
    .start(fetchshift_start),
    .frame_start(frame_start),

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
