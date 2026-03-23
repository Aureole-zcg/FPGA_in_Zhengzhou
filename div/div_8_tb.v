`timescale 1ns/1ps

module div_8_tb();
reg clk,rst_n;
wire clk_div8;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;
    #77
    rst_n=1'b1;
end

always #20 clk=~clk;

div_8 div_8_inst(
    .clk(clk),
    .rst_n(rst_n),
    .clk_div8(clk_div8)
);

endmodule
