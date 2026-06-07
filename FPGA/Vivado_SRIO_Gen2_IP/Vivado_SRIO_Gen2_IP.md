# Vivado SRIO Gen2 IP 解析

## 1 背景

在用户使用 Vivado SRIO Gen2 IP时，最关注的就是User Interface。因为用户只需理解User Interface，就能利用SRIO Gen2 IP实现数据的高速传输，而不需要关注RapidIO协议的过多细节。User Interface包含I/O端口集和三个可选端口。其中，任何支持的I/O事务（例如NWRITEs、NWRITE\_Rs、SWRITEs、NREADs、RESPONSEs和DOORBELL）都通过I/O端口进行发送或接收。

I/O端口可以配置为两种模式：Condensed I/O或Initiator/Target。Initiator/Target端口类型将请求事务和响应事务分别处理，因此共有4个AXI4-Stream通道用于I/O事务的传输。Initiator/Target端口的示意图如下所示。

<img src="./Images/IO_Port.png" alt="IO Port" width="600">

本地设备生成的请求通过ireq通道发送，远程设备产生的响应包通过iresp通道接收。

远程设备生成的请求通过treq通道接收，本地设备产生的响应包通过tresp通道发送。

## 2 I/O端口数据格式

SRIO Gen2 IP的I/O端口可以配置为使用HELLO格式包或SRIO Stream格式包。HELLO格式包是一种精简的包格式，它将包头（Header）域标准化，简化了控制逻辑，并使数据与传输边界对齐，有助于数据管理。

在编写Verilog代码时，可以按照HELLO格式的时序将数据发送给SRIO核。SRIO核会自动将HELLO格式的包转换为标准的SRIO物理层包，并添加控制符号、空闲序列等必要信息进行发送。接收过程则相反，SRIO核在接收到标准的SRIO物理层包及其控制符号、空闲序列等信息后，会将接收到的信息转换为HELLO格式的包，以供用户进行后续处理。

这样，用户在设计事务的Verilog代码时，只需了解HELLO格式的包与时序，而不需要过多关注RapidIO的协议和RapidIO包格式。因此，一般推荐使用HELLO格式。

**HELLO包头：**

![HELLO Head](./Images/HELLO_Head.png)

如图不同的I/O事务对应不同的包头。

<img src="./Images/HELLO_Detail_1.png" alt="HELLO Detail 1" width="600">
<img src="./Images/HELLO_Detail_2.png" alt="HELLO Detail 2" width="600">

如果请求事务的数据量超过8字节，应将数据量调整为最接近的支持值。读写事务中支持的 HELLO 格式数据量为：8、16、32、64、96（仅支持读事务）、128、160（仅支持读事务）、192（仅支持读事务）、224（仅支持读事务）和 256 字节。

HELLO格式数据的包头在用户接口的第一个有效时钟上发送。如果事务携带数据负载，则数据负载会紧随包头连续发送。包的Source ID和Destination ID放置在tuser信号中，并与包头一同在第一个有效时钟发送。发送完毕后，tuser信号中的数据将被忽略。

下图显示了携带数据负载的HELLO格式包在用户接口上传输的时序图。该图展示了32字节数据负载的传输，加上包头，整个传输共花费5个时钟周期。用户只需按照类似下图的时序，将想要发送的数据送入IP核的AXI4-Stream接口，IP核便会将其转换为标准的RapidIO串行物理层包进行发送，接收过程则是发送过程的逆过程。

<img src="./Images/HELLO_Packet_Transfer.png" alt="HELLO Packet Transfer" width="600">

## 3 IP核配置

打开IP核配置界面后，主要需要关注的标签是Basic和I/O标签，其他标签的配置通常使用默认配置即可。

### 3.1 Basic标签

![SRIO Gen2 Basic](./Images/SRIO_Gen2_Basic.png)

