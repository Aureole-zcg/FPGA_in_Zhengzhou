//将通过状态机收集的数据进行BCD码转换，用于生成74HC595使用的串行信号，以控制数码管波形
module BCD8421_convert
(
    input wire clk, rst_n,
    input wire [19:0] data,

    output reg [3:0] one     ,
    output reg [3:0] ten     ,
    output reg [3:0] hundred ,
    output reg [3:0] thousend,
    output reg [3:0] ten_tho ,
    output reg [3:0] hun_tho 
);

reg [43:0] data_BCD;//十进制转二进制BCD编码的0~999999
reg [5:0] cnt_BCD;//0→接收新data，1~40→移动data的20bit数据进行BCD转码，41→传递数据输出

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_BCD <= 6'd0;
    else if (cnt_BCD == 6'd41)
            cnt_BCD <= 6'd0;
        else cnt_BCD <= cnt_BCD + 1'b1;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        data_BCD <= 44'd0;
        one      <= 4'd0;
        ten      <= 4'd0;
        hundred  <= 4'd0;
        thousend <= 4'd0;
        ten_tho  <= 4'd0;
        hun_tho  <= 4'd0;
    end
    else if (cnt_BCD == 6'd0)
            data_BCD <= {24'b0,data};
        else if (cnt_BCD % 2'd2 == 1'b0)
                data_BCD <= data_BCD << 1'b1;
            else if (cnt_BCD % 2 == 1'b1 && cnt_BCD != 6'd41)//奇数数到计数判定，最后一位只移位不判定
                begin
                    data_BCD[23:20] <= (data_BCD[23:20] > 3'd4) ?  data_BCD[23:20] + 2'd3 : data_BCD[23:20] ;
                    data_BCD[27:24] <= (data_BCD[27:24] > 3'd4) ?  data_BCD[27:24] + 2'd3 : data_BCD[27:24] ;
                    data_BCD[31:28] <= (data_BCD[31:28] > 3'd4) ?  data_BCD[31:28] + 2'd3 : data_BCD[31:28] ;
                    data_BCD[35:32] <= (data_BCD[35:32] > 3'd4) ?  data_BCD[35:32] + 2'd3 : data_BCD[35:32] ;
                    data_BCD[39:36] <= (data_BCD[39:36] > 3'd4) ?  data_BCD[39:36] + 2'd3 : data_BCD[39:36] ;
                    data_BCD[43:40] <= (data_BCD[43:40] > 3'd4) ?  data_BCD[43:40] + 2'd3 : data_BCD[43:40] ;
                end
                else //cnt_BCD = 6'd41
                begin
                    one      <= data_BCD[23:20];
                    ten      <= data_BCD[27:24];
                    hundred  <= data_BCD[31:28];
                    thousend <= data_BCD[35:32];
                    ten_tho  <= data_BCD[39:36];
                    hun_tho  <= data_BCD[43:40];
                end
end
endmodule
