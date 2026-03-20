//项目目标：0~99循环计数器，在10~20计数位置拉高信号，其他位置均为低电平
module cnt_ctrl
(
    input wire clk,
    input rst_n,

    output reg Y
);

reg [7:0] cnt;
always @(posedge clk,negedge rst_n)
begin
    if(~rst_n)//rst_n==0
        cnt<=1'b0;
    else if(cnt==8'd99)
        cnt<=1'b0;
    else cnt<=cnt+1'b1;
	end

    //assign Y=(cnt>8'd9&&cnt<8'd21)? 1'b1:1'b0;//组合逻辑写法，数据类型wire
    
    always @(*) //组合逻辑
    begin
        if(cnt>=8'd10&&cnt<=8'd20)
            Y=1'b1;
        else Y=1'b0;
    end

    //always @(*)
    //begin
    //    case(cnt)
    //    8'd10,8'd11,8'd12,8'd13,8'd14,8'd15,8'd16,8'd17,8'd18,8'd19,8'd20:Y=1'b1;
    //    default :Y=1'b0;
    //    endcase
    //end


//时序逻辑
reg Y_test;
always @(posedge clk) 
begin
    if(~rst_n)//rst_n==0
        Y_test<=1'b0;
    if(cnt>8'd8&&cnt<8'd20)//延时特性，cnt到9就拉高，cnt到20就拉低
            Y_test<=1'b1;
        else Y_test<=1'b0;
    
end
endmodule
