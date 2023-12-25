module ftdi(
    input wire clk_60,          // ftdi clock
    input wire [7:0] data_in,   // input data
    input wire rxf_n,           // when high, cant read (no data available)
    input wire txe_n,           // when high, cant write (fifo full)
    output wire rd_n,           // set low to begin reading data
    output wire wr_n,            // set low to begin writing data
    output reg oe_n,            // set low to drive data on bus (one clock period before rd_n low)

    output wire [19:0] fb_wdata,
    output wire [13:0] fb_waddr,
    output wire fb_we,

    // sysclock domain
    input wire frame_start,
    output wire fb_sel
);

reg begin_read;

assign fb_wdata = 20'b0;
assign fb_waddr = 14'b0;
assign fb_we = 1'b0;

assign wr_n = 1'b1;

// this is gonna have to cross domains
assign fb_sel = 1'b0;

always @(posedge clk_60) begin


    if(!rxf_n) begin
        oe_n <= 1'b0;
        if(oe_n <= 1'b0) begin
            begin_read <= 1'b1;
            // latch in data here
        end
    end else begin
        oe_n <= 1'b1;
        begin_read <= 1'b0;
    end


end

assign rd_n = rxf_n || !begin_read;

endmodule