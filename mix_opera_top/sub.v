module sub
(
    input wire[7:0] sub_in1,
    input wire[7:0] sub_in2,

    output reg [7:0]sub_out

);

//assign sub_out=sub_in1-sub_in2;

always @(*)//always：表示该块内的语句会反复执行。* 是通配符，即模块中任何被读取的信号发生变化时，该块就会被触发
begin
if(sub_in1>sub_in2)
sub_out=sub_in1-sub_in2;
else 
sub_out=8'd0;
end
endmodule
