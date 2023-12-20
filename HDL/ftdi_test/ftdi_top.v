module ftdi_top(
    input wire clk_60,          // ftdi clock
    input wire [7:0] data_in,   // input data
    input wire rxf_n,           // when high, cant read (no data available)
    input wire txe_n,           // when high, cant write (fifo full)
    output wire rd_n,           // set low to begin reading data
    output reg wr_n,            // set low to begin writing data
    output reg oe_n,            // set low to drive data on bus (one clock period before rd_n low)

    output reg [7:0] data
);

reg begin_read;

reg [7:0] data;

always @(posedge clk_60) begin


    if(!rxf_n) begin
        oe_n <= 1'b0;
        if(oe_n <= 1'b0) begin
            begin_read <= 1'b1;
            data <= data_in;
        end
    end else begin
        oe_n <= 1'b1;
        begin_read <= 1'b0;
    end


end

assign rd_n = rxf_n || !begin_read;

endmodule