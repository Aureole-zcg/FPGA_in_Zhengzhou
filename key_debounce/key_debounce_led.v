//按键按下，小灯状态翻转
module key_debounce_led
#(
    parameter Debounce_TIME = 20_000_000//消抖信号20ms
)
(
    input wire key_in, clk, rst_n,

    output reg led0,led1,led2,led3
);
reg [31:0] cnt;//低电平计数器
reg key_out;
localparam CNT_MAX = Debounce_TIME/20-1;//20ns时钟晶振

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
            cnt<=32'd0;        
    else if (key_in==1'b1)
            cnt<=32'd0;
        else if (cnt==CNT_MAX)
                cnt<=cnt;
            else cnt<=cnt+1'b1;    
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        key_out<=1'b0;
    else if (cnt==CNT_MAX-1)//最后一位计数保持，以控制按下次数
            key_out<=1'b1;//单独高电平表示采集到按键按下，按键标示电平
        else key_out<=1'b0;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
	     begin
		  led0=1'b0;
		  led1=1'b0;
		  led2=1'b1;
		  led3=1'b1;
		  end
		  
    else if(key_out)
	         begin
		      led0=~led0;
		      led1=~led1;
		      led2=~led2;
		      led3=~led3;
		      end
		  else 
		      begin//组合逻辑无法实现自我保持，会产生锁存器导致结果错误，自我赋值采用时序逻辑
				led0=led0;
		      led1=led1;
		      led2=led2;
		      led3=led3;
				end
	 
	     //begin
        //led0=(key_out==1'b1)? ~led0:led0;
        //led1=(key_out==1'b1)? ~led1:led1;
        //led2=(key_out==1'b1)? ~led2:led2;
        //led3=(key_out==1'b1)? ~led3:led3;
		  //end

end
endmodule
