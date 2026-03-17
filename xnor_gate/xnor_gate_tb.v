//测试平台框架

//时间预编译指令 时间单位/时间精度
`timescale 1ns/1ps

//所有的输入统一换reg类型 输出统一用wire
module xnor_gate_tb;
reg A;
reg B;
wire Y;

//赋值关键字
//initial --reg
initial 
begin
  A=0;
  B=0;//信号初始化
	#100//时间过100ns
	A=1;
	B=1;
	#50
	A=0;//B不写就维持
	#100
	A=1;
	B=0;
	#100
	A=0;//语法要求，不能时间结尾，只能语句结尾
end 

//调用
//模块名 实例化名
xnor_gate xnor_gate_inst
(
  .A(A),//端口 传输数据
	.B(B),
	.Y(Y)
	
);

endmodule 
