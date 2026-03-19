module D_ff_2way_f
(
    input wire D,
    input clk,
    input rst_n,

    output reg Q
);

//时序逻辑唯一书写表达式、
//(posedge clk)上升沿//下降沿（negedge clk)
//always @(posedge clk)同步复位  always @(posedge clk or negedge rst_n)//异步复位
always @(negedge clk)
begin
    if(rst_n==1'b0)
        Q<=0;
    else Q<=D;
    
end
endmodule
