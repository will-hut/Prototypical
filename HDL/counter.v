`default_nettype none

module counter
#(parameter WIDTH=8) (
    input clk,
    input rst,
    input en,

    output reg [WIDTH-1:0] out
);

wire [WIDTH-1:0] next = out + 1;

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