/*程序接收到连续的AA BB CC DD 将板子上所有的LED点亮，
只有程序接收到55 66 77 88  时候才会将板子上所有的灯熄灭*/
module act_led2
(
    input wire clk, rst_n, flag,
    input wire [7:0]data_in,

    output reg led1, led2, led3, led4
);

reg [7:0] array [7:0];//存储8个字符
//reg [3:0] cnt;//计数data的字符位0~7
reg  Y;//led电平寄存器

//always @(posedge clk, negedge rst_n) 
//begin
//    if (~rst_n)
//        cnt <= 3'd0;
//    else cnt <= cnt +1'b1;//溢出清零
//end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
	 begin
	 array [7] <= 8'd0;
     array [6] <= 8'd0;
     array [5] <= 8'd0;
	 array [4] <= 8'd0;
	 array [3] <= 8'd0;
	 array [2] <= 8'd0;
	 array [1] <= 8'd0;
	 array [0] <= 8'd0;
	 end
       
    else if (flag == 1'b1)
        begin
            array [7] <= array[6];
            array [6] <= array[5];
            array [5] <= array[4];
            array [4] <= array[3];
            array [3] <= array[2];
            array [2] <= array[1];
            array [1] <= array[0];
            array [0] <= data_in ;
        end
    else begin
            array [7] <= array [7];
            array [6] <= array [6];
            array [5] <= array [5];
            array [4] <= array [4];
            array [3] <= array [3];
            array [2] <= array [2];
            array [1] <= array [1];
            array [0] <= array [0];
        end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        Y <= 1'b1;
    else begin
        case ({array [7],array [6],array [5],array [4],array [3],array [2], array [1],array [0]})
        "AABBCCDD":Y <= 1'b0;
        "55667788":Y <= 1'b1;
        default :Y <= Y;
        endcase
    end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        led1 <= 1'b1; 
        led2 <= 1'b1; 
        led3 <= 1'b1; 
        led4 <= 1'b1;
    end
    else if (Y == 1'b0)
        begin
            led1 <= 1'b0; 
            led2 <= 1'b0; 
            led3 <= 1'b0; 
            led4 <= 1'b0;
        end
        else if (Y == 1'b1)
             begin
                led1 <= 1'b1; 
                led2 <= 1'b1; 
                led3 <= 1'b1; 
                led4 <= 1'b1;
            end
        else begin
            led1 <= led1; 
            led2 <= led2; 
            led3 <= led3; 
            led4 <= led4;
        end
end

endmodule

























/*//测试用led
module act_led
#(
    parameter MAX_1S = 50_000_000-1 //1s
)
(
    input wire clk, rst_n,
    input wire [7:0]data,

    output reg led
);

reg [31:0] cnt;
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 32'd0;
    else if (data > 8'd0 && data < 8'd7 || cnt == MAX_1S)
            cnt <= 32'd0;
    else if (data >= 8'd7 && data <= 8'd15)
            cnt <= cnt + 1'b1;
        else if (cnt > 1'b0 && cnt < MAX_1S)
                cnt <= cnt + 1'b1;
            else cnt <= cnt;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        led <= 1'b0;
    else if (cnt > 1'b0 )
            led <= 1'b0;
        else led <= 1'b1;
end


endmodule*/
