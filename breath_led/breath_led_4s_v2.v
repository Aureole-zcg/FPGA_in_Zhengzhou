module breath_led_4s_v2
(
    input wire clk,rst_n,//50MHz，低电平复位

    output reg led_out
);
reg [15:0] clk_4s, clk_4ms, clk_1us;//计数器，记录时间
reg led_state;//led状态翻转标志位
parameter MS_MAX = 16'd1999;//秒和毫秒的计数峰值//localparam不能跨文件使用，为了仿真改为parameter
parameter S_MAX = 16'd1999;//4s的cnt计数峰值
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
    clk_4ms<=16'd0;
    else if (clk_4ms==MS_MAX && clk_1us==US_MAX) 
        clk_4ms<=16'd0;
        else if (clk_1us==US_MAX) 
		      clk_4ms<=clk_4ms+1'b1;
				else clk_4ms<=clk_4ms;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    clk_4s<=16'd0;
    else if (clk_4s==S_MAX && clk_4ms==MS_MAX && clk_1us==US_MAX) 
        clk_4s<=16'd0;
        else  if (clk_4ms==MS_MAX && clk_1us==US_MAX)
		      clk_4s<=clk_4s+1'b1;
				else clk_4s<=clk_4s;
end

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    led_state<=1'b0;
    else if (clk_4s==S_MAX && clk_4ms==MS_MAX && clk_1us==US_MAX)
        led_state<=~led_state;
        else led_state<=led_state;
end

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    led_out<=1'b0;
  else if (clk_4s < clk_4ms)//4s分成了1999份，一份2ms，2ms分成了1999份,一份1us，暗到亮的过程，分成2千份，所以s和ms的份数已经对齐
        led_out<=led_state;//标志位是低，灯就逐渐增加低电平时间
        else led_out<=~led_state;//其余时间补标志位反向值
end
endmodule 
