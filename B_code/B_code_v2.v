module B_code_v2
#(
    parameter TIME_8MS = 32'd999_999,
    parameter TIME_5MS = 32'd624_999,
    parameter TIME_2MS = 32'd249_999,
    parameter error = 32'd1000//±8us误差
)
(
    input wire clk, rst_n, B_code_in,

    output reg [3:0] second_ones  ,
    output reg [2:0] second_tens  ,
    output reg [3:0] minute_ones  ,
    output reg [2:0] minute_tens  ,
    output reg [3:0] hour_ones    ,
    output reg [1:0] hour_tens    ,
    output reg [3:0] day_ones     ,
    output reg [3:0] day_tens     ,
    output reg [1:0] day_hundreds ,
    output reg [3:0] year_ones    ,
    output reg [3:0] year_tens    
);

reg [31:0] cnt_b;
reg fall_0;//用于确定当前码元类型（now_type）
reg fall_1;//同时有锁定的码元类型（latch_type）和当前码元类型（now_type），用于开始信号双p检测
reg fall_2;//更新锁定的上一个码元信息（latch_type）
reg fall_3;//用于定位一帧数据中当前码元对应的序号
reg fall_4;//用于完成当前码元的时间信息解析
reg fall_5;//用于全部解析完成的整体输出
reg fall_6;//预留
reg fall_7;//用于高电平计数器计数值的清零（高电平计数器：计数高电平保持时常确定码元）
reg B_code_in_0;
reg B_code_in_1;
reg B_code_in_2;
reg [1:0] now_type;
reg [1:0] latch_type;
reg work_state;
reg [7:0] cnt_mem;

//B码打拍消除亚稳态，边沿检测
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        B_code_in_0 <= 1'b0;
        B_code_in_1 <= 1'b0;
        B_code_in_2 <= 1'b0;
        fall_0 <= 1'b0;
        fall_1 <= 1'b0;
        fall_2 <= 1'b0;
        fall_3 <= 1'b0;
        fall_4 <= 1'b0;
        fall_5 <= 1'b0;
        fall_6 <= 1'b0;
        fall_7 <= 1'b0;
    end
    else begin
        B_code_in_0 <= B_code_in;
        B_code_in_1 <= B_code_in_0;
        B_code_in_2 <= B_code_in_1;
        fall_0 <= (~B_code_in_1) & B_code_in_2;//fall_0在B码下降沿时产生一个时钟周期的高电平，用于确定当前码元类型（now_type）
        fall_1 <= fall_0;
        fall_2 <= fall_1;
        fall_3 <= fall_2;
        fall_4 <= fall_3;
        fall_5 <= fall_4;
        fall_6 <= fall_5;
        fall_7 <= fall_6;
    end
end

//cnt_b：高电平计数器
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_b <= 32'd0;
    else if (fall_7)
        cnt_b <= 32'd0;
        else if (B_code_in_2)
            cnt_b <= cnt_b + 1'b1;
            else cnt_b <= cnt_b;
end

//now_type：存储当前码元类型
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    now_type <= 2'b11;//00:0  01:1  10:P  11:空闲
    else if (fall_0 && TIME_8MS - error <= cnt_b && cnt_b <= TIME_8MS + error)
        now_type <= 2'b10;
        else if (fall_0 && TIME_5MS - error <= cnt_b && cnt_b <= TIME_5MS + error)
        now_type <= 2'b01;
            else if (fall_0 && TIME_2MS - error <= cnt_b && cnt_b <= TIME_2MS + error)
            now_type <= 2'b00;
                else if (fall_0)
                now_type <= 2'b11;
                    else now_type <= now_type;
end   

//latch_type: 锁定码元类型
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    latch_type <= 2'b11;//00:0  01:1  10:P  11:空闲
    else if (fall_2)
        latch_type <= now_type;
        else latch_type <= latch_type;
end

