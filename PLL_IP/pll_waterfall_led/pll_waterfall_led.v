//调用锁相环IP核，产生200Mhz的时钟，要求使用这个200Mhz的时钟信号，编写流水灯模块（4个LED灯500ms流水显示）
module pll_waterfall_led
(
    input wire clk, rst_n,
    output reg led0, led1, led2, led3
);

waterfall	waterfall_inst (
	.areset ( ~rst_n ),
	.inclk0 ( clk ),
	.c0 ( c0 ),
	.locked (  )
	);

//倍频200MHz时钟，T=5ns, 闪光灯模块（1个LED灯1秒亮灭循环）
parameter Second_500MS = 100_000_000;//200MHz时钟周期为5ns，500毫秒需要100_000_000个时钟周期
reg [31:0] cnt_switch;//计数器，用来计算led亮灭时间

always @(posedge c0, negedge rst_n) //使用c0时钟
begin
    if (~rst_n)
    begin
        cnt_switch <= 32'd0;
        led0 <= 1'b0;
        led1 <= 1'b1;
        led2 <= 1'b1;
        led3 <= 1'b1;
    end
    else if (cnt_switch == Second_500MS - 1) //当计数器达到500毫秒的时钟周期数时，切换LED状态
        begin
            cnt_switch <= 32'd0;
            led0 <= led3; //切换LED状态
            led1 <= led0;
            led2 <= led1;
            led3 <= led2;
        end
        else 
            begin
                cnt_switch <= cnt_switch + 1; //计数器加1
                led0 <= led0;//led保持状态
                led1 <= led1;
                led2 <= led2;
                led3 <= led3;
            end
    
end
endmodule
