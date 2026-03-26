module rise_fall
(
    input wire clk, rst_n, A,
    output reg Y
);

reg A_dff1, A_dff2, A_dff3;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        A_dff1<=1'b0;
        A_dff2<=1'b0;
        A_dff3<=1'b0;
    end
    else 
    begin
        A_dff1<=A;
        A_dff2<=A_dff1;
        A_dff3<=A_dff2;        
    end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        Y<=1'b0;
		  else if (A_dff2 ^ A_dff3)//根据波形图，A_dff2和A_dff3不同时，Y出现高电平标志电位
            Y=1'b1;
        else Y=1'b0;
end
endmodule
