module MOSIx8
#(
    parameter MAX_1S = 50_000_000//50MHz T=20ns //上电等待
)
(
    input wire div_clk,//SPI使用分频过的低频时钟
    input wire rst_n,
    //input wire spi_en,//SPI使能标志
    //input wire [1:0] spi_cmd,//命令输入
    //input wire [7:0] spi_wrdata,//输入数据
    //input wire [7:0] spi_wrdata_width,//输入数据宽度
    //input wire [15:0] spi_wrdata_num,//输入数据数量

    output reg spi_clk,//spi输出时钟
    output wire cs_n,//片选信号
    output reg spi_MOSI,//单bit串行数据
    output reg spi_done //信号传输完毕标志信号
);

parameter idle = 8'd0;
parameter s0 = 8'd1;
parameter s1 = 8'd2;
parameter s2 = 8'd3;
parameter s3 = 8'd4;
parameter s4 = 8'd5;
parameter s5 = 8'd6;
parameter s6 = 8'd7;
parameter s7 = 8'd8;
parameter s8 = 8'd9;
parameter s9 = 8'd10;

wire [7:0] spi_wrdata;//输入数据
wire [7:0] spi_wrdata_width;//输入数据宽度
wire [15:0] spi_wrdata_num;//输入数据数量

reg spi_en;//SPI使能标志
reg [1:0] spi_cmd;//命令输入
wire div_clk_not;
reg [7:0] state;
reg [15:0] cnt_band_bit;//总传递bit位
reg [15:0] cnt_band_index;//码元计数器
reg [7:0] cnt_bit;//bit计数器
reg spi_clk_en;//SPI时钟使能
reg [31:0] cnt_1s;//上电等待1s

assign div_clk_not = ~div_clk;




//状态机
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        state <= idle;
    else begin 
        case(state)
            0 : begin//idle
                if (spi_en == 1'b1 && spi_cmd == 2'b00 )
                    state <= s0;
            end 

            //s0 //可以在这里修改CS_n到输出时钟之间的间隔
            1 : state <= s1;
            
            2 : begin//s1
                if (cnt_band_bit == spi_wrdata_width)//传递完第一个指令（写使能指令）
                    state <= s2;
            end

            //s2
            3 : state <= s3;

            //s3
            4 : state <= s4;

            //s4
            5 : state <= s5;

            //s5
            6 : state <= s6;

            //s6
            7 : if (cnt_band_bit == spi_wrdata_num * spi_wrdata_width&& cnt_bit == spi_wrdata_width)//输出完所有数据
                    state <= s7;

            //s7
            8 : state <= s8;

            //s8
            9 : state <= s9;

            //s9
            10 : state <= idle;

            default : state <= idle;
        endcase
    end
end

//cs_n
assign cs_n = (state == s1 || state == s2 || state == s6 || state == s7)? 1'b0 : 1'b1;
//assign cs_n = (state == s2)? 1'b0 : 1'b1;
//always @(posedge div_clk, negedge rst_n) 
//begin
//    if (~rst_n)
//        cs_n <= 1'b1;
//    else if (state == s2)
//            cs_n <= 1'b1;
//        else if (state == s0)
//            cs_n <= 1'b0;    
//end

always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_1s <= 32'd0;
    else if (state == idle && cnt_1s < MAX_1S)
            cnt_1s <= cnt_1s +1'b1;
            else cnt_1s <= cnt_1s;
end

