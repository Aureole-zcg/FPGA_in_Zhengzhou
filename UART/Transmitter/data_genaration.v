module data_genaration
#(
    parameter MAX_1s = 49_999_999 //50MHz 1s=50_000_000T
)
(
    input wire clk, rst_n,

    output reg [7:0] data,
    output reg       data_flag
);

reg [25:0] cnt_1s;//1s counter

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_1s <= 26'd0;
    else if (cnt_1s == MAX_1s)
        cnt_1s <= 26'd0;
        else cnt_1s <= cnt_1s + 1'b1;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data <= 8'd0;
    else if (data == 8'd8 && cnt_1s == MAX_1s)
            data <= 8'd0;
        else if (cnt_1s == MAX_1s)
                data <= data + 1'b1;
            else data <= data;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data_flag <= 1'b0;
    else if (cnt_1s == 1'b1)
            data_flag <= 1'b1;
        else data_flag <= 1'b0;
end
endmodule
