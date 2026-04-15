//轮询检测fifo，打包输出1024Byte数据
module top_test
(
    input wire clk_20MHz ,
               clk_15MHz ,
               clk_50MHz ,
               clk_100MHz,
               rst_n     ,

    output reg [63:0] package_data,
    output reg        data_valid
);

reg rdreq_20MHz, rdreq_15MHz, rdreq_50MHz, rdreq_100MHz;
wire [63:0] q_out_20MHz;
wire [12:0] rdusedw_20MHz;
test_fifo test_fifo_20MHz
(
    . wrclk(clk_20MHz),
    . rdclk(clk_100MHz),
    . rst_n(rst_n),
    . rdreq(rdreq_20MHz),

    . q(q_out_20MHz),
    .rdusedw(rdusedw_20MHz)
);

wire [63:0] q_out_15MHz;
wire [12:0] rdusedw_15MHz;
test_fifo test_fifo_15MHz
(
    . wrclk(clk_15MHz),
    . rdclk(clk_100MHz),
    . rst_n(rst_n),
    . rdreq(rdreq_15MHz),

    . q(q_out_15MHz),
    .rdusedw(rdusedw_15MHz)
);

wire [63:0] q_out_50MHz;
wire [12:0] rdusedw_50MHz;
test_fifo test_fifo_50MHz
(
    . wrclk(clk_50MHz),
    . rdclk(clk_100MHz),
    . rst_n(rst_n),
    . rdreq(rdreq_50MHz),

    . q(q_out_50MHz),
    .rdusedw(rdusedw_50MHz)
);

wire [63:0] q_out_100MHz;
wire [12:0] rdusedw_100MHz;
test_fifo test_fifo_100MHz
(
    . wrclk(clk_100MHz),
    . rdclk(clk_100MHz),
    . rst_n(rst_n),
    . rdreq(rdreq_100MHz),

    . q(q_out_100MHz),
    .rdusedw(rdusedw_100MHz)
);


