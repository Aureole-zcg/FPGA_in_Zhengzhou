module more_led_breath_top
(
    input wire clk,rst_n,//50MHz，低电平复位

    output wire led0, led1, led2, led3
);

wire [31:0] delay1=32'd30_000_000;//0.5s
wire [31:0] delay2=32'd60_000_000;//1.0s
wire [31:0] delay3=32'd120_000_000;//1.5s


breath_led breath_led_inst0
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led0)
);

breath_led_delay breath_led_delay_inst1
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位
    .delay(delay1),

    .led_out(led1)
);

breath_led_delay breath_led_delay_inst2
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位
    .delay(delay2),

    .led_out(led2)
);

breath_led_delay breath_led_delay_inst3
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位
    .delay(delay3),

    .led_out(led3)
);




endmodule
