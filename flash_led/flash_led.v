module flash_led
#(//parameter全局变量
    parameter CNT_MAX=32'd50000000//定义参数 1s
)
(
    input wire clk,
    input wire rst_n,

    output reg led
);

//parameter CNT_MAX=32'd50000000;
//localparam 局部变量
reg [31:0] cnt ;

always @(posedge clk , negedge rst_n)
begin
    if(~rst_n)
        cnt<=1'd0;
    else if(cnt<CNT_MAX-1)
        cnt<=cnt+1'd1;
    else cnt<=1'd0;
end 

//always @(posedge clk , negedge rst_n)//时序逻辑取反，翻转LED状态
//begin
//    if(~rst_n)
//        led<=1'd0;
//    else if(cnt<CNT_MAX/2-1)//0~24999999
//        led=led;//保持
//    else led=~led;
//end 

    always @(*) //组合逻辑
begin
    if (cnt<=CNT_MAX/2-1) 
        led=1'b0;
    else led=1'b1;
end
endmodule
