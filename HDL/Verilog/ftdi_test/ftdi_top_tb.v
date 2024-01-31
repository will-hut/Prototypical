`timescale 1ns/10ps

module hub75_top_tb(
);


//main inputs
reg clk_60;
reg rxf_n;

// memory wires
wire rd_n, wr_n, oe_n;

integer i = 0;
reg [7:0] mem [0:15];
wire [7:0] data_to_ftdi = oe_n ? 8'bz : mem[i];

ftdi_top dut(
    .clk_60(clk_60),
    .data_in(data_to_ftdi),
    .rxf_n(rxf_n),
    .txe_n(1'b1),
    .rd_n(rd_n),
    .wr_n(wr_n),
    .oe_n(oe_n)
);

always @(posedge clk_60) begin
    if(!rd_n) begin
        i = i+1;
    end
end


initial begin
    // For iverilog
    $dumpfile("out.vcd");
    $dumpvars;

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


    #16.66 
    #12.66 rxf_n = 1'b0;
    #4
    #16.66 
    #16.66 
    #16.66
    #16.66
    #16.66 
    #16.66
    #16.66
    #9.33 rxf_n = 1'b1;
    #7.33
    #12.66 rxf_n = 1'b0;
    #4
    #16.66
    #16.66
    #16.66
    #16.66
    #9.33 rxf_n = 1'b1;

    #3000 $finish;
end

always #8.33 clk_60 = ~clk_60;

endmodule