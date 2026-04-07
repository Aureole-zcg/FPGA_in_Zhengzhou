module ram_test6
(
    input wire clk, rst_n, 

    output wire [7:0] q_a, q_b
);

reg       wren_a, wren_b;
reg [7:0] addr_a, addr_b;
reg [7:0] data_a, data_b;

ram8x256	ram8x256_inst (
	.address_a ( addr_a ),
	.address_b ( addr_b ),
	.clock     ( clk    ),
	.data_a    ( data_a ),
	.data_b    ( data_b ),
	.wren_a    ( wren_a ),
	.wren_b    ( wren_b ),
	.q_a       ( q_a    ),
	.q_b       ( q_b    )
	);

reg [9:0] cnt;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt <= 10'd0;
    else cnt <= cnt + 1'b1;
end

//读写时序
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        wren_a <=1'd0;
        addr_a <=8'd0;
        data_a <=8'd0;

        wren_b <=1'd0;
        addr_b <=8'd0;
        data_b <=8'd0;
    end
    else if (cnt == 10'd1)//a、b都写入数据 //不能同地址同时写入
        begin
            wren_a <=1'd1;
            addr_a <=8'd2;
            data_a <=8'd2;
    
            wren_b <=1'd1;
            addr_b <=8'd3;
            data_b <=8'd7;
        end
        else if (cnt == 10'd2)//a写b读
            begin
                wren_a <=1'd1;
                addr_a <=8'd4;
                data_a <=8'd8;
        
                wren_b <=1'd0;//读数据
                addr_b <=8'd3;
                data_b <=8'd0;//don't care
            end 
            else if (cnt == 10'd2)//a读b读
                begin
                    wren_a <=1'd0;//读数据
                    addr_a <=8'd3;
                    data_a <=8'd0;//don't care
            
                    wren_b <=1'd0;//读数据
                    addr_b <=8'd4;
                    data_b <=8'd0;//don't care
                end 
                else if (cnt >= 10'd10 && cnt <= 10'd19)//a,b连续写
                    begin
                        wren_a <=1'd1;
                        addr_a <=cnt;
                        data_a <=cnt;
                
                        wren_b <=1'd1;
                        addr_b <=cnt + 10'd5;//15~24
                        data_b <=cnt;
                    end 
                    else if ( cnt >= 10'd30 && cnt <= 10'd39)//连续读
                        begin
                            wren_a <=1'd0;
                            addr_a <=cnt - 10'd20;
                            data_a <=8'd0;//don't care
                    
                            wren_b <=1'd0;
                            addr_b <=cnt - 10'd15;
                            data_b <=8'd0;//don't care
                        end
                        else begin
                                wren_a <=1'd0;
                                addr_a <=8'd0;
                                data_a <=8'd0;

                                wren_b <=1'd0;
                                addr_b <=8'd0;
                                data_b <=8'd0;
                            end
end

endmodule
