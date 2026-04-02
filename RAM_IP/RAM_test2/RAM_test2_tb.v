`timescale 1ns/1ps

module RAM_test2_tb();

reg       wrclk ; 
reg       wren  ; 
reg [7:0] wraddr; 
reg [7:0] data  ;
reg       rdclk ; 
reg       rden  ; 
reg [6:0] rdaddr; 
reg       rst_n ;

wire [15:0] q;

initial begin
    wrclk  = 1'b0;
    wren   = 1'b0;
    wraddr = 8'b0;
    data   = 8'b0;
    rdclk  = 1'b0;
    rden   = 1'b0;
    rdaddr = 7'b0;
    rst_n  = 1'b0;
    #77
    rst_n  = 1'b1;
end

always #10 wrclk = ~wrclk;//50MHZ T=20ns
always #20 rdclk = ~rdclk;//25MHZ T=40ns

reg [9:0] cnt;//cnt:0~1023

always @(posedge wrclk, negedge rst_n)
begin
    if (~rst_n)
    cnt <= 10'd0;
    else cnt <= cnt + 1'b1;//溢出清零
end

always @(posedge wrclk, negedge rst_n) //正序写入
begin
    if (~rst_n)
    begin
        wren   <= 1'b0;
        wraddr <= 8'b0;
        data   <= 8'b0;
    end
    else if (cnt >= 10'd1 && cnt <= 10'd256)
        begin
            wren <= 1'b1;//写入
            wraddr <= cnt - 10'd1;//0~255
            data <= cnt - 10'd1;//0~255
        end
        else begin
            wren   <= 1'b0;
            wraddr <= 8'b0;
            data   <= 8'b0;
        end
end

//倒序地址输出
//写采用一起写，读采用拆开写
always @(posedge rdclk, negedge rst_n) 
begin
    if (~rst_n)
    rden <= 1'b0;
    else if (cnt >= 10'd258 && cnt <= 10'd512)//0~127
        rden <= 1'b1;//读取
        else rden <= 1'b0;
end

always @(posedge rdclk, negedge rst_n) 
begin
    if (~rst_n)
    rdaddr <= 7'b0;
    else if(rden)
        rdaddr <= rdaddr + 1'b1;//自加读取
        //if (cnt >= 10'd258 && cnt <= 10'd512)//另一种写法
        //rdaddr <= cnt/2-129;//读取
        else rden <= 7'b0;
end

RAM_test2 RAM_test2_inst
(
    . wrclk (wrclk ), 
    . wren  (wren  ), 
    . wraddr(wraddr), 
    . data  (data  ),
    . rdclk (rdclk ), 
    . rden  (rden  ), 
    . rdaddr(rdaddr), 
    . rst_n (rst_n ),
    
    .  q(q)
);
endmodule
