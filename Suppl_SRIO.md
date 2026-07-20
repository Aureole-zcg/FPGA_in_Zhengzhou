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
