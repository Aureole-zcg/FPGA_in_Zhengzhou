//在序列检测到需要的帧头信息后，通过状态机采集时间信息，并进行校验和处理
module time_get
(
    input wire clk, rst_n, Y, flag,
    input wire [7:0] data_in,

    output reg [19:0] data_dec
);

parameter idle = 3'd0;
parameter s0 = 3'd1;
parameter s1 = 3'd2;
parameter s2 = 3'd3;
parameter s3 = 3'd4;
parameter s4 = 3'd5;
parameter s5 = 3'd6;

reg [2:0] state;

reg [3:0] cnt_dot   ;//计数","个数
reg [2:0] flag_num;//字段12 后的校验值
reg [7:0] xnor_num  ;//计算异或值
reg xnor_en;//异或使能
reg [7:0] test_value;//gps数据校验值
reg [23:0] data_time;//寄存时间
reg [3:0] time_flag;//计数控制时间字符数量
//reg work_en;//输出时间数据的工作使能

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        xnor_num <= 8'd0;
        xnor_en <= 1'b0;
    end
    else if (state == s5)
            xnor_num <= 8'd0;
        else if (data_in == 8'h2a)
            begin
                xnor_en <= 1'b0;
                xnor_num <= xnor_num;
            end
        else if (Y == 1'b1)
            begin
                xnor_num <=  "G" ^ "P" ^ "R" ^ "M" ^ "C" ^ ",";
                xnor_en <= 1'b1;
            end
            else if (flag == 1'b1 && xnor_en == 1'b1)
                    xnor_num <= xnor_num ^ data_in;
                else if (flag_num == 1'b1)//字段12已经更新
                        xnor_num <= xnor_num;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        state <= idle;
        cnt_dot   <= 4'd0;
        test_value<= 8'd0;
        data_time <= 24'd0;
        time_flag <= 4'd0;
        flag_num <= 3'd0;
    end
    else begin
        case(state)
        0 : begin//idle
            if (Y == 1'b1)
            begin
                state <= s0;
                cnt_dot   <= 4'd0;
                test_value<= 8'd0;
                data_time <= 24'd0;
                time_flag <= 4'd0;
                flag_num <= 3'd0;
            end
            else state <= idle;
        end

        1 : begin//s0
            if (flag == 1'b1 && data_in == 8'h2c)//","
            begin
                cnt_dot <= cnt_dot + 1'b1;//计数 ","
                state <= s1;
            end
        end

        2 : begin//s1
            if (flag == 1'b1)
                time_flag <= time_flag +1'b1;
            if (flag == 1'b1 && data_in == 8'h2c)//","
            begin
                cnt_dot <= cnt_dot + 1'b1;//计数 ","
                state <= s2;
            end
            else if (flag == 1'b1 && time_flag <= 4'd5)//hhmmss.sss格式UTC时间只取前6位
                data_time <={data_time[19:0],data_in[3:0]};
        end

        3 : begin//s2
            if (flag == 1'b1)
            begin
                if (data_in == 8'h2c)//","
                    cnt_dot <= cnt_dot + 1'b1;//计数 ","
                else begin
                    if (data_in == 8'h56)// "V" 状态，A=定位，V=未定位
                        state <= idle;
                end
            end
            else if (cnt_dot == 4'd12)
                    state <= s3;
        end

        4 : begin//s3
            if (flag == 1'b1)
                flag_num <= flag_num +1'b1;//等待校验位
            else if (flag_num == 3'd3)//存储校验位
                    if (data_in == 8'h41)
                            test_value <= {test_value[3:0],4'b1010};
                        else if (data_in == 8'h42)
                            test_value <= {test_value[3:0],4'b1011};
                        else if (data_in == 8'h43)
                            test_value <= {test_value[3:0],4'b1100};
                        else if (data_in == 8'h44)
                            test_value <= {test_value[3:0],4'b1101};
                        else if (data_in == 8'h45)
                            test_value <= {test_value[3:0],4'b1110};
                        else if (data_in == 8'h46)
                            test_value <= {test_value[3:0],4'b1111};
                        else test_value <= {test_value[3:0],data_in[3:0]};
                else if (flag_num == 3'd4)//存储校验位
                    begin
                        if (data_in == 8'h41)
                        begin
                            test_value <= {test_value[3:0],4'b1010};
                            state <= s4;
                        end
                        else if (data_in == 8'h42)
                        begin
                            test_value <= {test_value[3:0],4'b1011};
                            state <= s4;
                        end
                        else if (data_in == 8'h43)
                        begin
                            test_value <= {test_value[3:0],4'b1100};
                            state <= s4;
                        end
                        else if (data_in == 8'h44)
                        begin
                            test_value <= {test_value[3:0],4'b1101};
                            state <= s4;
                        end
                        else if (data_in == 8'h45)
                        begin
                            test_value <= {test_value[3:0],4'b1110};
                            state <= s4;
                        end
                        else if (data_in == 8'h46)
                        begin
                            test_value <= {test_value[3:0],4'b1111};
                            state <= s4;
                        end
                        else begin
                        test_value <= {test_value[3:0],data_in[3:0]};
                        state <= s4;
                        end
                    end
        end

        5 : begin//s4
            if ( xnor_num == test_value)
                state <= s5;
            else state <= idle;
        end

        6 : begin//s5
            state <= idle;
            cnt_dot   <= 4'd0;
            test_value<= 8'd0;
            data_time <= data_time;
            time_flag <= 4'd0;
            flag_num <= 3'd0;
        end
        
        endcase
    end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data_dec <= 20'd0;
    else if (state == s5)
        begin//UTC+8,24H制
            if (data_time[23:20]*17'd100_000+data_time[19:16]*14'd10_000+80_000 >= 240_000)
                data_dec <= data_time[3:0]*1'd1
                       +data_time[7:4]*4'd10
                       +data_time[11:8]*7'd100
                       +data_time[15:12]*10'd1_000
                       +(data_time[19:16]*14'd10_000+80_000)
                       +data_time[23:20]*17'd100_000-240_000;
            else  data_dec <= data_time[3:0]*1'd1
                       +data_time[7:4]*4'd10
                       +data_time[11:8]*7'd100
                       +data_time[15:12]*10'd1_000
                       +(data_time[19:16]*14'd10_000+80_000)
                       +data_time[23:20]*17'd100_000;
        end
end

endmodule
