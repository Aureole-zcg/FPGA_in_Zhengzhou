`timescale 1ns/1ps

module coke_tb();
reg clk, rst_n;
reg [1:0]coin;
wire coke, change;

initial
begin
    clk = 1'b0;
    rst_n = 1'b0;
	 coin = 1'b0;
    #77
    rst_n = 1'b1;
end

always #10 clk = ~clk;//50MHz T=20ns
always #20 coin = {$random}%3;

coke
#(
    . idle (3'd0),
    . s0   (3'd1),//0.5
    . s1   (3'd2),//1.0
    . s2   (3'd3),//1.5
    . s3   (3'd4),//2.0
    . s4   (3'd5),//2.5
    . s5   (3'd6) //3.0
)
coke_inst
(
    . clk(clk), 
    . rst_n(rst_n), 
    . coin(coin),
    . coke(coke), 
    . change(change)
);

endmodule
