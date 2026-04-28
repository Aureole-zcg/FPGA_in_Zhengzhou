//将转BCD码的时间数据进行串行排列，以供74HC595串并转换
module sel_seg_gen
#(
    parameter MAX_1ms = 50_000//50MHz,1ms=50_000T
)
(
    input wire clk        ,
    input wire rst_n      ,
    input wire [19:0] data,//from data_generation
    input wire [5:0] point,
    input wire sign       ,
    input wire seg_en     ,//高电平有效

    output reg [5:0] sel,
    output reg [7:0] seg //串行
);
//使用BCD码转位选段选
wire [3:0] one     ;
wire [3:0] ten     ;
wire [3:0] hundred ;
wire [3:0] thousend;
wire [3:0] ten_tho ;
wire [3:0] hun_tho ;
BCD8421_convert BCD8421_convert_inst
(
    . clk  (clk  ), 
    . rst_n(rst_n),
    . data (data ),

    . one     (one     ),
    . ten     (ten     ),
    . hundred (hundred ),
    . thousend(thousend),
    . ten_tho (ten_tho ),
    . hun_tho (hun_tho )
);

//中间变量
reg [15:0] cnt_1ms; 
reg [2:0] cnt_tubshift;//0~5，6个数码管
reg [5:0] sel_r;//位选信号寄存器


always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_1ms <= 16'd0;
    else if (cnt_1ms == MAX_1ms - 1'b1)
            cnt_1ms <= 16'd0; 
        else cnt_1ms <= cnt_1ms + 1'b1;  
end

//1ms切换一个数码管 
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_tubshift <= 3'd0;//二级计数器
    else if (cnt_tubshift == 3'd5 && cnt_1ms == MAX_1ms - 1'b1)
            cnt_tubshift <= 3'd0;
        else if (cnt_1ms == MAX_1ms - 1'b1)
                cnt_tubshift <= cnt_tubshift + 1'b1; 
            else cnt_tubshift <= cnt_tubshift;  
end

//sel_r，储存sel，当选择动态刷新数码管从最左边一号数码管开始时，0：100_000
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        sel_r <= 6'b111_111;//复位全亮
    else if (cnt_tubshift && cnt_1ms == MAX_1ms - 1'b1)//1ms
            sel_r <= sel_r >> 1'b1;
            else if (cnt_tubshift == 1'b0 && cnt_1ms == MAX_1ms - 1'b1)//回到初始100_000
                     sel_r <= 6'b100_000;
        else sel_r <= sel_r;  
end

//获取小数点point(from data_generation)
reg dot;//1bit, 取对应数码管号的point信号值,1ms切换一个值
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        dot <= 1'b0;
    else if (cnt_1ms == MAX_1ms - 1'b1)
            dot <= ~point[cnt_tubshift];//共阳极数码管低电平点亮
        else dot <= dot;  
end

//方法一：单个四位BCD转为十进制，数码管到该位，直接取数
//方法二：先将所有BCD码编为数列，数码管到位，读数列位
//由于BCD码是统一传输6个数字，且避免0和空位混淆，和时序同步，选择方法二
//先将数字排列为串行数列
reg [23:0] data_r;
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data_r <= 24'd0;//复位全亮
    else if (hun_tho || point[0])
            data_r <= {hun_tho, ten_tho, thousend, hundred, ten, one};
        else if (ten_tho || point[1])//不讨论负号
                data_r <= {4'd10, ten_tho, thousend, hundred, ten, one};//3'd7代表空，data数据输入后，data_r在case选择具体值
            else if (thousend || point[2])
                    data_r <= {4'd10, 4'd10, thousend, hundred, ten, one};
                else if (hundred || point[3])
                        data_r <= {4'd10, 4'd10, 4'd10, hundred, ten, one};
                    else if (ten || point[4])
                            data_r <= {4'd10, 4'd10, 4'd10, 4'd10, ten, one};
                        else if (one || point[5])
                                data_r <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, one};
                            else data_r <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10};
end

//sel_r移动一位的同时，确定sel所对应的data_r，赋值给seg_r
reg [7:0] seg_r;
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        seg_r <= 8'h0;//复位全亮"8."
    else //if (cnt_1ms == MAX_1ms - 1'b1)//1ms
            case (cnt_tubshift)
            3'd0 : seg_r <= data_r[23:20];//sel 100_000
            3'd1 : seg_r <= data_r[19:16];//sel 010_000
            3'd2 : seg_r <= data_r[15:12];//sel 001_000
            3'd3 : seg_r <= data_r[11:8]; //sel 000_100
            3'd4 : seg_r <= data_r[7:4];  //sel 000_010
            3'd5 : seg_r <= data_r[3:0];  //sel 000_001
            default : seg_r <= 8'h0;   //复位全亮"8."
            endcase
        //else seg_r <= seg_r;  
end

//sel_r过D触发器延迟得到sel, seg通过seg_r得到十六进制数码管灯管段码
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        sel <= 6'b111_111;//复位全亮
    else sel <= sel_r;  
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        seg <= 8'h0;//复位全亮"8."
    else if (cnt_1ms == 1'b0)//与sel对齐
            case (seg_r)
            4'd0 : seg <={7'b0000001, dot} ;//dp先进，让dp在低位，seg从低位到高位进入
            4'd1 : seg <={7'b1001111, dot} ;//sel 010_000
            4'd2 : seg <={7'b0010010, dot} ;//sel 001_000
            4'd3 : seg <={7'b0000110, dot} ;//sel 000_100
            4'd4 : seg <={7'b1001100, dot} ;//sel 000_010
            4'd5 : seg <={7'b0100100, dot} ;//sel 000_001
            4'd6 : seg <={7'b0100000, dot} ;
            4'd7 : seg <={7'b0001111, dot} ;
            4'd8 : seg <={7'b0000000, dot} ;
            4'd9 : seg <={7'b0000100, dot} ;
            4'd10 : seg <={8'b11111111} ;
            default : seg <= 8'h0;   //复位全亮"8."
            endcase
        else seg <= seg;  
end


endmodule