//work_state: 双P检测
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    work_state <= 1'b0;
    else if (fall_1 && now_type== 2'b10 && latch_type == 2'b10)
        work_state <= 1'b1;
        else if (cnt_mem == 8'd61)
            work_state <= 1'b0;
            else work_state <= work_state;
end

//cnt_men：码元序号计数器
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_mem <= 8'd0;
    else if (~work_state)
        cnt_mem <= 8'd0;
        else if (fall_3)
            cnt_mem <= cnt_mem + 1'b1;
            else cnt_mem <= cnt_mem;
end

//提取时间信息
reg [3:0] second_ones_r  ;
reg [2:0] second_tens_r  ;
reg [3:0] minute_ones_r  ;
reg [2:0] minute_tens_r  ;
reg [3:0] hour_ones_r    ;
reg [1:0] hour_tens_r    ;
reg [3:0] day_ones_r     ;
reg [3:0] day_tens_r     ;
reg [1:0] day_hundreds_r ;
reg [3:0] year_ones_r    ;
reg [3:0] year_tens_r    ;

//second_ones 2~5
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    second_ones_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd2 && cnt_mem <= 8'd5)
        second_ones_r <= {now_type[0],second_ones_r[3:1]};
        else second_ones_r <= second_ones_r;
end

//second_tens 7~9
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    second_tens_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd7 && cnt_mem <= 8'd9)
        second_tens_r <= {now_type[0],second_tens_r[2:1]};
        else second_tens_r <= second_tens_r;
end

//minute_ones 11~14
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    minute_ones_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd11 && cnt_mem <= 8'd14)
        minute_ones_r <= {now_type[0],minute_ones_r[3:1]};
        else minute_ones_r <= minute_ones_r;
end

//minute_tens 16~18
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    minute_tens_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd16 && cnt_mem <= 8'd18)
        minute_tens_r <= {now_type[0],minute_tens_r[2:1]};
        else minute_tens_r <= minute_tens_r;
end

//hour_ones 21~24
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    hour_ones_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd21 && cnt_mem <= 8'd24)
        hour_ones_r <= {now_type[0],hour_ones_r[3:1]};
        else hour_ones_r <= hour_ones_r;
end

//hour_tens 26~27
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    hour_tens_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd26 && cnt_mem <= 8'd27)
        hour_tens_r <= {now_type[0],hour_tens_r[1]};
        else hour_tens_r <= hour_tens_r;
end

//day_ones 31~34
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    day_ones_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd31 && cnt_mem <= 8'd34)
        day_ones_r <= {now_type[0],day_ones_r[3:1]};
        else day_ones_r <= day_ones_r;
end

//day_tens 36~39
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    day_tens_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd36 && cnt_mem <= 8'd39)
        day_tens_r <= {now_type[0],day_tens_r[3:1]};
        else day_tens_r <= day_tens_r;
end

//day_hundreds 41~42
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    day_hundreds_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd41 && cnt_mem <= 8'd42)
        day_hundreds_r <= {now_type[0],day_hundreds_r[1]};
        else day_hundreds_r <= day_hundreds_r;
end

//year_ones 51~54
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    year_ones_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd51 && cnt_mem <= 8'd54)
        year_ones_r <= {now_type[0],year_ones_r[3:1]};
        else year_ones_r <= year_ones_r;
end

//year_tens 56~59
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    year_tens_r <= 4'd0;
    else if (fall_4 && cnt_mem >= 8'd56 && cnt_mem <= 8'd59)
        year_tens_r <= {now_type[0],year_tens_r[3:1]};
        else year_tens_r <= year_tens_r;
end


/*
always @(posedge clk, negedge rst_n)//另一种读取由低到高发送的数据 的方法
begin
    if (~rst_n)
    begin
        second_ones  <=4'd0;
        second_tens  <=3'd0;
        minute_ones  <=4'd0;
        minute_tens  <=3'd0;
        hour_ones    <=4'd0;
        hour_tens    <=2'd0;
        day_ones     <=4'd0;
        day_tens     <=4'd0;
        day_hundreds <=2'd0;
        year_ones    <=4'd0;
        year_tens    <=4'd0;
    end
	 else if (fall_4)
	     begin
		      case (cnt_mem)
				8'd1: second_ones[0] <= now_type[0];//只要now_type的最后一位0/1
				8'd2: second_ones[1] <= now_type[0];
				8'd3: second_ones[2] <= now_type[0];
				8'd4: second_ones[3] <= now_type[0];
				//依次往下……
				
				endcase
		  end
		  else begin
            second_ones  <= second_ones;
            second_tens  <= second_tens;
            minute_ones  <= minute_ones;
            minute_tens  <= minute_tens;
            hour_ones    <= hour_ones;
            hour_tens    <= hour_tens;
            day_ones     <= day_ones;
            day_tens     <= day_tens;
            day_hundreds <= day_hundreds;
            year_ones    <= year_ones;
            year_tens    <= year_tens;
        end
	 


end
*/

//统一输出
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        second_ones  <=4'd0;
        second_tens  <=3'd0;
        minute_ones  <=4'd0;
        minute_tens  <=3'd0;
        hour_ones    <=4'd0;
        hour_tens    <=2'd0;
        day_ones     <=4'd0;
        day_tens     <=4'd0;
        day_hundreds <=2'd0;
        year_ones    <=4'd0;
        year_tens    <=4'd0;
    end
    else if (fall_5 && cnt_mem ==8'd60)//解码完1s整个帧再输出
        begin
            second_ones <=second_ones_r;//倒序整理后，再加权计算
            second_tens <=second_tens_r;
            minute_ones <=minute_ones_r;
            minute_tens <=minute_tens_r;
            hour_ones   <=hour_ones_r;
            hour_tens   <=hour_tens_r;
            day_ones    <=day_ones_r;
            day_tens    <=day_tens_r;
            day_hundreds<=day_hundreds_r;
            year_ones   <=year_ones_r;
            year_tens   <=year_tens_r;
        end
        else begin
            second_ones  <= second_ones;
            second_tens  <= second_tens;
            minute_ones  <= minute_ones;
            minute_tens  <= minute_tens;
            hour_ones    <= hour_ones;
            hour_tens    <= hour_tens;
            day_ones     <= day_ones;
            day_tens     <= day_tens;
            day_hundreds <= day_hundreds;
            year_ones    <= year_ones;
            year_tens    <= year_tens;
        end
end
endmodule
