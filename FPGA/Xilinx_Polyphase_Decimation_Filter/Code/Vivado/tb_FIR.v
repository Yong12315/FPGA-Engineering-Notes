`timescale 1ns/1ps
`default_nettype none

module tb_FIR;

reg                                 Clk                        ;

reg                                 s_axis_data_tvalid       ='b0;
reg                  [  31: 0]      s_axis_data_tdata          ;
wire                                m_axis_data_tvalid         ;
wire                 [  47: 0]      m_axis_data_tdata          ;

wire                 [  15: 0]      I_In                       ;
wire                 [  15: 0]      Q_In                       ;
wire                 [  15: 0]      I_Out                      ;
wire                 [  15: 0]      Q_Out                      ;
wire                 [  31: 0]      IQ_Result                  ;

reg                  [  31: 0]      IQ_Data_Mem[0:19999]       ;

reg                  [  31: 0]      Cnt                      ='d0 ;

fir_compiler_0 u_fir_compiler_0 (
    .aclk                               (Clk                       ),// input wire aclk
    .s_axis_data_tvalid                 (s_axis_data_tvalid        ),// input wire s_axis_data_tvalid
    .s_axis_data_tready                 (                          ),// output wire s_axis_data_tready
    .s_axis_data_tdata                  (s_axis_data_tdata         ),// input wire [31 : 0] s_axis_data_tdata
    .m_axis_data_tvalid                 (m_axis_data_tvalid        ),// output wire m_axis_data_tvalid
    .m_axis_data_tdata                  (m_axis_data_tdata         ) // output wire [47 : 0] m_axis_data_tdata
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) Clk=~Clk;

initial begin
    $readmemh("IQ_Data.mem", IQ_Data_Mem);
end

integer fid_result;
localparam RESULT_FILE = "E:/prj/Drone_Monitor/Zynq/Self/MATLAB/FIR/IQ_Result.txt";

initial begin
    fid_result = $fopen(RESULT_FILE, "w");
    if (fid_result == 0) begin
        $display("ERROR: Cannot open %s", RESULT_FILE);
        $finish;
    end
end


assign                              I_In                        = s_axis_data_tdata[15:0];
assign                              Q_In                        = s_axis_data_tdata[31:16];
assign                              I_Out                       = m_axis_data_tdata[15:0];
assign                              Q_Out                       = m_axis_data_tdata[39:24];
assign                              IQ_Result                   = {Q_Out, I_Out}       ;

always @(posedge Clk) begin
    if (s_axis_data_tvalid) begin
        Cnt <= Cnt + 1;
    end
    else begin
        Cnt <= 'd0;
    end
end

always @(*) begin
    s_axis_data_tdata = IQ_Data_Mem[Cnt];
end

initial begin
    #1 Clk<=1'bx;
    #(CLK_PERIOD*3) 
    #(CLK_PERIOD*3) Clk<=0;
    repeat(5) @(posedge Clk);
    @(posedge Clk);
    s_axis_data_tvalid = 'b0;
    repeat(2) @(posedge Clk);
    #1;
    #(CLK_PERIOD*30)
    s_axis_data_tvalid = 'b1;
    #(CLK_PERIOD*20000)
    s_axis_data_tvalid = 'b0;
end

always @(posedge Clk) begin
    if (m_axis_data_tvalid) begin
        $fwrite(fid_result, "%h\n", IQ_Result);
    end
end

endmodule
`default_nettype wire