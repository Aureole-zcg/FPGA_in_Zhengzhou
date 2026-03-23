//这是一个参数可调的偶分频模板，更改DIV_NUM的偶数即可得到对应偶分频
module div_2n
#(
    parameter DIV_NUM = 32'd8//参数在test banch的参数端口修改
)
(
    input wire clk,rst_n,
    output reg clk_div
);

reg [31:0] cnt ;
localparam CNT_MAX = DIV_NUM-1;

always @(negedge clk, negedge rst_n)
begin
    if (~rst_n)
        cnt<=32'd0;
    else 
	    if (cnt==CNT_MAX)//常规判断清零
	           cnt<=1'd0;
        else cnt<=cnt+1'd1;//一共计数DIV_NUM-1个时钟边沿，(DIV_NUM-1)分频
end

always @(negedge clk, negedge rst_n) 
begin
    if (~rst_n)
        clk_div<=1'd0;
    else
        begin
            if (cnt<CNT_MAX/2||cnt==CNT_MAX) 
                clk_div=1'b1;
            else clk_div=1'b0;
		end
end
endmodule
