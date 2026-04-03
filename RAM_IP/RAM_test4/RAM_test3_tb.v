`timescale 1ns/1ps

module RAM_test3_tb();

reg       clk   ; 
reg       wren  ; 
reg [7:0] wraddr; 
reg [31:0] data ;
reg       rden  ; 
reg [9:0] rdaddr; 
reg       rst_n ;

wire [7:0] q;

initial begin
    clk    = 1'b0;
    wren   = 1'b0;
    wraddr = 8'b0;
    data   = 32'd0;
    rden   = 1'b0;
    rdaddr = 10'b0;
    rst_n  = 1'b0;
    #77
    rst_n  = 1'b1;
end

always #10 clk = ~clk;//50MHZ T=20ns

reg [9:0] cnt;//cnt:0~1023

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    cnt <= 10'd0;
    else cnt <= cnt + 1'b1;//溢出清零
end

always @(posedge clk, negedge rst_n) //正序写入
begin
    if (~rst_n)
    begin
        wren   <= 1'b0;
        wraddr <= 8'b0;
        data   <= 32'd0;
    end
    else if (cnt >= 10'd1 && cnt <= 10'd18)
        begin
            wren <= 1'b1;//写入
            wraddr <= cnt - 10'd1;//0~17
            data <= cnt - 10'd1;//0~17
        end
        else if (cnt >= 10'd20 && cnt <= 10'd28)
            begin
                wren <= 1'b1;//写入
                wraddr <= cnt - 10'd2;//18~26
                data <= cnt - 10'd2;//18~26
            end
            else if (cnt == 10'd29)
                begin
                    wren   <= 1'b1;//写入
                    wraddr <= cnt - 10'd2;//27
                    data   <= 32'd6782;//32'h1A7E//读8'h7E和8'h1A
                end
                else 
					 begin
					      wren   <= 1'b0;
                     wraddr <= 8'b0;
                     data   <= 32'd0;
					 end
end

//倒序地址输出
//写采用一起写，读采用拆开写
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rden <= 1'b0;
    else if (cnt >= 10'd30 && cnt <= 10'd101 ||cnt >= 10'd107 && cnt <= 10'd146)//18*4=72 10*4=40
        rden <= 1'b1;//读取
        else rden <= 1'b0;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rdaddr <= 10'b0;
    else begin 
	 if(rden)
        rdaddr <= rdaddr + 1'b1;//自加读取
		  else rdaddr <= rdaddr;
    if (rdaddr == 10'd112)
	 rdaddr <= 10'b0;
	 
	 end
end

RAM_test3 RAM_test3_inst
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
