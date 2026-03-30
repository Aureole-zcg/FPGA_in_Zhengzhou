module B_code
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

reg [31:0] cnt_MS;//晶振125MHz，MS==125000T
reg [31:0] cnt_10ms;
reg [3:0] cnt_H;//计数有几毫秒高电平
reg [3:0] H_num;//转移和记录高电平总值
reg [7:0] code [99:0];//记录码元
reg [7:0] code_num;//计数具体的码元号
reg [3:0] P_num;//一共11个P
//reg [7:0] Waiting_for_translation[99:0];//调整数据顺序来翻译二进制数
reg B_code_D;//B码在D触发器延迟一个周期，用于触发标志
reg flag_Bcode_Hcode_MS;//标志，对齐B码和毫秒的起始点

parameter MS = 32'd125000;//MS==125000T
parameter CODE_NUM_MAX = 8'd99;//一共100个码元，编号0-99

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    B_code_D<= 1'b0;
    else B_code_D<=B_code_in;//B码在D触发器延迟一个周期，用于触发标志
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    flag_Bcode_Hcode_MS<= 1'b0;
    else if (B_code_in==1'b1 && B_code_D==1'b0)//B码上升沿和D触发器延迟后的信号间产生一个标志位，用于对齐cnt_MS和cnt_10ms
        flag_Bcode_Hcode_MS<= 1'b1;
        else flag_Bcode_Hcode_MS<=1'b0;

end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_MS <= 32'd0;
    else if (flag_Bcode_Hcode_MS==1'b1)
        cnt_MS <= 32'd2;//使用标志位对齐B码和毫秒的起始点
        else if (cnt_MS==MS-1)
            cnt_MS <= 32'd0;
            else cnt_MS <= cnt_MS+1'b1;//定义MS的计数器
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_H<=4'd0;
    else if (B_code_in==1'b0 )
        cnt_H<=4'd0;
        else if (B_code_in==1'b1&&cnt_MS==MS-1)//和ms对齐,1ms计数加1
            cnt_H<=cnt_H+1'b1;//计数B_code_in有几ms高电平，来判断是什么信号值
            else  cnt_H<=cnt_H;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    H_num<=4'd0;
    else if (cnt_H==4'd0 && cnt_MS == MS-1)
         H_num<=4'd0;//清零并传值
         else H_num<=cnt_H;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_10ms <= 32'd0;
    else if (flag_Bcode_Hcode_MS==1'b1)
        cnt_10ms <= 32'd2;//使用标志位对齐B码和毫秒的起始点
        else if (cnt_10ms==MS*10-1)
            cnt_10ms <= 32'd0;
            else cnt_10ms <= cnt_10ms+1'b1;//定义10ms的计数器
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    code_num<=8'd0;
    else if (code_num==CODE_NUM_MAX && cnt_10ms==MS*10-1 || P_num==4'd0)//计数到99个码元清零
        code_num<=8'd0;
        else if (cnt_10ms == MS*10-1)
            code_num <= code_num+1'b1;//每10ms记录一个码元
            else code_num <= code_num;
end


always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    P_num<=4'd0;
    else if (cnt_H==4'd0)
        begin
            if (H_num == 4'd8)
            P_num<=P_num+1'b1;//记录P码元的数量，来判断是哪个P码元
            else P_num<=P_num;
        end
        else if (P_num>4'd11)
            P_num<=4'd1;//P码元数量超过11个清零，但由于定时位前的P已经被识别成P12，导致定时时刻后的P成为P1而不是P2，所以，之后的P0成为P12
            else P_num<=P_num;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    code[code_num] <= 8'd0;
    else if (cnt_H==4'd0)//高电平消失时，根据高电平总值判断码元类型，并记录
        begin
            if (P_num>=4'd2&&P_num<4'd12)
            begin
                case(H_num)
                4'd8: code[code_num] <= "P";
                4'd5: code[code_num] <= 1'b1;
                4'd2: code[code_num] <= 1'b0;
                default: code[code_num] <= code[code_num];
                endcase
            end
            else code[code_num] <= 8'd0;
        end
        else code[code_num] <= code[code_num];
end

//always @(posedge clk, negedge rst_n) 
//begin
//    if (~rst_n)
//    Waiting_for_translation[99:0]<= 8'd0;
//    else if (code_num==CODE_NUM_MAX)//翻转数据位
//        begin
//            Waiting_for_translation[2:5]<={code[5],code[4],code[3],code[2]};
//            Waiting_for_translation[7:9]<={code[9],code[8],code[7]};
//            Waiting_for_translation[11:14]<={code[14],code[13],code[12],code[11]};
//            Waiting_for_translation[16:18]<={code[18],code[17],code[16]};
//            Waiting_for_translation[21:24]<={code[24],code[23],code[22],code[21]};
//            Waiting_for_translation[26:27]<={code[27],code[26]};
//            Waiting_for_translation[31:34]<={code[34],code[33],code[32],code[31]};
//            Waiting_for_translation[36:39]<={code[39],code[38],code[37],code[36]};
//            Waiting_for_translation[41:42]<={code[42],code[41]};
//            Waiting_for_translation[51:54]<={code[54],code[53],code[52],code[51]};
//            Waiting_for_translation[56:59]<={code[59],code[58],code[57],code[56]};
//        end
//        else Waiting_for_translation[99:0]<=Waiting_for_translation[99:0];
//end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        second_ones  <=3'd0;
        second_tens  <=2'd0;
        minute_ones  <=3'd0;
        minute_tens  <=2'd0;
        hour_ones    <=3'd0;
        hour_tens    <=1'd0;
        day_ones     <=3'd0;
        day_tens     <=3'd0;
        day_hundreds <=1'd0;
        year_ones    <=3'd0;
        year_tens    <=3'd0;
    end
    else if (code_num == 8'd60)//解码完时间就输出
	    //if (cnt_10ms==MS*10-1)//得到一位时间就输出
		 //if (code_num==CODE_NUM_MAX)//解码完1s整个帧再输出
        begin
            second_ones <={code[5]*8+code[4]*4+code[3]*2+code[2]*1};//倒序整理后，再加权计算
            second_tens <=code[9]*4+code[8]*2+code[7]*1;
            minute_ones <=code[14]*8+code[13]*4+code[12]*2+code[11]*1;
            minute_tens <=code[18]*4+code[17]*2+code[16]*1;
            hour_ones   <=code[24]*8+code[23]*4+code[22]*2+code[21]*1;
            hour_tens   <=code[27]*2+code[26]*1;
            day_ones    <=code[34]*8+code[33]*4+code[32]*2+code[31]*1;
            day_tens    <=code[39]*8+code[38]*4+code[37]*2+code[36]*1;
            day_hundreds<=code[42]*2+code[41]*1;
            year_ones   <=code[54]*8+code[53]*4+code[52]*2+code[51]*1;
            year_tens   <=code[59]*8+code[58]*4+code[57]*2+code[56]*1;
        end
    else begin
            second_ones  <=second_ones ;
            second_tens  <=second_tens ;
            minute_ones  <=minute_ones ;
            minute_tens  <=minute_tens ;
            hour_ones    <=hour_ones   ;
            hour_tens    <=hour_tens   ;
            day_ones     <=day_ones    ;
            day_tens     <=day_tens    ;
            day_hundreds <=day_hundreds;
            year_ones    <=year_ones   ;
            year_tens    <=year_tens   ;
        end
end
endmodule
