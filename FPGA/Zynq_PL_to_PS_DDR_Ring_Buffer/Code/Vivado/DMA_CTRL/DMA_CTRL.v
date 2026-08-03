`timescale 1ns/1ps
`default_nettype none


module DMA_CTRL #(
    parameter                           DATA_SIZE                   = 'd32848              ,
    parameter                           FIRST_ADDR                  = 32'h3E00_0000        ,
    parameter                           LAST_ADDR                   = 32'h3FFF_0000        
) (
    input  wire                         Clk                        ,
    input  wire                         Rst                        ,

    input  wire                         PL2PS_DMA_Done             ,

    output reg                          PL2PS_DMA_Start            ,
    output reg           [  31: 0]      axiOut_Offset              ,
    output wire          [  15: 0]      DataLength                 
);


assign                              DataLength                  = DATA_SIZE/4          ;

always @(posedge Clk) begin
    if (Rst) begin
        PL2PS_DMA_Start <= 'b0;
    end
    else begin
        PL2PS_DMA_Start <= 'b1;
    end
end

always @(posedge Clk) begin
    if (Rst) begin
        axiOut_Offset <= FIRST_ADDR;
    end
    else if ((axiOut_Offset == LAST_ADDR) && PL2PS_DMA_Done) begin
        axiOut_Offset <= FIRST_ADDR;
    end
    else if (PL2PS_DMA_Done) begin
        axiOut_Offset <= axiOut_Offset + 32'h0001_0000;
    end
end


endmodule

`default_nettype wire
