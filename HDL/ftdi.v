`timescale 10ns/100ps


module ftdi(
    input wire clk_60,          // ftdi clock
    input wire [7:0] data_in,   // input data
    input wire rxf_n,           // when high, cant read (no data available)
    input wire txe_n,           // when high, cant write (fifo full)
    output wire rd_n,           // set low to begin reading data
    output wire wr_n,           // set low to begin writing data
    output wire oe_n,           // set low to drive data on bus (one clock period before rd_n low)

    output wire [19:0] fb_wdata,
    output wire [13:0] fb_waddr,
    output wire fb_we,

    output reg full,
    input wire swapped
);

// MAIN STATE MACHINE ==========================================================================
// this handles the direct byte-level transactions with the FTDI FIFO.
localparam
    IDLE    = 3'b011,
    START   = 3'b010,
    READ    = 3'b100
;

wire ftdi_req = !rxf_n;
wire read_state = state[2];

assign oe_n = state[0];
assign rd_n = state[1];
assign wr_n = 1'b1;


reg [2:0] state = IDLE;
reg [2:0] next_state;

always @(posedge clk_60) begin
    state <= next_state;
end


// due to USB packetizing and comparatively low framerate,
// we can assume that a packet will end on the last byte of the frame
// and won't have to worry about continuing to read while full
always @(*) begin
    case (state)
        IDLE:       next_state = (ftdi_req && !full) ? START : IDLE;
        START:      next_state = (ftdi_req) ? READ : IDLE;
        READ:       next_state = (ftdi_req) ? READ : IDLE;
        default:    next_state = IDLE;
    endcase
end

wire ftdi_read_en = read_state & !rxf_n;

// SEQUENCING ===============================================================================
// this handles writing to the memory and incrementing the counter every 3rd byte
// it also synchronizes to the frame start bit (data[7]) to prevent misalignment

reg [2:0] seq = 3'b001;
reg [2:0] next_seq;
reg active = 1'b0;

always @(*) begin
    case (seq)
        3'b001: next_seq = 3'b010;
        3'b010: next_seq = 3'b100;
        3'b100: next_seq = 3'b001;
        default: next_seq = 3'b001;
    endcase
end

always @(posedge clk_60) begin
    if(ftdi_read_en) begin
        if(data_in[7]) begin
            seq <= 3'b001;
        end else begin
            seq <= next_seq;
        end
    end
    active <= ftdi_read_en;
end

wire bram_write = seq[0] & active;
assign fb_we = bram_write;

// SHIFT REGISTER ===============================================================================
// this loads the bytes into a 24-bit shift register, to prepare to send to the BRAM.
reg [23:0] shiftreg_out;
always @(posedge clk_60) begin
    if (ftdi_read_en) begin
        shiftreg_out <= {shiftreg_out[15:0], data_in};
    end
end

// the 20-bit signal to be stored into BRAM
assign fb_wdata = {shiftreg_out[22:16],shiftreg_out[14:8],shiftreg_out[5:0]};
assign fb_waddr = write_cnt_out;


// WRITE COUNTER ==================================================================================
// controls the counter that writes into the framebuffer

wire [13:0] write_cnt_out;
wire write_cnt_rst = (data_in[7] &&ftdi_read_en)  || swapped; // reset counter if start of frame received or if buffer swapped 
counter #(.WIDTH(14)) write_cnt (
    .clk(clk_60),
    .rst(write_cnt_rst),
    .en(bram_write),

    .out(write_cnt_out)
);


// FULL SIGNAL ==================================================================================
// this tells the framebuffer that the frame is full, and also
// resets the signal when the framebuffer has told us it has swapped
initial full = 1'b0;
always @(posedge clk_60) begin
    if(write_cnt_out == 14'd16383 && bram_write) begin
        full <= 1'b1;
    end else if (swapped) begin
        full <= 1'b0;
    end
end

endmodule