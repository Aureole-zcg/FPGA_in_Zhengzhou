`timescale 1ns/1ps

module A7_LED_tb();

reg clk;
reg rst_n;

initial
begin
    clk=1'b0;
    rst_n=1'b0;//绯荤粺澶嶄綅
    #77
    rst_n=1'b1;//绯荤粺姝ｅ父
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//鑾峰彇鍛ㄦ湡绋冲畾闇囪崱鐨勬椂閽熶俊鍙?

A7_LED 
#(
    . MAX_1S     (50_000_000), //50MHz T=20ns 50_000_000*20ns=1s
    . SIM_MAX_1S (50        )//for sim
) A7_LED_inst
(
    .clk(clk),
    .rst_n(rst_n)

    
);
endmodule
