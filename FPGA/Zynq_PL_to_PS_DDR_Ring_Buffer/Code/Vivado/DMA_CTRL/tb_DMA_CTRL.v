`timescale 1ns/1ps

`default_nettype none

module tb_DMA_CTRL;

reg                                 Clk                         ;
reg                                 Rst                         ;
reg                                 PL2PS_DMA_Done              ;

wire                                PL2PS_DMA_Start             ;
wire               [  31: 0]        axiOut_Offset               ;

reg                [  15: 0]        cnt                         ;


DMA_CTRL U_DMA_CTRL (
    .Clk                                (Clk                       ),
    .Rst                                (Rst                       ),
    .PL2PS_DMA_Done                     (PL2PS_DMA_Done            ),

    .PL2PS_DMA_Start                    (PL2PS_DMA_Start           ),
    .axiOut_Offset                      (axiOut_Offset             ) 
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) Clk=~Clk;

always @(posedge Clk) begin
    if (Rst) begin
        cnt <= 'd0;
    end
    else if (cnt == 'd10000) begin
        cnt <= 'd0;
    end
    else begin
        cnt <= cnt + 1;
    end
end

always @(posedge Clk) begin
    if (Rst) begin
        PL2PS_DMA_Done <= 'b0;
    end
    else if (cnt == 'd10000) begin
        PL2PS_DMA_Done <= 'b1;
    end
    else begin
        PL2PS_DMA_Done <= 'b0;
    end
end

initial begin
    #1 Rst<=1'bx;Clk<=1'bx;
    #(CLK_PERIOD*3) Rst<=0;
    #(CLK_PERIOD*3) Rst<=1;Clk<=0;
    repeat(5) @(posedge Clk);
    Rst<=0;
    PL2PS_DMA_Done = 'b0;
    @(posedge Clk);
    repeat(2) @(posedge Clk);

end

endmodule
`default_nettype wire
