//0~999999的数据循环产生模块，为BCD码转译提供数据
module data_generation
#(
    parameter MAX_100ms = 5_000_000//0.1s,5_000_000T,50MHz
)
(
    input wire clk, rst_n,

    output reg [19:0] data, //0~999999,20bit
    output wire [5:0]  point,//小数点
    output wire        sign, //"-"负数符号
    output reg         seg_en//段选使能
);

reg [24:0] cnt_100ms;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_100ms <= 25'd0;
    else if (cnt_100ms == MAX_100ms - 1'b1)//清零
            cnt_100ms <= 25'd0;
        else cnt_100ms <= cnt_100ms +1'b1;    
end

//每0.5s data自加1
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data <= 20'd0;
    else if (data == 20'd999_999 && cnt_100ms == MAX_100ms - 1'b1)//清零
            data <= 20'd0;
        else if (cnt_100ms == MAX_100ms - 1'b1)
                data <= data + 1'b1;
            else data <= data;    
end

//在这里产生小数点和负号，只产生单纯数字循环，符号在595显示代码（产生sel和seg）中可以体现
assign point = 6'b010000;
assign sign = 1'b0;
//小数点和负号均为高有效

//段选使能常开
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        seg_en <= 1'b0;
    else seg_en <= 1'b1;    
end
endmodule
