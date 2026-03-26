module breath_led_1and2s_top
(
    input wire clk,rst_n,//50MHz，低电平复位

    output wire led0, led1, led2, led3
);

breath_led breath_led_inst1s
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led0)
);

breath_led_2s breath_led_2s_inst2s
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led1)
);

breath_led_4s_v1 breath_led_4s_v1_inst4s
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led2)
);

breath_led_4s_v2 breath_led_4s_v2_inst4s
(
    .clk(clk),
    .rst_n(rst_n),//50MHz，低电平复位

    .led_out(led3)
);
endmodule
