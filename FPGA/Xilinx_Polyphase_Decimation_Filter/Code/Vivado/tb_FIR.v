`timescale 1ns/1ps
`default_nettype none

module tb_FIR;

reg                                 Clk                        ;

reg                                 s_axis_data_tvalid         ;
reg                                 s_axis_data_tdata          ;
wire                                m_axis_data_tvalid         ;
wire                                m_axis_data_tdata          ;

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
    $dumpfile("tb_FIR.vcd");
    $dumpvars(0, tb_FIR);
end

initial begin
    #1 Clk<=1'bx;
    #(CLK_PERIOD*3) 
    #(CLK_PERIOD*3) Clk<=0;
    repeat(5) @(posedge Clk);
    @(posedge Clk);
    repeat(2) @(posedge Clk);
    $finish(2);
end

endmodule
`default_nettype wire