- Mode：IP的模式，有基本（Basic）和高级（Advanced）两种。
- Link Width：链路宽度，可选值为1、2或4，链路宽度越大，数据传输的带宽越大。
- Transfer Frequency：传输频率，表示每个串行链路的传输速率，可选值为1.25、2.5、3.125、5.0 和 6.25。传输频率越大，数据传输的带宽越大。
- Reference Clock Frequency：参考时钟频率，可选值为125MHz或156.25MHz，指的是外部时钟源（如晶振或锁相环芯片）送给FPGA串行收发器专用时钟引脚的时钟频率。
- TX Buffer Depth：发送缓冲区的深度，可选值为8、16或32，表示发送缓冲区中可存储的包的最大数目。
- RX Buffer Depth：接收缓冲区的深度，可选值为8、16或 32，表示接收缓冲区中可存储的包的最大数目。
- Component Device ID：该参数是复位后Base Device ID CSR寄存器的复位值。
- Device ID Width：设备ID的宽度，收发双方的设备ID宽度应相同，否则由于包头的偏移可能导致事务被错误解释。大多数系统的Device ID为8位，但RapidIO核也提供了16位的Device ID供用户选择。
- Unified Clock：如果用户设计中的log\_clk和phy\_clk相同，可以选中此选项，选中后可减少延时和资源利用率。
- Transmitter Controlled：选中此选项后，RapidIO核会首先尝试使用发射端控制实现流控，但如果接收方不支持，则会自动切换为接收端控制。发射端控制流控可利用接收缓冲区的状态和水印最小化重试条件。接收端控制流控会随意发包并使用重试协议。
- Receiver Controlled：选中此选项后，RapidIO核只能使用接收端控制实现流控，在此模式下，接收端控制流控会随意发包并使用重试协议。
- transceiver control and status ports：选中此选项可启用额外的收发器控制和状态端口。这些端口与相应设备的GTX/GTH用户指南中同名的收发器端口对应，对于调试收发链路非常有用。

### 3.2 I/O标签

![SRIO Gen2 I/O](./Images/SRIO_Gen2_IO.png)

- Port I/O Style：I/O接口可以配置为Condensed I/O和Initiator/Target两种类型。其中，Condensed I/O模式下，接收和发送均使用一个AXI4-Stream通道；而在Initiator/Target模式下，接收和发送则采用不同的AXI4-Stream通道。
- I/O Format：I/O端口可以配置为使用HELLO格式包或SRIO Stream格式包。通常，强烈推荐使用HELLO格式。
- Messaging：用于选择消息事务的端口类型，参数可选为Combined with IO或Separate Messaging Port。Combined with IO选项表示消息事务与I/O写事务使用相同的I/O端口；选择Separate Messaging Port选项则表示消息事务使用独立的端口进行传输，选择此项后，IP核将出现专用于消息事务的AXI4-Stream通道。
- Maintenance：用于选择维护端口类型，维护端口类型仅限于AXI4-Lite。

## 4 PMA环回实例

### 4.1 配置IP

将链路宽度设置为2，启用额外的收发器控制和状态端口，其余配置保持默认。

![Setting IP](./Images/Setting_IP.png)

### 4.2 连线

根据GTH用户指南，GTH收发器支持以下配置：正常模式、近端/远端PCS子层回环和近端/远端PMA子层回环。

![GTH Loopback Port](./Images/GTH_Loopback_Port.png)

sim\_train\_en信号在仿真时应置为1，而在实际硬件运行时应置为0。将gt\_loopback\_in[5:0]配置为6’b010010，使GTH处于近端PMA回环模式。在此模式下，当在INITIATOR\_REQ接口输入请求数据流时，TARGET\_REQ接口将输出从PMA回环收到的数据流。INITIATOR\_REQ接口和TARGET\_REQ接口的时钟域均为log\_clk。

![IP Connection](./Images/IP_Connection.png)

### 4.3 测试

如图所示，ireq通道发送了一个256 bytes负载的SWRITE事务和一个DOORBELL事务，经过大约1us的时间环回到treq通道。

![Loopback Test](./Images/Loopback_Test.png)

**4.3.1 SWRITE事务**

SWRITE事务的包头为: 64’h006020000c000000。

![SWRITE](./Images/SWRITE.png)

对照HELLO格式解析包头。转化为二进制后，与HELLO格式各个字段对应关系如下所示：

![SWRITE Head](./Images/SWRITE_Head.png)

**4.3.2 DOORBELL事务**

DOORBELL事务为: 64’h00a0200000000000。

![DOORBELL](./Images/DOORBELL.png)

对照HELLO格式解析包头。转化为二进制后，与HELLO格式各个字段对应关系如下所示：

![DOORBELL Head](./Images/DOORBELL_Head.png)

## 5 REFERENCE

1. https://www.cnblogs.com/liujinggang/p/10072115.html
2. ug576-ultrascale-gth-transceivers
3. pg007\_srio\_gen2