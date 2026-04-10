`timescale 1ns/1ps

module fifo_tb();
reg clk, rst_n, wrreq, rdreq;
reg [7:0] data;

initial begin
    clk=1'b0; 
    rst_n=1'b0;
    wrreq=1'b0;
    rdreq=1'b0;
    data=8'd0;
    #77
    rst_n=1'b1;
end

always #10 clk=~clk;
reg [8:0] cnt;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 9'd0;
    else cnt <= cnt + 1'b1;//溢出清零
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        wrreq <= 1'b0;
        data <= 8'd0;
    end
    else if (cnt<=255)
    begin
        wrreq <= 1'b1;
        data <=cnt;
    end
    else begin
        wrreq <= 1'b0;
        data <= 8'd0;
    end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        rdreq <= 1'b0;
    else if (cnt>255)
        rdreq <= 1'b1;
    else 
        rdreq <= 1'b0;
end

fifo fifo_inst
(
    .clk  (clk  ), 
    .rst_n(rst_n), 
    .wrreq(wrreq), 
    .rdreq(rdreq), 
    .data (data ),

    .q()
);
endmodule