`timescale 1ns/1ps
`default_nettype none

module Full_Band_PowerSpec #(
    parameter                           IQ_WIDTH                    = 16                   ,
    parameter                           FFT_WINDOW_LENGTH           = 8192                 
) (
    input  wire                             Clk                        ,
    input  wire                             Rst                        ,

    input  wire                             Full_Band_FFT_tvalid       ,
    output wire                             Full_Band_FFT_tready       ,
    input  wire          [  63: 0]          Full_Band_FFT_tdata        ,
    input  wire          [  15: 0]          Full_Band_FFT_tuser        ,
    input  wire                             Full_Band_FFT_tlast        ,

    output wire                             Full_Band_PowerSpec_tvalid ,
    output wire          [  31: 0]          Full_Band_PowerSpec_tdata  ,
    output wire          [  15: 0]          Full_Band_PowerSpec_tuser  ,
    output wire                             Full_Band_PowerSpec_tlast         
);


assign                              Full_Band_FFT_tready        = 'b1                  ;


reg                  [2*(IQ_WIDTH+12)-1: 0] Data_IQ                    ;
reg                                         Data_IQ_Val                ;
reg                  [  15: 0]              IQ_Index                   ;
reg                                         IQ_Last                    ;

always @(posedge Clk) begin
    if (Full_Band_FFT_tvalid) begin
        Data_IQ <= {Full_Band_FFT_tdata[59:32], Full_Band_FFT_tdata[27:0]};
        IQ_Index <= Full_Band_FFT_tuser;
    end
    else begin
        Data_IQ <= 'd0;
        IQ_Index <= 'd0;
    end
end

always @(posedge Clk) begin
    if (Rst) begin
        Data_IQ_Val <= 'b0;
        IQ_Last <= 'b0;
    end
    else begin
        Data_IQ_Val <= Full_Band_FFT_tvalid;
        IQ_Last <= Full_Band_FFT_tlast;
    end
end

/*********************************************** FFT Shift ***********************************************/
wire                 [2*(IQ_WIDTH+12)-1: 0] IQ_Delay                   ;
wire                                        Shift_IQ_Val               ;
reg                  [2*(IQ_WIDTH+12)-1: 0] Shift_IQ                   ;
wire                 [  15: 0]              Shift_IQ_Index             ;
wire                                        Shift_IQ_Last              ;

reg                                         Shift_IQ_Val_Reg           ;
reg                  [2*(IQ_WIDTH+12)-1: 0] Shift_IQ_Reg               ;
reg                  [  15: 0]              Shift_IQ_Index_Reg         ;
reg                                         Shift_IQ_Last_Reg          ;

