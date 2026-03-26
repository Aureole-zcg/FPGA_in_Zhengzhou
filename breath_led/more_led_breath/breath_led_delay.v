/*这条代码，是用来搭配more_led_breath_top使用的，top程序会提供本程序的延迟值，计数器more_led_breath在
跑完延迟时间前，呼吸灯的 clk_1s 计数器不会工作，即强行将信号延长delay的时间，以达到呼吸灯的呼吸不同步，
更改delay的数据，可以达到led自我秩序的呼吸，注：多个led需要多次调用*/
module breath_led_delay
(
    input wire clk,rst_n,//50MHz，低电平复位
    input wire [31:0] delay, //延时输入信号，控制呼吸灯的相位

    output reg led_out
);
reg [15:0] clk_1s, clk_1ms, clk_1us;//计数器，记录时间
reg led_state;//led状态翻转标志位
parameter S_MS_MAX = 16'd999;//秒和毫秒的计数峰值//localparam不能跨文件使用，为了仿真改为parameter
parameter US_MAX = 16'd49;//50MHz晶振，1us=50T

reg [31:0] delay_cnt;//延时计数器


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
    if (~rst_n) begin
        clk_1s<=16'd0;
        delay_cnt<=32'd0;
    end
    else if (delay_cnt<delay) //如果延时计数器的值小于输入的延时值，继续增加计数器
        delay_cnt<=delay_cnt+1'b1;
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
