`timescale 1ns/1ns
module analog_emu
#(parameter CLK300PERIOD  = 385 * 8, CLK2M4PERIOD = 385)
(
  output reg clk_2m4,
  output reg clk_300k,
  output reg rstn_o
);

initial begin
  clk_2m4 = 1'b0;
  clk_300k= 1'b0;
  rstn_o  = 1'b1;
end

always #(CLK2M4PERIOD/2) clk_2m4  = ~clk_2m4 ;
always #(CLK300PERIOD/2) clk_300k = ~clk_300k;

endmodule
