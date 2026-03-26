//心跳灯模块
module heart_led
(
    input wire clk,rst_n,//50MHz，低电平复位

    output reg led0
);
reg [15:0] clk_1s, clk_1ms, clk_1us;//计数器，记录时间
parameter S_MS_MAX = 16'd999;//秒和毫秒的计数峰值//localparam不能跨文件使用，为了仿真改为parameter
parameter US_MAX = 16'd49;//50MHz晶振，1us=50T

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    clk_1us<=16'd0;
    else if (clk_1us==US_MAX)//分微秒的主要目的是让秒和微秒的份数对齐
        clk_1us<=16'd0;
        else  clk_1us<=clk_1us+1'b1;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    clk_1ms<=16'd0;
    else if (clk_1ms==S_MS_MAX && clk_1us==US_MAX) 
        clk_1ms<=16'd0;
        else if (clk_1us==US_MAX) 
		      clk_1ms<=clk_1ms+1'b1;
				else clk_1ms<=clk_1ms;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    clk_1s<=16'd0;
    else if (clk_1s==S_MS_MAX && clk_1ms==S_MS_MAX && clk_1us==US_MAX) 
        clk_1s<=16'd0;
        else  if (clk_1ms==S_MS_MAX && clk_1us==US_MAX)
		      clk_1s<=clk_1s+1'b1;
				else clk_1s<=clk_1s;
end


always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    led0<=1'b0;
    else if (clk_1s > clk_1ms)
        led0<=1'b1;
        else led0<=1'b0;//从最亮逐渐熄灭
end
endmodule 
