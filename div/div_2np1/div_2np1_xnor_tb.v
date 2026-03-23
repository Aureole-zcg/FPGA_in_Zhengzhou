`timescale 1ns/1ps

module div_2np1_xnor_tb();
reg clk,rst_n;
wire clk_div2np1;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;
    #77
    rst_n=1'b1;
end

always #10 clk=~clk;

div_2np1_xnor 
#(
   .DIV_NUM(32'd11)//11分频
)
div_2np1_xnor_inst7(
    .clk(clk),
    .rst_n(rst_n),
    .clk_div2np1(clk_div2np1)
);
endmodule

