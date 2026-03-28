//月亮代表我的心
module bsong_beep.v
#(
    parameter Do = 190839,//七个基础音调，音调的频率转化为时钟周期个数
    parameter Re = 170068,
    parameter Mi = 151515,
    parameter Fa = 143266,
    parameter So = 127551,
    parameter La = 113636,
    parameter Si = 101214,
    parameter TIM = 20_000_000//0.23s==11_500_000T//0.5S==25_000_000T//--------调整点1√

)
(
    input wire clk, rst_n,

    output reg beep_out
);

reg [31:0] cnt_s, tone_cnt, tone;//计数0.4s（音调鸣响时长）//频率计数器，计数PWM低电平//具体音调
reg [31:0] tone_num;//音调数，第几个音调

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_s<=32'd0;
    else if (cnt_s==TIM-1)//每个音调响0.4s
        cnt_s<=1'd0;
        else cnt_s<=cnt_s+1'd1;    
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone_num<=32'd0;
    else if (tone_num==73 && cnt_s==TIM-1)//计数0~73，74个音调//--------调整点2√
        tone_num<=32'd0;
        else if (cnt_s==TIM-1)
		      tone_num<=tone_num+1'd1;    
              else tone_num<=tone_num;//保持当前音调，直到0.4s计数结束
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone<=Do;
    else case(tone_num)//确定音调//--------调整点3√
         /*
         Do;//1
         Re;//2
         Mi;//3
         Fa;//4
         So;//5
         La;//6
         Si;//7
         */
         
         8'd0:tone<=So;//5
         8'd1:tone<=So;//5
         8'd2:tone<=Mi;//3
         8'd3:tone<=Re;//2
         8'd4:tone<=Do;//1
         8'd5:tone<=Mi;//3

         8'd6:tone<=La;//6
         8'd7:tone<=La;//6
         8'd8:tone<=Fa;//4
         8'd9:tone<=Re;//2
         8'd10:tone<=Do;//1
         8'd11:tone<=Si;//7

         8'd12:tone<=So;//5
         8'd13:tone<=Do;//1
         8'd14:tone<=Mi;//3
         8'd15:tone<=So;//5
         8'd16:tone<=Do;//1
         8'd17:tone<=Si;//7
         8'd18:tone<=Mi;//3
         8'd19:tone<=So;//5

         8'd20:tone<=So;//5
         8'd21:tone<=La;//6
         8'd22:tone<=Si;//7
         8'd23:tone<=Do;//1
         8'd24:tone<=La;//6
         8'd25:tone<=So;//5

         8'd26:tone<=Mi;//3
         8'd27:tone<=Re;//2
         8'd28:tone<=Do;//1
         8'd29:tone<=Do;//1
         8'd30:tone<=Do;//1
         8'd31:tone<=Mi;//3
         8'd32:tone<=Re;//2
         8'd33:tone<=Do;//1
         8'd34:tone<=Do;//1
         8'd35:tone<=Re;//2

         8'd36:tone<=Re;//2
         8'd37:tone<=Mi;//3
         8'd38:tone<=Re;//2
         8'd39:tone<=Do;//1
         8'd40:tone<=La;//6
         8'd41:tone<=Re;//2
         8'd42:tone<=Re;//2

         8'd43:tone<=So;//5
         8'd44:tone<=Do;//1
         8'd45:tone<=Mi;//3
         8'd46:tone<=So;//5
         8'd47:tone<=Do;//1
         8'd48:tone<=Si;//7
         8'd49:tone<=Mi;//3
         8'd50:tone<=So;//5

         8'd51:tone<=So;//5
         8'd52:tone<=La;//6
         8'd53:tone<=Si;//7
         8'd54:tone<=Do;//1
         8'd55:tone<=La;//6
         8'd56:tone<=So;//5

         8'd57:tone<=Mi;//3
         8'd58:tone<=Re;//2
         8'd59:tone<=Do;//1
         8'd60:tone<=Do;//1
         8'd61:tone<=Do;//1

         8'd62:tone<=Mi;//3
         8'd63:tone<=Re;//2
         8'd64:tone<=Do;//1
         8'd65:tone<=Do;//1
         8'd66:tone<=Do;//1

         8'd67:tone<=Re;//2
         8'd68:tone<=Mi;//3
         8'd69:tone<=Re;//2
         8'd70:tone<=La;//6
         8'd71:tone<=Si;//7
         8'd72:tone<=Do;//1
         8'd73:tone<=Do;//1
         default :tone<=Do;
         endcase   
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone_cnt<=32'd0;
    else if (tone_cnt==tone-1 || cnt_s==TIM-1)//或（tone_cnt > tone)
        tone_cnt<=32'd0;
        else tone_cnt<=tone_cnt+1'd1;//开始累计高电平时间计数，实现音调对应PWM波
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    beep_out<=1'b1;
    else if(tone_cnt<=tone>>8)//占空比12.5%//占空比越大声音越大//--------调整点4√
        beep_out<=1'b0;
        else beep_out<=1'b1;
end

endmodule
