//奇分频的模板
module div_2np1
#(
    parameter DIV_NUM=32'd7//7分频
)
(
    input wire clk,rst_n,

    output wire clk_div2np1
);

localparam CNT_MAX = DIV_NUM-1;//6

reg [31:0]cnt_pose, cnt_nege;//上升沿下降沿计数器
reg clk_pose, clk_nege;

always @(posedge clk, negedge rst_n)//上升沿0~6循环计数
begin
    if(~rst_n)
        cnt_pose<=32'd0;
    else if(cnt_pose==CNT_MAX)//计数满清零
            cnt_pose<=32'd0;
        else cnt_pose<=cnt_pose+1'd1;
end

always @(negedge clk, negedge rst_n)//下升沿0~6循环计数
begin
    if(~rst_n)
        cnt_nege<=32'd0;
    else if(cnt_nege==CNT_MAX)//计数满清零
            cnt_nege<=32'd0;
        else cnt_nege<=cnt_nege+1'd1;
end

always @(posedge clk, negedge rst_n)//上升沿0~6循环计数
begin
    if(~rst_n)
        clk_pose<=1'd0;
    else clk_pose<=(cnt_pose<CNT_MAX>>1)?1'b1:1'b0;
end

always @(negedge clk, negedge rst_n)//上升沿0~6循环计数
begin
    if(~rst_n)
        clk_nege<=1'd0;
		  else clk_nege<=(cnt_nege<CNT_MAX>>1)?1'b1:1'b0;
end

//always @(negedge clk, negedge rst_n)//上升沿0~6循环计数
//begin//去掉下降边沿计数器
//    if(~rst_n)
//        clk_nege<=1'd0;
//    else clk_nege=(cnt_pose==32'd0||cnt_pose==32'd1||cnt_pose==32'd2||cnt_pose==32'd3)?1'b1:1'b0;
//end

assign clk_div2np1=clk_nege | clk_pose;   

endmodule
