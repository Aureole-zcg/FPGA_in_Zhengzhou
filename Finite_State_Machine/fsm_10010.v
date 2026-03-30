module fsm_10010
(
    input wire clk, rst_n, data_in,
    output reg flag
);

//状态编码 Moore
parameter idle = 4'd0;
parameter s0 = 4'd1;
parameter s1 = 4'd2;
parameter s2 = 4'd3;
parameter s3 = 4'd4;
parameter s4 = 4'd5;

reg [3:0] state;

//状态机描述 三种描述方式 ，一段式，二段式，三段式
//一段式：一个always语块，使用时序逻辑既描述状态转移又描述输出逻辑
/*
always @ (posedge clk, negedge rst_n)
begin
    if (~rst_n)
    begin
        state <= idle ;
        flag <= 1'b0;
    end
    else case (state)
        idle: begin
            if (data_in == 1'b1)
                state <= s0;
            else
                state <= idle;
            flag <= 1'b0;
            end

        s0: begin
            if (data_in == 1'b0)
                state <= s1;
            else
                state <= s0;
            flag <= 1'b0;
            end

        s1: begin
            if (data_in == 1'b0)
                state <= s2;
            else
                state <= s0;
            flag <= 1'b0;
            end

        s2: begin
            if (data_in == 1'b1)
                state <= s3;
            else
                state <= idle;
            flag <= 1'b0;
            end

        s3: begin
            if (data_in == 1'b0)
                state <= s4;
            else
                state <= s0;
            flag <= 1'b0;
            end

        s4: begin
            if (data_in == 1'b0)
                state <= s2;
            else
                state <= s0;
            flag <= 1'b1;
            end

        default: begin
            state <= idle;
            flag <= 1'b0;
            end
    endcase
end
*/


//二段式状态机
/*
第一段：时序逻辑描述状态转移
第二段：组合逻辑描述输出（时序允许的情况，仍可选择时序逻辑）
*/
/*
always @ (posedge clk, negedge rst_n)//复制过来删掉输出
begin
    if (~rst_n)
        state <= idle ;
    else case (state)
        idle: begin
            if (data_in == 1'b1)
                state <= s0;
            else
                state <= idle;
            end

        s0: begin
            if (data_in == 1'b0)
                state <= s1;
            else
                state <= s0;
            end

        s1: begin
            if (data_in == 1'b0)
                state <= s2;
            else
                state <= s0;
            end

        s2: begin
            if (data_in == 1'b1)
                state <= s3;
            else
                state <= idle;
            end

        s3: begin
            if (data_in == 1'b0)
                state <= s4;
            else
                state <= s0;
            end

        s4: begin
            if (data_in == 1'b0)
                state <= s2;
            else
                state <= s0;
            end

        default: begin
            state <= idle;
            end
    endcase
end

always @ (*)//组合逻辑，只写输出
begin
    if (~rst_n)
        flag = 1'b0;
    else if (state == s4)
        flag = 1'b1;
    else
        flag = 1'b0;
end
*/

//三段式
/*
第一段：时序逻辑描述状态更新，把次态（下一状态）更新到现态
第二段：组合逻辑根据现态及输入判断次态
第三段：时序逻辑描述输出
*/

reg [3:0] state_now, state_next;

always @ (posedge clk, negedge rst_n)//满足现态
begin
    if (~rst_n)
        state_now <= idle ;
    else
        state_now <= state_next;
end

always @ (*)//组合逻辑，根据现态判断次态
begin
    if (~rst_n)
        state_next = idle ;
    else case (state_now)
        idle: begin
            if (data_in == 1'b1)
                state_next = s0;
            else
                state_next = idle;
            end

        s0: begin
            if (data_in == 1'b0)
                state_next = s1;
            else
                state_next = s0;
            end

        s1: begin
            if (data_in == 1'b0)
                state_next = s2;
            else
                state_next = s0;
            end

        s2: begin
            if (data_in == 1'b1)
                state_next = s3;
            else
                state_next = idle;
            end

        s3: begin
            if (data_in == 1'b0)
                state_next = s4;
            else
                state_next = s0;
            end

        s4: begin
            if (data_in == 1'b0)
                state_next = s2;
            else
                state_next = s0;
            end

        default: begin
            state_next = idle;
            end
    endcase
end

always @ (posedge clk, negedge rst_n)//时序逻辑，只写输出
begin
    if (~rst_n)
        flag = 1'b0;
    else if (state_next == s4)
        flag = 1'b1;
    else
        flag = 1'b0;
end

endmodule
