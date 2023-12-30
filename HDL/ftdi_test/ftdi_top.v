module ftdi_top(
    input wire clk_60,          // ftdi clock
    input wire [7:0] data_in,   // input data
    input wire rxf_n,           // when high, cant read (no data available)
    input wire txe_n,           // when high, cant write (fifo full)
    output wire rd_n,           // set low to begin reading data
    output wire wr_n,            // set low to begin writing data
    output wire oe_n             // set low to drive data on bus (one clock period before rd_n low)
);

// MAIN STATE MACHINE ==========================================================================
// this handles the direct byte transactions with the FTDI FIFO.
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

always @(*) begin
    case (state)
        IDLE:       next_state = (ftdi_req && writable) ? START : IDLE;
        START:      next_state = (ftdi_req) ? READ : IDLE;
        READ:       next_state = (ftdi_req) ? READ : IDLE;
        default:    next_state = IDLE;
    endcase
end

wire ftdi_read_en = read_state & !rxf_n;

// SEQUENCER ===============================================================================
// this handles writing to the memory and incrementing the counter every 3rd byte
// it also synchronizes to the frame start bit (data[7]) to prevent getting off

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

wire bram_write = seq[2] & active;

wire [13:0] write_cnt_out;
counter #(.WIDTH(14)) write_cnt (
    .clk(clk_60),
    .rst(data_in[7]),
    .en(bram_write),

    .out(write_cnt_out)
);

wire writable = (count != 14'b11111111111111);


// SHIFT REGISTER ===============================================================================
// this loads the bytes into a 24-bit shift register, to prepare to send to the BRAM.
reg [23:0] shiftreg_out;
always @(posedge clk_60) begin
    if (ftdi_read_en) begin
        shiftreg_out <= {shiftreg_out[15:0], data_in};
    end
end

// the 20-bit signal to be stored into BRAM
wire [19:0] bram_write_data = {shiftreg_out[22:16],shiftreg_out[14:0],shiftreg_out[5:0]};

endmodule