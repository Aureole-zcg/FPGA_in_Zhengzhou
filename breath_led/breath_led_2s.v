/*两秒逐渐变亮，两秒逐渐变暗
cnt_2s,0~999
cnt_2ms,0~1999
暗到亮的过程，分成1千份*/
module breath_led_2s
(
    input wire clk,rst_n,//50MHz，低电平复位

    output reg led_out
);
reg [15:0] clk_2s, clk_2ms, clk_1us;//计数器，记录时间
reg led_state;//led状态翻转标志位
parameter MS_MAX = 16'd1999;//秒和毫秒的计数峰值//localparam不能跨文件使用，为了仿真改为parameter
parameter S_MAX = 16'd999;//1s的cnt计数峰值
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
    clk_2ms<=16'd0;
    else if (clk_2ms==MS_MAX && clk_1us==US_MAX) 
        clk_2ms<=16'd0;
        else if (clk_1us==US_MAX) 
		      clk_2ms<=clk_2ms+1'b1;
				else clk_2ms<=clk_2ms;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    clk_2s<=16'd0;
    else if (clk_2s==S_MAX && clk_2ms==MS_MAX && clk_1us==US_MAX) 
        clk_2s<=16'd0;
        else  if (clk_2ms==MS_MAX && clk_1us==US_MAX)
		      clk_2s<=clk_2s+1'b1;
				else clk_2s<=clk_2s;
end

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    led_state<=1'b0;
    else if (clk_2s==S_MAX && clk_2ms==MS_MAX && clk_1us==US_MAX)
        led_state<=~led_state;
        else led_state<=led_state;
end

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    led_out<=1'b0;
    else if (clk_2s < clk_2ms>>1)//2s分成了999份，2ms分成了1999份，暗到亮的过程，分成1千份，所以s和ms的份数要对齐
        led_out<=led_state;//标志位是低，灯就逐渐增加低电平时间
        else led_out<=~led_state;//其余时间补标志位反向值
end
endmodule 
