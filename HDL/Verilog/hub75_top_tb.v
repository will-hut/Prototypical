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
reg rxf_n;
wire rd_n, wr_n, oe_n;

integer i = 0;
reg [7:0] mem [0:15];
wire [7:0] data_to_ftdi = oe_n ? 8'b11111111 : mem[i];


hub75_top dut(
    .clk(clk),
    .clk_60(clk_60),

    .ftdi_data(data_to_ftdi),
    .ftdi_rxf_n(rxf_n),
    .ftdi_txe_n(1'b1),
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

always @(posedge clk_60) begin
    if(!rd_n) begin
        i = i+1;
    end
end

initial begin
    mem[0] = 8'hFF;
    mem[1] = 8'h01;
    mem[2] = 8'h02;
    mem[3] = 8'h03;
    mem[4] = 8'h04;
    mem[5] = 8'h05;
    mem[6] = 8'h06;
    mem[6] = 8'h06;
    mem[7] = 8'h07;
    mem[8] = 8'h08;
    mem[9] = 8'h09;
    mem[10] = 8'h10;
    mem[11] = 8'h11;
    mem[12] = 8'h12;
    mem[13] = 8'h13;
    mem[14] = 8'h14;
    mem[15] = 8'h15;

    //Initial values
    clk_60 = 1'b0;
    rxf_n = 1'b1;


    #1.666 
    #1.266 rxf_n = 1'b0;
    #0.4
    #1.666 
    #1.666 
    #1.666
    #1.666
    #1.666 
    #1.666
    #1.666
    #1.666
    #1.666
    #1.666
    #1.666
    #0.933 rxf_n = 1'b1;
end

// system clocks
always #1 clk = ~clk;
always #0.833 clk_60 = ~clk_60;

endmodule