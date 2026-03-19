module mux4_1
(
    input wire [7:0]add_in0,
    input wire [7:0]add_in1,
    input wire [7:0]add_in2,
    input wire [7:0]add_in3,
    input wire [1:0]sel,

    output reg [7:0]add_out

);

//assign --wire
//always --reg

//第一种写法：assign+三目运算符
//assign后只能跟一条语句
//assign add_out=(sel==2'b00)? add_in0:
//               (sel==2'b01)? add_in1:
//               (sel==2'b10)? add_in2:add_in3;

//第二种写法：always+三目运算符
//always @(*)//(sel,add_in0,add_in1,add_in2,add_in3)
//    add_out=(sel==2'b00)? add_in0:
//               (sel==2'b01)? add_in1:
//               (sel==2'b10)? add_in2:add_in3;

//第三种写法：always+if else
//always @(*)
//begin
//    if(sel==2'b00)
//        add_out=add_in0;
//    else if(sel==2'b01)
//        add_out=add_in1;
//    else if(sel==2'b10)
//        add_out=add_in2;
//    else 
//        add_out=add_in3;
//end

//第四种写法：always+case语句
always @(*)
begin
    case (sel)
        2'b00:add_out=add_in0;
        2'b01:add_out=add_in1;
        2'b10:add_out=add_in2;
        default:add_out=add_in3;
    endcase
end

endmodule
