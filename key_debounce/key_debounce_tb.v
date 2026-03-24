`timescale 1ns/1ps
module key_debounce_tb();
reg key_in, clk, rst_n;

wire key_out;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;
    key_in=1'b1;
    #77
    rst_n=1'b1;
    #100
    key_in=1'b0;//开始按键抖动
    #138
    key_in=1'b1;
    #10
    key_in=1'b0;
    #1000
    key_in=1'b1;
    #134679
    key_in=1'b0;
    #2587
    key_in=1'b1;
    #134
    key_in=1'b0;//按键按下第一次
    #30000000
    key_in=1'b1;
    #134679
    key_in=1'b0;
    #1000
    key_in=1'b1;
    #7964
    key_in=1'b0;//按键按下第二次
    #35000000
    key_in=1'b1;
    #7964
    key_in=1'b1;
end

always #10 clk=~clk;

key_debounce
#(
    .Debounce_TIME(20000000)//消抖信号20ms
)
key_debounce_inst
(
    . key_in(key_in),
    . clk(clk),
    . rst_n(rst_n),

    . key_out(key_out)
);

endmodule
