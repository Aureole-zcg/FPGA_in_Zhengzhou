`timescale 1ns/1ps

module code_tb();

reg clk, rst_n;
reg [7:0]data_in;

initial 
begin
    clk <= 1'b0;
    rst_n <= 1'b0;
    data_in <= 8'd0;
    #77
    rst_n <= 1'b1;
end

always #10 clk = ~clk;//50MHz T=20ns

reg [3:0] cnt_16;//0~15
reg [2:0] cnt_bit;//0~7

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        cnt_16 <= 4'd0;
        cnt_bit <= 3'd0;
    end
    else if (cnt_bit==3'd7)
        begin 
            cnt_16 <= cnt_16 +1'b1; 
            cnt_bit <= 3'd0;
        end
        else begin
            cnt_16 <= cnt_16 ; 
            cnt_bit <= cnt_bit +1'b1; 
            end  
end


reg [7:0] mem [7:0];
initial
//begin
//mem [0] = 0100_0011;//C
//mem [1] = 0100_1101;//M
//mem [2] = 0101_0010;//R
//mem [3] = 0100_1110;//N
//mem [4] = 0100_0000;//P
//mem [5] = 0100_0111;//G
//mem [6] = 0010_0100;//$
//mem [7] = 0100_0001;//A
//end

begin
mem [0] = 67;//C
mem [1] = 77;//M
mem [2] = 82;//R
mem [3] = 78;//N
mem [4] = 80;//P
mem [5] = 71;//G
mem [6] = 36;//$
mem [7] = 65;//A
end

reg [3:0]state;
parameter idle = 4'd0;
parameter s1 = 4'd1  ;
parameter s2 = 4'd2  ;
parameter s3 = 4'd3  ;
parameter s4 = 4'd4  ;
parameter s5 = 4'd5  ;
parameter s6 = 4'd6  ; 
parameter s7 = 4'd7  ;
parameter s8 = 4'd8  ;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    state <= idle;
    else  if (cnt_bit==3'd7)
        case(cnt_16)
            0,6:state <= s1;
            1,7:state <= s2;
            2,8:state <= s3;
            3:state <= s5;
            4,10:state <= s6;
            5,11:state <= s7;
            9:state <= s4;
            default :state <= s8; 
            endcase
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    data_in <= 8'd0;
    else case(state)
        s1:data_in <= mem [0];
        s2:data_in <= mem [1];
        s3:data_in <= mem [2];
        s4:data_in <= mem [3];
        s5:data_in <= mem [4];
        s6:data_in <= mem [5];
        s7:data_in <= mem [6];
        s8:data_in <= mem [7];
        default :data_in <= 8'd0;
        endcase 
end

code code_inst
(
    .clk(clk), 
    .rst_n(rst_n), 
    .data_in(data_in),

    .Y()
);
endmodule
