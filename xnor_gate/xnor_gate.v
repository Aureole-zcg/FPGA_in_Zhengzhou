//模块框架
module xnor_gate//module模块开始后跟模块名
(             //端口列表描述区
input A,//输入端口 wire（金属线）信号类型//逗号间隔
input B,//wire类型可省略
  
output Y//输出端口 输出信号定义类型取决于后续赋值语句
);
//逻辑功能表达区
//assign --wire 

//赋值语句描述
//赋值关键字 assign
//assign：分配；指派；指定
assign Y=~A^B;

endmodule 