always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        begin
            spi_en <= 1'b0; 
            spi_cmd <= 2'b00;
        end
    else if (cnt_1s == MAX_1S - 1'b1)
            spi_en <= 1'b1; 
            else spi_en <= 1'b0; 
end

//cnt_band_bit 计数已经发出的bit位个数
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_band_bit <= 16'd0;
    else if (cnt_band_bit == spi_wrdata_num * spi_wrdata_width)//输入所有数据的bit个数
            cnt_band_bit <= cnt_band_bit;
        else if ((state == s1 || state == s6))
                cnt_band_bit <= cnt_band_bit + 1'b1;
end


//cnt_bit计数传递的bit位数
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        cnt_bit <= 8'd0;
        spi_clk_en <= 1'b0; 
    end
    else if (cnt_bit == spi_wrdata_width)
    begin
        if (cnt_band_index == spi_wrdata_num -1'b1 && cnt_bit == spi_wrdata_width && cnt_band_bit == spi_wrdata_num * spi_wrdata_width)//输入所有数据
        begin
            cnt_bit <= 8'd0;
            spi_clk_en <= 1'b0;
        end
        else if (state == s6)//s6连续发送
        begin
            cnt_bit <= 8'd1;
            spi_clk_en <= 1'b1;
        end
            else
            begin
                cnt_bit <= 8'd0;
                spi_clk_en <= 1'b0;
            end
    end
        else if (state == s1 || state == s6)
        begin
            cnt_bit <= cnt_bit + 1'b1;
            spi_clk_en <= 1'b1;
        end
end

//cnt_band_index码元计数器，对应取数据数组值--index
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_band_index <= 16'd0;
    else if (cnt_band_index == spi_wrdata_num -1'b1 && cnt_bit == spi_wrdata_width - 1'b1)//输入所有数据
            cnt_band_index <= cnt_band_index;
        else if (cnt_bit == spi_wrdata_width - 1'b1)
                cnt_band_index <= cnt_band_index + 1'b1;
end

always @(*) 
begin
   if (spi_clk_en)
   spi_clk = div_clk_not;
   else  spi_clk = 1'b0;
end

//MOSI
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        spi_MOSI <= 1'b0;
    else if (cnt_band_index == spi_wrdata_num -1'b1 && cnt_bit == spi_wrdata_width && cnt_band_bit == spi_wrdata_num * spi_wrdata_width)
            spi_MOSI <= 1'b0;
        else if (state == s1 && cnt_bit >= 1'b0 && cnt_bit < spi_wrdata_width) 
                //spi_MOSI <= spi_wrdata[cnt_bit];//先发低位LSB
                spi_MOSI <= spi_wrdata[spi_wrdata_width - 1'b1-cnt_bit];//先发高位MSB
            else if (state == s6 && cnt_bit >= 1'b0 && cnt_bit <= spi_wrdata_width)
                begin
                    if (cnt_bit == spi_wrdata_width)
                        spi_MOSI <= spi_wrdata[spi_wrdata_width - 1'b1];
                    else spi_MOSI <= spi_wrdata[spi_wrdata_width - 1'b1-cnt_bit];//先发高位MSB
                end
                else if (cnt_band_index == spi_wrdata_num -1'b1 && cnt_bit == spi_wrdata_width && cnt_band_bit == spi_wrdata_num * spi_wrdata_width)
                        spi_MOSI <= 1'b0;
                    else spi_MOSI <= 1'b0;
end

//always @(posedge div_clk, negedge rst_n) 
//begin
//    if (~rst_n)
//        spi_MOSI <= 1'b0;
//    else if (state == s6 && cnt_bit >= 1'b1 && cnt_bit <= spi_wrdata_width)
//            //spi_MOSI <= spi_wrdata[cnt_bit];//先发低位LSB
//            spi_MOSI <= spi_wrdata[spi_wrdata_width - cnt_bit];//先发高位MSB
//        else if (cnt_bit == spi_wrdata_width)
//                spi_MOSI <= 1'b0;
//            else spi_MOSI <= spi_MOSI;
//end

//输出完毕done信号
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        spi_done <= 1'b0;
    else if (state == s8)
            spi_done <= 1'b1;
        else spi_done <= 1'b0;
end

w25q16jv_cmd w25q16jv_cmd_inst
(
	. index(cnt_band_index),//索引

	. spi_wrdata      (spi_wrdata      ),
    . spi_wrdata_width(spi_wrdata_width),//输入数据宽度
    . spi_wrdata_num  (spi_wrdata_num  ) //输入数据数量
);
endmodule
