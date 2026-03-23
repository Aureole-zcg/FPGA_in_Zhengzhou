`timescale 1ns/1ps

module div_2np1_tb();
reg clk,rst_n;
wire clk_div2np1;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;
    #77
    rst_n=1'b1;
end

always #20 clk=~clk;

div_2np1 
#(
   .DIV_NUM(32'd7)//7分频
)
div_2np1_inst7(
    .clk(clk),
    .rst_n(rst_n),
    .clk_div2np1(clk_div2np1)
);
endmodule

