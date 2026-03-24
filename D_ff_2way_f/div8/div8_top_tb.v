`timescale 1ns/1ps

module div8_top_tb();

reg clk;
reg rst_n;
wire div8_clk_6_25MHz;

initial
begin
    clk=1'b0;
    rst_n=1'b0;
    #77
    rst_n=1'b1;
end

always #10 clk=~clk;


div8_top div8_top_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .div8_clk_6_25MHz(div8_clk_6_25MHz)
);
endmodule
