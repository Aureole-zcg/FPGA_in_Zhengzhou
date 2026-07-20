SRIO事务及其类型  
SRIO(Serial Rapid lI0) 事务(transaction) 类型由SRIO包 (packet) 中的Ftype和Ttype决定，其中比较重要的是Nread (Ftype =2,Ttype=4)，功能是读制定的地址;

NWRITE(Ftype=5,Ttype =4)表示往指定的地址写数据;

NWRITE_R(Ftype=5，Ttype=5)，表示往指定的地址写数据，写完之后接收目标期间的响应，即所谓的带响应的写;

SWRITE(Ftype =6,Ttype保留)，表示以流写方式写指定的地址,与NWRITE以及NWRITE_R相比这种方式效率最高；

DOOREBELL(Ftype=10，Ttype保留)，这是一个门铃中断  

事务类型：  
|包类型|FTYPE取值(4bit)|对应表格行|
|:---|:---|:---|
NREAD|2|第一行|
NWRITE|5|第二行|
SWRITE|6|第三行|
DB(Doorbell门铃)|10|第四行|
MSG消息|11|第五行|
RESP响应包|13|第六行|
Data Stream数据流|9|第七行|

若包头tdata[55:52]==4'd5 → 当前就是NWRITE写数据包，左边8bit 就是源设备ID srcTID;  
若tdata[55:52]==4'd10 → 当前就是DB门铃包，左边8bit 同样是源设备ID srcTID;  
哪怕最左侧都是8bit宽度，只要FTYPE不同，整行包头结构、剩余比特的定义全部跟着变。  

PGO07 SRIO高速接口:收发都得调通，ug471 IO资源  
情形1:FPGA给DSP(FPGA调IP核，DSP是C语言封装好的驱动函数不是调核)  
情形2:FPGA和两片DSP通信，如vpx  
情形3:两片FPGA通信，设计方案，SRIO核，通过GTH/X连接到下一片芯片(如果速率不快直接串口，或者lvds，不需要任意高速接口的GTX，如果更快任意高速接口的GTH否则浪费)  
情形4:FPGA和光速连接器，有tx和rx，电信号-SRIO-光信号-光纤(光口可通过sRIO、Aurora、万兆以太网UDP)-电信号，只需要关心数据怎么给SRIO核(或Aurora核或万兆核)即可  
情形5:如太速科技特殊的vpx图3号，多个DSP和多个FPGA之间两两间连接，可能5个人写程序，都经过SRIO线太多，所以用交换SRIO芯片(用IIc配置寄存器调通)  

手册:P4，高度灵活和优化的串行快速IO、端点使用AX14-Stream接口用于高吞吐量数据传输  
vivado的IP核,Lanes:124;传输速率1.25-6.25Gbit/s乘以Lane*4、高达25Gbit/s传输  

SRIO交换机
<img width="1038" height="721" alt="80260f52a1b4f6de22b64eba8ffee302" src="https://github.com/user-attachments/assets/e426e970-5d5f-42b8-a5b8-43538a6d1350" />

谁使用SRIO，就把接口交给谁
