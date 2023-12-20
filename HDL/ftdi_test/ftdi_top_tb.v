`timescale 1ns/10ps

module hub75_top_tb(
);


//main inputs
reg clk_60;
reg [7:0] data;

reg rxf_n, txe_n;

// memory wires
wire rd_n, wr_n, oe_n, siwu;

ftdi_top dut(
    .clk_60(clk_60),
    .data_in(data),
    .rxf_n(rxf_n),
    .txe_n(txe_n),
    .rd_n(rd_n),
    .wr_n(wr_n),
    .oe_n(oe_n)
);




initial begin
    // For iverilog
    $dumpfile("out.vcd");
    $dumpvars;

    //Initial values
    clk_60 = 1'b0;
    data = 8'b00000000;
    rxf_n = 1'b1;
    txe_n = 1'b0;

    #16.66 
    #12.66 rxf_n = 1'b0;
    #4 data = 8'b10101010;
    #16.66 
    #16.66
    #16.66
    #16.66
    #8.33 rxf_n = 1'b1;


    #3000 $finish;
end

always #8.33 clk_60 = ~clk_60;

endmodule