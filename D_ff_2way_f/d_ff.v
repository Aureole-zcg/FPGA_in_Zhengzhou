module d_ff
(
    input wire clk,//时钟信号
    input wire rst_n,//复位信号
    input wire D,//输入信号

    output reg Q
);

//时序逻辑唯一书写表达式、
//(posedge clk)上升沿//下降沿（negedge clk)
//always @(posedge clk)同步复位
always @(posedge clk or negedge rst_n)//异步复位
begin
    if(rst_n==1'b0)
    Q<=1'b0;
    else
    Q<=D;

end


endmodule
