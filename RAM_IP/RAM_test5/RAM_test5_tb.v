`timescale 1ns/1ps

module RAM_test5_tb();

reg       clk   ; 
reg       wren  ; 
reg [4:0] wraddr; 
reg [3:0] data ;
reg       rden  ; 
reg [4:0] rdaddr; 
reg       rst_n ;

wire [3:0] q;

initial begin
    clk    = 1'b0;
    wren   = 1'b0;
    wraddr = 5'b0;
    data   = 4'd0;
    rden   = 1'b0;
    rdaddr = 5'b0;
    rst_n  = 1'b0;
    #77
    rst_n  = 1'b1;
end

always #10 clk = ~clk;//50MHZ T=20ns

reg [7:0] cnt;//cnt:0~127

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    cnt <= 10'd0;
    else if(cnt == 10'd127)
        cnt <= 10'd33;
    else cnt <= cnt + 1'b1;
end

always @(posedge clk, negedge rst_n) //正序写入
begin
    if (~rst_n)
    begin
        wren   <= 1'b0;
        wraddr <= 5'b0;
        data   <= 4'd0;
    end
    else if (cnt >= 10'd1 && cnt <= 10'd32)
        begin
            wren <= 1'b1;//写入
            wraddr <= cnt - 1'd1;//0~31
            data <= {$random}%32;//0~31的随机数
        end
        else 
            begin
                wren   <= 1'b0;
                wraddr <= 5'b0;
                data   <= 4'd0;
            end
end

//倒序地址输出
//写采用一起写，读采用拆开写
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rden <= 1'b0;
    else if (cnt >= 10'd33 && cnt <= 10'd64)//33~64
        rden <= 1'b1;//读取
        else rden <= 1'b0;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rdaddr <= 10'd0;
    else begin
        if(cnt >= 10'd33 && cnt <= 10'd48)//16~31
        rdaddr <= cnt - 10'd17;//自加读取，溢出清零
            else if(cnt >= 10'd49 && cnt <= 10'd64)//0~15
            rdaddr <= cnt - 10'd49;//自加读取，溢出清零
                else rdaddr <= 10'd0;
    end
    
end

RAM_test5 RAM_test5_inst
( 
    . wren  (wren  ), 
    . wraddr(wraddr), 
    . data  (data  ),
    . clk   (clk   ), 
    . rden  (rden  ), 
    . rdaddr(rdaddr), 
    . rst_n (rst_n ),
    
    .  q(q)
);
endmodule
