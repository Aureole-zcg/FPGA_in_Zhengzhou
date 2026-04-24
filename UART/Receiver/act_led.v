//测试用led
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


endmodule