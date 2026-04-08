/*项目设计按键点灯。要求：
1、按键在4s内发生有效的2次按下小灯将保持被点亮；
2、按键在4s内发生有效的3次按下小灯将保持1s的闪光灯效果（0.5s亮，0.5s灭）；
3、按键在4s内发生有效的4次按下小灯将保持1s的心跳灯效果；
4、按键在4s内发生有效的5次及以上按下小灯将保持熄灭（只1次按下同样熄灭）；
*/
//改成了4s内操作结果会一直维持，不自动熄灭

module test_button_lighting
(
    input wire key, clk, rst_n,//50MHz晶振

    output reg led
);

parameter MAX_4s = 200_000_000;//4s
parameter MAX_20ms = 1_000_000;//20ms
parameter MAX_500ms = 25_000_000;//0.5s
parameter MAX_PWM_CNT = 1000;

reg [31:0] cnt_4s;
reg [31:0] cnt_20ms;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
       cnt_4s <= 32'd0;
    else if (cnt_4s ==  MAX_4s-1)
	      cnt_4s <= 32'd0;
			else if (flag == 1'b1)
			    cnt_4s <= cnt_4s + 1'b1;
				 else if (cnt_4s == 1'b0)
				     cnt_4s <= cnt_4s;
				      else cnt_4s <= cnt_4s + 1'b1;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
       cnt_20ms <= 32'd0;
	 else if (key == 1'b1)
                cnt_20ms <= 32'd0;
        else if (cnt_20ms ==  MAX_20ms-1)
                cnt_20ms <= cnt_20ms;
            
                else cnt_20ms <= cnt_20ms + 1'b1;
end

reg flag;//按下标志位

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        flag <= 1'b0;
    else if (cnt_20ms ==  MAX_20ms-2 )
            flag <= 1'b1;
            else flag <= 1'b0;
end

reg [2:0] flag_num;//按下的次数

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        flag_num <= 3'd0;
		  //************************************************
		 // else if (flag == 1'b1)
		 //     flag_num <= flag_num +1'b1;
		 //     else if (flag_num > 4 || cnt_4s == MAX_4s-1)
		 //	    flag_num <= 3'd0;
		 //     else flag_num <= flag_num;
		  //************************************************
		  //上述代码会4s后自动熄灭
		  else if (cnt_4s ==  32'd0 && flag == 1'b1)
		      flag_num <= 3'd1;
            else if (flag == 1'b1)
                    flag_num <= flag_num +1'b1;
                    else if (flag_num > 4 )//按下次数5以上，或者时间超过四秒再按均下一次熄灭
                            flag_num <= 3'd0;	  
                        else flag_num <= flag_num;
end

reg [31:0] cnt_500ms;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
       cnt_500ms <= 32'd0;
    else if (cnt_500ms ==  MAX_500ms-1)
            cnt_500ms <= 32'd0;
            else cnt_500ms <= cnt_500ms + 1'b1;
end

reg [31:0] cnt_1us;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
       cnt_1us <= 32'd0;
    else if (cnt_1us ==  MAX_20ms/20/1000-1)//50T
            cnt_1us <= 32'd0;
            else cnt_1us <= cnt_1us + 1'b1;
end

reg [31:0] cnt_1ms;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
       cnt_1ms <= 32'd0;//1000*1us
    else if (cnt_1ms ==  MAX_PWM_CNT && cnt_1us ==  MAX_20ms/20/1000-1)
            cnt_1ms <= 32'd0;
            else if (cnt_1us ==  MAX_20ms/20/1000-1)
                cnt_1ms <= cnt_1ms + 1'b1;
            else cnt_1ms <= cnt_1ms;
end

reg [31:0] cnt_1s;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
       cnt_1s <= 32'd0;//50_000_000T
    else if (cnt_1s ==  MAX_PWM_CNT && cnt_1ms ==  MAX_PWM_CNT && cnt_1us ==  MAX_20ms/20/1000-1)
            cnt_1s <= 32'd0;
            else if (cnt_1ms ==  MAX_PWM_CNT && cnt_1us ==  MAX_20ms/20/1000-1)
                cnt_1s <= cnt_1s + 1'b1;
            else cnt_1s <= cnt_1s;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        led <= 1'b0;
    else 
	    begin
           case(flag_num)
               2:led <= 1'b0;
               3:begin
                   if (cnt_500ms == 0)
                       led <= ~led;
                   else led <= led;
               end
               4:begin
                   if (cnt_1s <= cnt_1ms)
                       led <= 1'b1;
                   else led <= 1'b0;
               end
               default :led <= 1'b1;
               endcase
        end
        
end
endmodule
