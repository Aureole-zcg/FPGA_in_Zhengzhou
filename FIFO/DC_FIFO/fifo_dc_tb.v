`timescale 1ns/1ps

module fifo_dc_tb();

reg wrclk;
reg rdclk;
reg rst_n;

initial
begin
    wrclk=1'b0;
    rdclk=1'b0;
    rst_n=1'b0;
    #77
    rst_n=1'b1;
end

always #10 wrclk=~wrclk;
always #20 rdclk=~rdclk;

fifo_dc fifo_dc_inst
(
    . wrclk(wrclk),
    . rdclk(rdclk),
    . rst_n(rst_n),

    . q()
);
endmodule