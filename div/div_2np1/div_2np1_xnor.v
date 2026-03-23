module div_2np1_xnor
#(
    parameter DIV_NUM=32'd3//分频数，奇数
)
(
    input wire clk,rst_n,

    output wire clk_div2np1
);

localparam CNT_MAX = DIV_NUM-1;

reg [31:0] cnt;
reg clk_pose, clk_nege;

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
        clk_pose<=1'd0;
    else if(cnt==CNT_MAX)
        clk_pose<=~clk_pose;
end

always @(negedge clk, negedge rst_n)
begin
    if(~rst_n)
        clk_nege<=1'd0;
    else if(cnt==CNT_MAX/2)
        clk_nege<=~clk_nege;
end

assign clk_div2np1=clk_pose ~^ clk_nege;

endmodule
