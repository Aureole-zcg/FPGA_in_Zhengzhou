`timescale 1ns/1ps

module top_tb();

reg        clk  ;
reg        rst_n;
reg [15:0] DATA ;
reg        wrreq;


initial begin
    clk <= 1'b0;
    rst_n <= 1'b0;
    #77
    rst_n <= 1'b1;
end

always #10 clk=~clk;//50MHz T=20ns

reg [11:0] cnt;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 12'd0;
    else cnt <= cnt + 1'b1;//溢出清零
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        wrreq <= 1'b0;
        DATA <= 16'd0;
    end
    else if (cnt<=12'd2047)
    begin
        wrreq <= 1'b1;
        DATA <=cnt;//0~2047
    end
    else begin
        wrreq <= 1'b0;
        DATA <= 16'd0;
    end
end

FIFO_TEST_top FIFO_TEST_top_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),
    . DATA (DATA ),
	 . wrreq(wrreq),

    . q_reverse(),
    . q_max    (),
    . addr_max (),
    . q_fft    ()
);
endmodule