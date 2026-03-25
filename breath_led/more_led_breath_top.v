module more_led_breath_top
(
    input wire clk,rst_n,//50MHz，低电平复位

    output wire led0, led1, led2, led3
);

breath_led breath_led_inst0
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led0_delay)
);

breath_led breath_led_inst1
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led1_delay)
);

breath_led breath_led_inst2
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led2_delay)
);

breath_led breath_led_inst3
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led3_delay)
);

wire led0_delay, led1_delay, led2_delay, led3_delay;

localparam TIM_DELAY = 12500000;//0.25s

reg [31:0] cnt_delay;//延时计数器
reg [1:0] state;//记录第几个led开始亮起

reg en0, en1, en2, en3;//enable signal使能信号，高电平有效

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
	 begin
        	 cnt_delay<=32'd0;
			 state<=2'd0;
			 en0<=1'b0;
			 en1<=1'b0;
			 en2<=1'b0;
			 en3<=1'b0;
	 end
	 else begin
	         case(state)
				0:begin
				      en0 <= 1'b1;
				    if(cnt_delay==TIM_DELAY-1'b1)
				        begin
				    	     cnt_delay<=32'd0;
			               state<=state+1'd1;
				    	 end
				    else cnt_delay<=cnt_delay+1'd1;
				end
				1:begin
				      en1 <= 1'b1;
				    if(cnt_delay==TIM_DELAY-1'b1)
				        begin
				    	     cnt_delay<=32'd0;
			               state<=state+1'd1;
				    	 end
				    else cnt_delay<=cnt_delay+1'd1;
				end
				2:begin
				      en2 <= 1'b1;
				    if(cnt_delay==TIM_DELAY-1'b1)
				        begin
				    	     cnt_delay<=32'd0;
			               state<=state+1'd1;
				    	 end
				    else cnt_delay<=cnt_delay+1'd1;
				end
				default :begin
				      en3 <= 1'b1;
				    if(cnt_delay==TIM_DELAY-1'b1)
				        begin
				    	     cnt_delay<=32'd0;
			               state<=1'd0;
				    	 end
				    else cnt_delay<=cnt_delay+1'd1;
				end
			 endcase
	     end
end 


assign led0=(en0)? led0_delay : 1'b1;
assign led1=(en1)? led1_delay : 1'b1;
assign led2=(en2)? led2_delay : 1'b1;
assign led3=(en3)? led3_delay : 1'b1;
endmodule
