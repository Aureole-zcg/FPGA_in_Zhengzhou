module MOSIx8
(
    input wire div_clk,//SPI使用分频过的低频时钟
    input wire rst_n,
    input wire spi_en,//SPI使能标志
    input wire [1:0] spi_cmd,//命令输入
    input wire [7:0] spi_wrdata,//输入数据
    input wire [7:0] spi_wrdata_width,//输入数据宽度

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

wire div_clk_not;
reg [7:0] state;
reg [7:0] cnt_baud;//码元计数器
reg spi_clk_en;//SPI时钟使能

assign div_clk_not = ~div_clk;

//状态机
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        state <= idle;
    else begin 
        case(state)
            0 : begin//idle
                if (spi_en == 1'b1 && spi_cmd == 2'b00)
                    state <= s0;
            end 

            //s0 //可以在这里修改CS_n到输出时钟之间的间隔
            1 : state <= s1;
            
            2 : begin//s1
                if (cnt_baud == spi_wrdata_width)
                    state <= s2;
            end

            //s2
            3 : state <= s3;

            //s3
            4 : state <= s4;

            //s4
            5 : state <= idle;

            default : state <= idle;
        endcase
    end
end

//cs_n
assign cs_n = (state == s1 || state == s2)? 1'b0 : 1'b1;
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

//s1
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        cnt_baud <= 8'd0;
        spi_clk_en <= 1'b0; 
    end
    else if (cnt_baud == spi_wrdata_width)
    begin
        cnt_baud <= 8'd0;
        spi_clk_en <= 1'b0;
    end
        else if (state == s1)
        begin
            cnt_baud <= cnt_baud + 1'b1;
            spi_clk_en <= 1'b1;
        end
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
    else if (state == s1 && cnt_baud >= 1'b0 && cnt_baud < spi_wrdata_width)
            spi_MOSI <= spi_wrdata[cnt_baud];//先发低位LSB
            //spi_MOSI <= spi_wrdata[spi_wrdata_width - 1'b1-cnt_baud];//先发高位MSB
        else if (cnt_baud == spi_wrdata_width)
                spi_MOSI <= 1'b0;
            else spi_MOSI <= spi_MOSI;
end

//输出完毕done信号
always @(posedge div_clk, negedge rst_n) 
begin
    if (~rst_n)
        spi_done <= 1'b0;
    else if (state == s3)
            spi_done <= 1'b1;
        else spi_done <= 1'b0;
end
endmodule
