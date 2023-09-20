`timescale 10ns/100ps

module hub75_top_tb(

);


//main inputs
reg clk;
reg rst;

// memory wires
wire r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4;
wire row_clk, row_data;
wire clk_out, lat, blank;

hub75_top dut(
    .clk(clk),
    .rst(rst),
    
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




initial begin
    // For iverilog
    $dumpfile("out.vcd");
    $dumpvars;

    //Initial values
    clk = 1'b0;
    rst = 1'b1;

    // pulse reset
    #2 rst = 1'b0;


    #300000 $finish;
end

always #1 clk = ~clk;

endmodule