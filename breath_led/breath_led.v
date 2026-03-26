//单个led灯的呼吸灯效果
/*以单led为例，低电平亮，高电平灭，控制PWM波占空比来控制led低电平时长，以实现led的不同亮度
一秒逐渐变亮，一秒逐渐变暗*/
/*以逐渐变亮为例，时钟周期20ns，s,ms,us,ns
s控制单个led从明到暗的长度,1s=1,000ms
ms控制pwm波的长度,1ms=1,000us
us控制实际pwm波的高电平值，1us=1000ns,50T*/
module breath_led
(
    input wire clk,rst_n,//50MHz，低电平复位

    output reg led_out
);
reg [15:0] clk_1s, clk_1ms, clk_1us;//计数器，记录时间
reg led_state;//led状态翻转标志位
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
    led_state<=1'b0;
    else if (clk_1s==S_MS_MAX && clk_1ms==S_MS_MAX && clk_1us==US_MAX)
        led_state<=~led_state;
        else led_state<=led_state;
end

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    led_out<=1'b0;
    else if (clk_1s < clk_1ms)
        led_out<=led_state;//标志位是低，灯就逐渐增加低电平时间
        else led_out<=~led_state;//其余时间补标志位反向值
end
endmodule 
