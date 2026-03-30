module coke
#(
    parameter idle = 3'd0,
    parameter s0   = 3'd1,//0.5
    parameter s1   = 3'd2,//1.0
    parameter s2   = 3'd3,//1.5
    parameter s3   = 3'd4,//2.0
    parameter s4   = 3'd5,//2.5
    parameter s5   = 3'd6//3.0
)
(
    input wire clk, rst_n, 
	 input wire [1:0] coin,
    output reg coke, change
);

reg [2:0] state;//状态机状态寄存器
//coin == 1'd0 == 投币0.5元

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    state <= idle;
    else begin
            case (state)
                idle : begin
                    if (coin == 2'd0)//投币0.5元
                    state <= s0;
                    else if (coin == 2'd1)//投币1元
                        state <= s1;
                        else state <= idle;//未投币
                    end

                s0 : begin//0.5
                    if (coin == 2'd0)//投币0.5元
                    state <= s1;
                    else if (coin == 2'd1)//投币1元
                        state <= s2;
                        else state <= s0;//未投币
                    end

                s1 : begin//1.0
                    if (coin == 2'd0)//投币0.5元
                    state <= s2;
                    else if (coin == 2'd1)//投币1元
                        state <= s3;
                        else state <= s1;//未投币
                    end

                s2 : begin//1.5
                    if (coin == 2'd0)//投币0.5元
                    state <= s3;
                    else if (coin == 2'd1)//投币1元
                        state <= s4;
                        else state <= s2;//未投币
                    end

                s3 : begin//2.0
                    if (coin == 2'd0)//投币0.5元
                    state <= s4;
                    else if (coin == 2'd1)//投币1元
                        state <= s5;
                        else state <= s3;//未投币
                    end

                s4 : begin//2.5
                    if (coin == 2'd0)//投币0.5元
                    state <= s0;
                    else if (coin == 2'd1)//投币1元
                        state <= s1;
                        else state <= idle;//未投币
                    end

                s5 : begin//3.0
                    if (coin == 2'd0)//投币0.5元
                    state <= s0;
                    else if (coin == 2'd1)//投币1元
                        state <= s1;
                        else state <= idle;//未投币
                    end
						  
                default: state <= idle;
            endcase
        end
end

always @(*)
begin
    if (~rst_n)
    begin 
        coke <= 1'd0;
        change <= 1'd0;
    end
    else 
    begin
        case (state)
            idle, s0, s1, s2, s3: begin
                coke <= 1'd0;
                change <=1'd0;
            end
            s4: begin
                coke <= 1'd1;//出可乐
                change <=1'd0;//不找零
            end
            s5: begin
                coke <= 1'd1;//出可乐
                change <=1'd1;//找零0.5元
            end
        endcase
    end
end

endmodule
