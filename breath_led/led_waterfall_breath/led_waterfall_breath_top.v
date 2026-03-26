module led_waterfall_breath_top
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

waterfall_light_port
#(
    .CNT_MAX(400_000_000)
)
waterfall_light_port_inst
(
    .clk(clk),
    .rst_n(rst_n),
    .led_in0(led0_delay), 
	 .led_in1(led1_delay), 
	 .led_in2(led2_delay), 
	 .led_in3(led3_delay), 

    .led0(led0),
	 .led1(led1),
	 .led2(led2),
	 .led3(led3)
);
endmodule
