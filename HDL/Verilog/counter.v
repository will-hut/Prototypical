`timescale 10ns/100ps

module counter
#(parameter WIDTH=8) (
    input wire clk,
    input wire rst,
    input wire en,

    output reg [WIDTH-1:0] out
);

initial out = 0;

wire [WIDTH-1:0] next = out + 1'b1;

always @(posedge clk) begin
    if(rst) begin
        out <= 0;
    end else begin
        if(en) begin
            out <= next;
        end
    end
end

endmodule