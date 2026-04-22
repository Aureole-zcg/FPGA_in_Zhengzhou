//发送固定字符串，修改参数和ASCII16进制编码可修改
module data_character_genaration
#(
    parameter MAX_1s = 49_999_999, //50MHz 1s=50_000_000T
    parameter MAX_40ms = 2_000_000 - 1'b1, 
    parameter character_NUM = 25 - 1'b1//发送的字符数
)
(
    input wire clk, rst_n,

    output reg [7:0] data,
    output reg       data_flag
);

reg [25:0] cnt_time;//time counter
reg [7:0] character_cnt;


always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_time <= 26'd0;
    else if (cnt_time == MAX_40ms)//单个字符生成发送时长
        cnt_time <= 26'd0;
        else cnt_time <= cnt_time + 1'b1;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        character_cnt <= 8'd0;
    else if (cnt_time == MAX_40ms && character_cnt == character_NUM)//发送字符数量
        character_cnt <= 8'd0;
        else if (cnt_time == MAX_40ms)
            character_cnt <= character_cnt + 1'b1;
            else character_cnt <= character_cnt;
end

//ASCII编码对应字符计数器值
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data <= 8'd0;
    else case (character_cnt)//I MISS YOU To:XAY (^///^)
    0  : data <= 8'h49 ;//"I"
    1  : data <= 8'h20 ;//" "
    2  : data <= 8'h4d ;//"M"
    3  : data <= 8'h49 ;//"I"
    4  : data <= 8'h53 ;//"S"
    5  : data <= 8'h53 ;//"S"
    6  : data <= 8'h20 ;//" "
    7  : data <= 8'h59 ;//"Y"
    8  : data <= 8'h4f ;//"O"
    9  : data <= 8'h55 ;//"U"
    10 : data <= 8'h20 ;//" "
    11 : data <= 8'h54 ;//"T"
    12 : data <= 8'h6f ;//"o"
    13 : data <= 8'h3a ;//":"
    14 : data <= 8'h58 ;//"X"
    15 : data <= 8'h41 ;//"A"
    16 : data <= 8'h59 ;//"Y"
    17 : data <= 8'h20 ;//" "
    18 : data <= 8'h28 ;//"("
    19 : data <= 8'h5e ;//"^"
    20 : data <= 8'h2f ;//"/"
    21 : data <= 8'h2f ;//"/"
    22 : data <= 8'h2f ;//"/"
    23 : data <= 8'h5e ;//"^"
    24 : data <= 8'h29 ;//")"
    default : data <= 8'd0;
    endcase
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data_flag <= 1'b0;
    else if (cnt_time == 1'b1)
            data_flag <= 1'b1;
        else data_flag <= 1'b0;
end
endmodule
