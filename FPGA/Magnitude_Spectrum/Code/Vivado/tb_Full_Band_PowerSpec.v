`timescale 1ns/1ps
`default_nettype none

module tb_Full_Band_PowerSpec;

reg                                 Clk                        ;
reg                                 Rst                        ;

wire                                s_axis_data_tready         ;
reg                                 s_axis_data_tvalid       ='b0 ;
reg                  [  31: 0]      s_axis_data_tdata          ;
reg                                 s_axis_data_tlast        ='b0;

wire                                Full_Band_FFT_tready       ;
wire                                Full_Band_FFT_tvalid       ;
wire                 [  63: 0]      Full_Band_FFT_tdata        ;
wire                 [  15: 0]      Full_Band_FFT_tuser        ;
wire                                Full_Band_FFT_tlast        ;

wire                                event_frame_started        ;
wire                                event_tlast_unexpected     ;
wire                                event_tlast_missing        ;
wire                                event_status_channel_halt  ;
wire                                event_data_in_channel_halt  ;
wire                                event_data_out_channel_halt  ;

wire                                Full_Band_PowerSpec_tvalid  ;
wire                 [  31: 0]      Full_Band_PowerSpec_tdata  ;
wire                 [  15: 0]      Full_Band_PowerSpec_tuser  ;
wire                                Full_Band_PowerSpec_tlast  ;


reg                  [  32: 0]      IQ_Input[0:8191]           ;


reg                  [  15: 0]      Cnt                        ;


xfft_0 u_xfft (
    .aclk                               (Clk                       ),// input wire aclk
    .s_axis_config_tdata                (8'd1                      ),// input wire [7 : 0] s_axis_config_tdata
    .s_axis_config_tvalid               (1'b1                      ),// input wire s_axis_config_tvalid
    .s_axis_config_tready               (                          ),// output wire s_axis_config_tready
    .s_axis_data_tdata                  (s_axis_data_tdata         ),// input wire [31 : 0] s_axis_data_tdata
    .s_axis_data_tvalid                 (s_axis_data_tvalid        ),// input wire s_axis_data_tvalid
    .s_axis_data_tready                 (s_axis_data_tready        ),// output wire s_axis_data_tready
    .s_axis_data_tlast                  (s_axis_data_tlast         ),// input wire s_axis_data_tlast
    .m_axis_data_tdata                  (Full_Band_FFT_tdata       ),// output wire [63 : 0] m_axis_data_tdata
    .m_axis_data_tuser                  (Full_Band_FFT_tuser       ),// output wire [15 : 0] m_axis_data_tuser
    .m_axis_data_tvalid                 (Full_Band_FFT_tvalid      ),// output wire m_axis_data_tvalid
    .m_axis_data_tready                 (Full_Band_FFT_tready      ),// input wire m_axis_data_tready
    .m_axis_data_tlast                  (Full_Band_FFT_tlast       ),// output wire m_axis_data_tlast
    .event_frame_started                (event_frame_started       ),// output wire event_frame_started
    .event_tlast_unexpected             (event_tlast_unexpected    ),// output wire event_tlast_unexpected
    .event_tlast_missing                (event_tlast_missing       ),// output wire event_tlast_missing
    .event_status_channel_halt          (event_status_channel_halt ),// output wire event_status_channel_halt
    .event_data_in_channel_halt         (event_data_in_channel_halt),// output wire event_data_in_channel_halt
    .event_data_out_channel_halt        (event_data_out_channel_halt) // output wire event_data_out_channel_halt
);

Full_Band_PowerSpec u_Full_Band_PowerSpec (
    .Clk                                (Clk                       ),
    .Rst                                (Rst                       ),
    .Full_Band_FFT_tvalid               (Full_Band_FFT_tvalid      ),
    .Full_Band_FFT_tready               (Full_Band_FFT_tready      ),
    .Full_Band_FFT_tdata                (Full_Band_FFT_tdata       ),
    .Full_Band_FFT_tuser                (Full_Band_FFT_tuser       ),
    .Full_Band_FFT_tlast                (Full_Band_FFT_tlast       ),
    .Full_Band_PowerSpec_tvalid         (Full_Band_PowerSpec_tvalid),
    .Full_Band_PowerSpec_tdata          (Full_Band_PowerSpec_tdata ),
    .Full_Band_PowerSpec_tuser          (Full_Band_PowerSpec_tuser ),
    .Full_Band_PowerSpec_tlast          (Full_Band_PowerSpec_tlast ) 
);


initial begin
    $readmemh("IQ_Data.mem", IQ_Input);
end

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) Clk=~Clk;

initial begin
    #1 Rst<=1'bx;Clk<=1'bx;
    #(CLK_PERIOD*3) Rst<=0;
    #(CLK_PERIOD*3) Rst<=1;Clk<=0;
    repeat(5) @(posedge Clk);
    Rst<=0;
    s_axis_data_tvalid = 'b0;
    s_axis_data_tlast = 'b0;
    @(posedge Clk);
    repeat(2) @(posedge Clk);
    #1;
    #(CLK_PERIOD*300);
    s_axis_data_tvalid = 'b1;
    #(CLK_PERIOD*8191);
    s_axis_data_tlast = 'b1;
    #(CLK_PERIOD)
    s_axis_data_tvalid = 'b0;
    s_axis_data_tlast = 'b0;
end

always @(*) begin
    if (Rst) begin
        s_axis_data_tdata = 'd0;
    end
    else if (s_axis_data_tvalid && s_axis_data_tready) begin
        s_axis_data_tdata = IQ_Input[Cnt];
    end
    else begin
        s_axis_data_tdata = 'd0;
    end
end

always @(posedge Clk) begin
    if (Rst) begin
        Cnt <= 'd0;
    end
    else if (s_axis_data_tvalid) begin
        Cnt <= Cnt + 1;
    end
    else begin
        Cnt <= 'd0;
    end
end


endmodule
`default_nettype wire