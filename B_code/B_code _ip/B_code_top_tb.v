`timescale 1ns/1ps

module B_code_top_tb();

reg clk; 
reg rst_n; 

initial 
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #100
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号

//仿真加速
defparam B_code_top_inst.B_generation_inst.time_10ms = 32'd1249;
defparam B_code_top_inst.B_generation_inst.time_8ms  = 32'd999;
defparam B_code_top_inst.B_generation_inst.time_5ms  = 32'd624;
defparam B_code_top_inst.B_generation_inst.time_2ms  = 32'd249;
defparam B_code_top_inst.B_code_v2_inst.TIME_8MS = 32'd999;
defparam B_code_top_inst.B_code_v2_inst.TIME_5MS = 32'd624;
defparam B_code_top_inst.B_code_v2_inst.TIME_2MS = 32'd249;
defparam B_code_top_inst.B_code_v2_inst.error = 32'd10;//±8us误差
                                       
B_code_top B_code_top_inst             
(                                     
    .clk(clk), 
    .rst_n(rst_n),
    . second_ones (),
    . second_tens (),
    . minute_ones (),
    . minute_tens (),
    . hour_ones   (),
    . hour_tens   (),
    . day_ones    (),
    . day_tens    (),
    . day_hundreds(),
    . year_ones   (),
    . year_tens   ()
);
endmodule
