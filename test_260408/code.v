/*
数据流输入data_in为8位宽数据，数据形式遵循下里面ascii码表，
每一个字符对应一个8bit有效数据。要求完成能识别“$GNRMC”序列，
识别成功输出1；识别“$GPRMC”序列，识别成功输出2；其他情况输出0
*/
module code
(
    input wire clk, rst_n, 
    input wire [7:0]data_in,

    output reg [1:0]Y
);

reg [7:0] array [5:0];//存储六个字符
reg [2:0] cnt;//计数data的字符位

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 3'd0;
    else cnt <= cnt +1'b1;//溢出清零
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
	 begin
	 array [5] <= 8'd0;
	 array [4] <= 8'd0;
	 array [3] <= 8'd0;
	 array [2] <= 8'd0;
	 array [1] <= 8'd0;
	 array [0] <= 8'd0;
	 end
       
    else if (cnt == 3'd7)
        begin
            array [5] <= {data_in};
            array [4] <= {array[5]};
            array [3] <= {array[4]};
            array [2] <= {array[3]};
            array [1] <= {array[2]};
            array [0] <= {array[1]};
        end
    else begin
            array [5] <= array[5];
            array [4] <= array[4];
            array [3] <= array[3];
            array [2] <= array[2];
            array [1] <= array[1];
            array [0] <= array[0];
        end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        Y <= 2'd0;
    else begin
        case ({array [5],array [4],array [3],array [2], array [1],array [0]})
        "$GNRMC":Y <= 2'd1;
        "$GPRMC":Y <= 2'd2;
        default :Y <= 2'd0;
        endcase
    end
end
endmodule
