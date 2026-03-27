module rise_fall
(
    input wire clk, rst_n, A,
    output reg Y_rise, Y_fall
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
        begin
		     Y_rise<=1'b0;
		     Y_fall<=1'b0;
		  end
		  else if (A_dff2==1'b1 && A_dff3==1'b0)//根据波形图，A_dff2和A_dff3不同时，Y出现高或低电平标志电位
            Y_rise<=1'b1;//边沿检测的上升沿检测和下降沿检测是分开进行的两个不同信号
            else if (A_dff2==1'b0 && A_dff3==1'b1)
		          Y_fall<=1'b1;
					 else begin
					 Y_rise<=1'b0;
					 Y_fall<=1'b0;
					 end
end
endmodule
