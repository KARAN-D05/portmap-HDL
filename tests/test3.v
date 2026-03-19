module mux_3to1_8bit(
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [1:0] sel,
    output reg [7:0] out
);

 always @(*) begin
    case (sel)
      2'b00 : out = in0;
      2'b01 : out = in1;
      2'b10 : out = in2;
      default: out = 1'b0;
    endcase
 end
endmodule