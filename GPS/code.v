/*
识别“$GPRMC”序列，识别成功输出1；其他情况输出0
*/
module code
(
    input wire clk, rst_n, flag,
    input wire [7:0]data_in,

    output reg Y
);

reg [7:0] array [5:0];//存储六个字符ASCII

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
       
    else if (flag)
        begin
            array [5] <= array[4];
            array [4] <= array[3];
            array [3] <= array[2];
            array [2] <= array[1];
            array [1] <= array[0];
            array [0] <= data_in ;
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
        Y <= 1'b0;
    else begin
        case ({array [5],array [4],array [3],array [2], array [1],array [0]})
        "$GPRMC":Y <= 1'b1;
        default :Y <= 1'b0;
        endcase
    end
end
endmodule