reg [2:0] state;
parameter idle = 3'd0;
parameter s0 = 3'd1;
parameter s1 = 3'd2;
parameter s2 = 3'd3;
parameter s3 = 3'd4;
parameter s4 = 3'd5;
reg [2:0] num_fifo;
reg [7:0] cnt_B;//1024Byte==128*64bit

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        cnt_B <= 8'd0;
    else if (cnt_B == 8'd138 || num_fifo == 3'd0)
            cnt_B <= 8'd0;
        else if (num_fifo > 3'd0)
                cnt_B <= cnt_B + 1'b1;
                else cnt_B <= cnt_B;
end

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
    begin
        state <= idle;
        num_fifo <= 3'd0;
    end
    else 
    begin case(state)
        idle : begin
            state <= s0;
            num_fifo <= 3'd0;
        end
        
        s0 : begin
            if (rdusedw_20MHz < 13'd128)
                state <= s1;
            else begin
                    state <= s4;
                    num_fifo <= 3'd1;
                end
        end

        s1 : begin
            if (rdusedw_15MHz < 13'd128)
                state <= s2;
            else begin
                    state <= s4;
                    num_fifo <= 3'd2;
                end
        end

        s2 : begin
            if (rdusedw_50MHz < 13'd128)
                state <= s3;
            else begin
                    state <= s4;
                    num_fifo <= 3'd3;
                end
        end

        s3 : begin
            if (rdusedw_100MHz < 13'd128)
                state <= s0;
            else begin
                    state <= s4;
                    num_fifo <= 3'd4;
                end
        end

        s4 : if (cnt_B == 8'd129)//rdreq将要读最后一个打包值
        begin
            if (num_fifo <= 3'd1)
                state <= s1;
            else if (num_fifo <= 3'd2)
                    state <= s2;
                else if (num_fifo <= 3'd3)
                        state <= s3;
                    else if (num_fifo <= 3'd4)
                            state <= s0;
                            else state <= idle;
        end

        default : state <= idle;
        endcase

        if (cnt_B == 8'd129)//晚一位置零num_fifo，使rdreq只受制于cnt_B
            num_fifo <= 3'd0;
    end
end



reg rdreq_D_20MHz, rdreq_D_15MHz, rdreq_D_50MHz, rdreq_D_100MHz;

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
    begin
        
        
        rdreq_20MHz <= 1'b0;
        rdreq_15MHz <= 1'b0;
        rdreq_50MHz <= 1'b0;
        rdreq_100MHz<= 1'b0;
        rdreq_D_20MHz<= 1'b0;
        rdreq_D_15MHz<= 1'b0;
        rdreq_D_50MHz<= 1'b0;
        rdreq_D_100MHz<= 1'b0;

    end
    else //if (cnt_B >= 1'b1 && cnt_B <= 8'd128)
            begin
                if (num_fifo == 3'd1)
                
                begin
                    if (cnt_B >= 1'b1 && cnt_B <= 8'd128)
                        rdreq_20MHz <= 1'b1;
                    else rdreq_20MHz <= 1'b0;
                   //package_data <= q_out_20MHz;
                   
                   //data_valid <= rdreq_D;
                   rdreq_D_20MHz <= rdreq_20MHz;
                end
                else rdreq_D_20MHz <= rdreq_20MHz;//延迟不受状态机控制
                
                if (num_fifo == 3'd2)
                begin
                    if (cnt_B >= 1'b1 && cnt_B <= 8'd128)
                        rdreq_15MHz <= 1'b1;
                    else rdreq_15MHz <= 1'b0;
                   //package_data <= q_out_15MHz;
                   
                   //data_valid <= rdreq_D;
                   rdreq_D_15MHz <= rdreq_15MHz;
                end
                else rdreq_D_15MHz <= rdreq_15MHz;//延迟不受状态机控制

                if (num_fifo == 3'd3)
                begin
                    if (cnt_B >= 1'b1 && cnt_B <= 8'd128)
                        rdreq_50MHz <= 1'b1;
                    else rdreq_50MHz <= 1'b0;
                   //package_data <= q_out_50MHz;
                   
                   //data_valid <= rdreq_D;
                   rdreq_D_50MHz <= rdreq_50MHz;
                end
                else rdreq_D_50MHz <= rdreq_50MHz;//延迟不受状态机控制
                
                if (num_fifo == 3'd4)
                begin
                    if (cnt_B >= 1'b1 && cnt_B <= 8'd128)
                        rdreq_100MHz <= 1'b1;
                    else rdreq_100MHz <= 1'b0;
                   //package_data <= q_out_100MHz;
                   
                   //data_valid <= rdreq_D;
                   rdreq_D_100MHz <= rdreq_100MHz;
                end
                else rdreq_D_100MHz <= rdreq_100MHz;//延迟不受状态机控制
            end
        //else begin
        //    //package_data <= 64'd0;
        //    //data_valid <= 1'b0;
        //    rdreq_20MHz <= 1'b0;
        //    rdreq_15MHz <= 1'b0;
        //    rdreq_50MHz <= 1'b0;
        //    rdreq_100MHz<= 1'b0;
        //    rdreq_D<= 1'b0;
        //end
end

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
    begin
        package_data <= 64'd0;
        data_valid <= 1'b0;
    end
    else 
    begin 
        if (rdreq_D_20MHz == 1'b1)
            begin
                package_data <= q_out_20MHz;
                data_valid <= rdreq_D_20MHz;
            end
            
        
        else if (rdreq_D_15MHz == 1'b1)
                begin
                    package_data <= q_out_15MHz;
                    data_valid <= rdreq_D_15MHz;
                end
                
            
            else if (rdreq_D_50MHz == 1'b1)
                    begin
                        package_data <= q_out_50MHz;
                        data_valid <= rdreq_D_50MHz;
                    end
                    
                
                else if (rdreq_D_100MHz == 1'b1)
                        begin
                            package_data <= q_out_100MHz;
                            data_valid <= rdreq_D_100MHz;
                        end
                        
                    
                    else begin
                        package_data <= 64'd0;
                        data_valid <= 1'b0;
                    end
        end
end

endmodule
