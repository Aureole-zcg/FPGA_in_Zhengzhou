`timescale 1ns/1ps

module top_tb();

reg clk, rst_n;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    #77
    rst_n =1'b1;
end

always #10 clk=~clk;

defparam top_dynamic_DIG_inst.data_generation_inst.MAX_100ms = 5_000;
defparam top_dynamic_DIG_inst.sel_seg_gen_inst.MAX_1ms = 50;

top_dynamic_DIG top_dynamic_DIG_inst
(
    .clk  (clk  ), 
    .rst_n(rst_n),

    .stcp(), 
    .shcp(), 
    .ds  (), 
    .oe_n()//储存寄存器时钟，移位寄存器时钟，串行数据，输出使能
);

endmodule
