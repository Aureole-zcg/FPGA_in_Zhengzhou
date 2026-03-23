//一个模拟测试偶分频的仿真代码，更改.DIV_NUM(32'd20)端口内偶数，即可仿真对应偶分频
`timescale 1ns/1ps

module div_2n_tb();
reg clk,rst_n;
wire clk_div;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;
    #77
    rst_n=1'b1;
end

always #10 clk=~clk;

div_2n 
#(
    .DIV_NUM(32'd20)//仿真20分频
)
div_2n_inst(
    .clk(clk),
    .rst_n(rst_n),
    .clk_div(clk_div)
);

endmodule