shiftreg #(
    .WIDTH                              (2*(IQ_WIDTH+12)           ),
    .LENGTH                             (FFT_WINDOW_LENGTH         ) 
) Data_IQ_shiftreg (
    .CLK                                (Clk                       ),
    .D                                  (Data_IQ                   ),
    .Q                                  (IQ_Delay                  ),
    .CE                                 ('b1                       ) 
);

shiftreg #(
    .WIDTH                              (1                         ),
    .LENGTH                             (FFT_WINDOW_LENGTH/2       ) 
) Data_IQ_Val_shiftreg (
    .CLK                                (Clk                       ),
    .D                                  (Data_IQ_Val               ),
    .Q                                  (Shift_IQ_Val              ),
    .CE                                 ('b1                       ) 
);

shiftreg #(
    .WIDTH                              (16                        ),
    .LENGTH                             (FFT_WINDOW_LENGTH/2       ) 
) IQ_Index_shiftreg (
    .CLK                                (Clk                       ),
    .D                                  (IQ_Index                  ),
    .Q                                  (Shift_IQ_Index            ),
    .CE                                 ('b1                       ) 
);

shiftreg #(
    .WIDTH                              (1                         ),
    .LENGTH                             (FFT_WINDOW_LENGTH/2       ) 
) IQ_Last_shiftreg (
    .CLK                                (Clk                       ),
    .D                                  (IQ_Last                   ),
    .Q                                  (Shift_IQ_Last             ),
    .CE                                 ('b1                       ) 
);

always @(*) begin
    if (Shift_IQ_Val && (Shift_IQ_Index < FFT_WINDOW_LENGTH/2)) begin
        Shift_IQ = Data_IQ;
    end
    else if (Shift_IQ_Val && (Shift_IQ_Index >= FFT_WINDOW_LENGTH/2)) begin
        Shift_IQ = IQ_Delay;
    end
end

always @(posedge Clk) begin
    Shift_IQ_Val_Reg <= Shift_IQ_Val;
    Shift_IQ_Last_Reg <= Shift_IQ_Last;
end

always @(posedge Clk) begin
    Shift_IQ_Reg <= Shift_IQ;
    Shift_IQ_Index_Reg <= Shift_IQ_Index;
end
/************************************************************************************************************/

reg                                     Abs_IQ_Val                 ;
reg     signed       [IQ_WIDTH+12-1: 0] Abs_I                      ;
reg     signed       [IQ_WIDTH+12-1: 0] Abs_Q                      ;
reg                  [  15: 0]          Shift_IQ_Index_Reg_1       ;
reg                                     Abs_IQ_Last                ;

always @(posedge Clk) begin
    if (Rst) begin
        Abs_IQ_Val <= 'b0;
        Abs_IQ_Last <= 'b0;
    end
    else begin
        Abs_IQ_Val <= Shift_IQ_Val_Reg;
        Abs_IQ_Last <= Shift_IQ_Last_Reg;
    end
end

always @(posedge Clk) begin
    if (Shift_IQ_Val_Reg) begin
        Shift_IQ_Index_Reg_1 <= Shift_IQ_Index_Reg;
    end
end

always @(posedge Clk) begin
    if (Shift_IQ_Val_Reg && (Shift_IQ_Reg[IQ_WIDTH+12-1] == 'b0)) begin
        Abs_I <= $signed(Shift_IQ_Reg[IQ_WIDTH+12-1: 0]);
    end
    else if (Shift_IQ_Val_Reg && (Shift_IQ_Reg[IQ_WIDTH+12-1] == 'b1)) begin
        Abs_I <= -$signed(Shift_IQ_Reg);
    end
end

always @(posedge Clk) begin
    if (Shift_IQ_Val_Reg && (Shift_IQ_Reg[2*(IQ_WIDTH+12)-1] == 'b0)) begin
        Abs_Q <= $signed(Shift_IQ_Reg[2*(IQ_WIDTH+12)-1:IQ_WIDTH+12]);
    end
    else if (Shift_IQ_Val_Reg && (Shift_IQ_Reg[2*(IQ_WIDTH+12)-1] == 'b1)) begin
        Abs_Q <= -$signed(Shift_IQ_Reg[2*(IQ_WIDTH+12)-1:IQ_WIDTH+12]);
    end
end


reg                                     Max_Min_Val                ;
reg                  [IQ_WIDTH+12-1: 0] Max_Abs_IQ                 ;
reg                  [IQ_WIDTH+12-1: 0] Min_Abs_IQ                 ;
reg                  [  15: 0]          Shift_IQ_Index_Reg_2       ;
reg                                     Max_Min_Last               ;

always @(posedge Clk) begin
    if (Rst) begin
        Max_Min_Val <= 'b0;
        Max_Min_Last <= 'b0;
    end
    else begin
        Max_Min_Val <= Abs_IQ_Val;
        Max_Min_Last <= Abs_IQ_Last;
    end
end

always @(posedge Clk) begin
    if (Abs_IQ_Val) begin
        Shift_IQ_Index_Reg_2 <= Shift_IQ_Index_Reg_1;
    end
end

always @(posedge Clk) begin
    if (Abs_IQ_Val && (Abs_I >= Abs_Q)) begin
        Max_Abs_IQ <= Abs_I;
    end
    else if (Abs_IQ_Val && (Abs_I < Abs_Q)) begin
        Max_Abs_IQ <= Abs_Q;
    end
end

always @(posedge Clk) begin
    if (Abs_IQ_Val && (Abs_I >= Abs_Q)) begin
        Min_Abs_IQ <= Abs_Q;
    end
    else if (Abs_IQ_Val && (Abs_I < Abs_Q)) begin
        Min_Abs_IQ <= Abs_I;
    end
end


reg                                     Mag_IQ_Val                 ;
reg                  [IQ_WIDTH+12: 0]   Mag_IQ                     ;
reg                  [  15: 0]          Shift_IQ_Index_Reg_3       ;
reg                                     Mag_IQ_Last                ;

always @(posedge Clk) begin
    if (Rst) begin
        Mag_IQ_Val <= 'b0;
        Mag_IQ_Last <= 'b0;
    end
    else begin
        Mag_IQ_Val <= Max_Min_Val;
        Mag_IQ_Last <= Max_Min_Last;
    end
end

always @(posedge Clk) begin
    if (Max_Min_Val) begin
        Shift_IQ_Index_Reg_3 <= Shift_IQ_Index_Reg_2;
    end
    else begin
        Shift_IQ_Index_Reg_3 <= 'd0;
    end
end

always @(posedge Clk) begin
    if (Max_Min_Val) begin
        Mag_IQ <= ((Max_Abs_IQ - (Max_Abs_IQ>>>4)) + ((Min_Abs_IQ>>>1) - (Min_Abs_IQ>>>5)));
    end
    else begin
        Mag_IQ <= 'd0;
    end
end


assign Full_Band_PowerSpec_tvalid = Mag_IQ_Val;
assign Full_Band_PowerSpec_tdata = {{(31-(IQ_WIDTH+12)){1'b0}}, Mag_IQ};
assign Full_Band_PowerSpec_tuser = Shift_IQ_Index_Reg_3;
assign Full_Band_PowerSpec_tlast = Mag_IQ_Last;

endmodule

`default_nettype wire