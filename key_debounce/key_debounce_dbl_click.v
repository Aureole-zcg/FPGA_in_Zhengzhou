//单按键双击改变led状态
module key_debounce_dbl_click
(
    input wire key_in1, clk, rst_n,

    output reg led_out0, led_out1, led_out2, led_out3
);

localparam WAIT_TIME = 2_000_000_000;//两按键等待时间最大两秒
localparam CNT_LED_MAX = WAIT_TIME/20-1;//99999999
reg [31:0] cnt_led;
wire key_out;//按键消抖输出的一个时钟周期的标志
reg [1:0]cnt_key_first;//按键已经按下一次
reg out_key_led;

key_debounce
#(
    .Debounce_TIME(20_000_000)//消抖信号20ms
)
key_debounce_key1//调用按键消抖
(
    .key_in(key_in1), 
    .clk(clk), 
    .rst_n(rst_n),

    .key_out(key_out)
);

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_key_first<=2'd0;
    else if (key_out==1'b1)
            cnt_key_first<=cnt_key_first+1'b1;//第一个按键已按下
        else begin
            cnt_key_first<=cnt_key_first;//保持记录已经按下一个按键
            if (cnt_key_first>1'b1||cnt_led==CNT_LED_MAX)//第二次按下或等待超过2s
            cnt_key_first<=2'd0;
            end   
end

//key_debounce
//#(
//    .Debounce_TIME(20_000_000)//消抖信号20ms
//)
//key_debounce_key2//调用第二个按键消抖
//(
//    .key_in(key_in2), //两按键非双击.key_in(key_in2),
//    .clk(clk), 
//    .rst_n(rst_n),
//
//    .key_out(key_out2)
//);

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin 
        cnt_led<=32'd0;
        out_key_led<=1'b0;
    end
    else if (cnt_key_first==2'd1&&cnt_led==32'd0)
            cnt_led<=cnt_led+1'd1;
        else if (cnt_led==CNT_LED_MAX)//等待两秒
                cnt_led<=32'd0;
					 
             else 
				 begin if (cnt_led==32'd0)
                 		cnt_led<=cnt_led;
				       else cnt_led<=cnt_led+1'd1;
				       if (cnt_key_first==2'd2&&cnt_led>32'd0)
                        out_key_led<=1'b1;
                   else out_key_led<=1'b0;
				 end
end


  //always @(posedge clk, negedge rst_n) //由双按键改写得来
//begin
//    if (~rst_n)
//    begin 
//        cnt_led<=32'd0;
//        out_key_led<=1'b0;
//    end
//    else if (key_out==1'b1&&cnt_led==32'd0)
//            cnt_led<=cnt_led+1'd1;  
//        else 
//		  begin 
//		       if (cnt_led==CNT_LED_MAX)//等待两秒
//                cnt_led<=32'd0;
//		       else 
//				 begin if (cnt_led==32'd0)
//				          cnt_led<=cnt_led;
//				     else cnt_led<=cnt_led+1'd1;
//				     if (key_out2==1'b1&&cnt_led>32'd0)
//                        out_key_led<=1'b1;
//                    else out_key_led<=1'b0;
//				 end
//		  end
//end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin 
        led_out0<=1'b0;
        led_out1<=1'b0;
        led_out2<=1'b1;
        led_out3<=1'b1;
    end
    else if (out_key_led==1'b1)
        begin
		    led_out0<=~led_out0;
		    led_out1<=~led_out1;
		    led_out2<=~led_out2;
		    led_out3<=~led_out3;
		end
        else begin
				  led_out0<=led_out0;
		        led_out1<=led_out1;
		        led_out2<=led_out2;
		        led_out3<=led_out3;
			end
end
endmodule
