`timescale 10ns/100ps

module hub75_top_tb(

);


//main inputs
reg clk, clk_60;

// memory wires
wire r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4;
wire row_clk, row_data;
wire clk_out, lat, blank;

// ftdi
reg [7:0] ftdi_data;
reg rxf_n, txe_n;
wire rd_n, wr_n, oe_n;


hub75_top dut(
    .clk(clk),
    .clk_60(clk_60),

    .ftdi_data(ftdi_data),
    .ftdi_rxf_n(rxf_n),
    .ftdi_txe_n(txe_n),
    .ftdi_rd_n(rd_n),
    .ftdi_wr_n(wr_n),
    .ftdi_oe_n(oe_n),
    
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
    .row_clk(row_clk),
    .row_data(row_data),
    .clk_out(clk_out),
    .lat(lat),
    .blank(blank)
);



// system signals
initial begin
    // For iverilog
    $dumpfile("out.vcd");
    $dumpvars;

    //Initial values
    clk = 1'b0;
    clk_60 = 1'b0;


    #400000 $finish;
end

// ftdi signals
initial begin
    //Initial values
    ftdi_data = 8'b00000000;
    rxf_n = 1'b1;
    txe_n = 1'b0;

    #1.666 
    #1.266 rxf_n = 1'b0;
    #0.4 ftdi_data = 8'b10101010;
    #1.666 
    #1.666
    #1.666
    #1.666
    #0.833 rxf_n = 1'b1;


end

// system clocks
always #1 clk = ~clk;
always #0.833 clk_60 = ~clk_60;

endmodule