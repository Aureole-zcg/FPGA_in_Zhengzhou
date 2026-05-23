`timescale 1ns/1ps

module sdram_init_tb();

reg clk_100MHz;
reg rst_n     ;

initial 
begin
    clk_100MHz = 1'b0;
    rst_n      = 1'b0;
    #77
    rst_n      = 1'b1;
end

always #5 clk_100MHz = ~clk_100MHz;//100MHz T=10ns

sdram_init sdram_init_inst
(
    .clk_100MHz(clk_100MHz),
    .rst_n(rst_n)
);
endmodule
