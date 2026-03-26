module rise_fall_tb();
    reg clk, rst_n, A;
    wire Y;

initial begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号
always #77 A={$random}%2;

rise_fall rise_fall_inst
(
    .clk(clk), 
    .rst_n(rst_n), 
    .A(A),
    .Y(Y)
);

endmodule
