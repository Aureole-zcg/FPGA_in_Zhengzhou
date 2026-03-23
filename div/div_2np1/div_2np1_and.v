module div_2np1_and
#(
    parameter DIV_NUM=32'd3//分频数，奇数
)
(
    input wire clk,rst_n,

    output wire clk_div2np1
);

reg [31:0] cnt;
reg clk_1, clk_2;
localparam CNT_MAX = DIV_NUM-1'b1;

always @(posedge clk, negedge rst_n) 
begin
    if(~rst_n)
            cnt<=32'd0;
    else if (cnt==CNT_MAX)
            cnt<=1'b0;
        else cnt<=cnt+1'b1;
end 
    
always @(posedge clk, negedge rst_n) 
begin
    if(~rst_n)
	     clk_1<=1'b0;
    else if (cnt==CNT_MAX||cnt<CNT_MAX>>1)//
             clk_1<=1'b1;
         else clk_1<=1'b0;        
end

always @(negedge clk, negedge rst_n) 
begin
    if (~rst_n)
            clk_2<=1'b0;
    else clk_2=(cnt==1'd0||cnt==1'd1)?1'b1:1'b0;//其他奇分频修改范围
end

assign clk_div2np1=clk_1&clk_2;
endmodule
