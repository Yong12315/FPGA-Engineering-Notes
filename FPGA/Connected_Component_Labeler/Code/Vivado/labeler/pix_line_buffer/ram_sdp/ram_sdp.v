`timescale 1ns/1ps

module ram_sdp #(
    parameter                           DWIDTH                      = 32    ,
    parameter                           AWIDTH                      = 16    
) (
    input                                        clka                            ,
    input                                        wea                             ,
    input              [AWIDTH-1: 0]             addra                           ,
    input              [DWIDTH-1: 0]             dina                            ,

    input                                        clkb                            ,
    input                                        enb                             ,
    input              [AWIDTH-1: 0]             addrb                           ,
    output reg         [DWIDTH-1: 0]             doutb                           
) ;


localparam                          MEM_SIZE                    = 2**AWIDTH;


reg                [DWIDTH-1: 0]                 ram[MEM_SIZE-1:0]                  ;


always @(posedge clka) begin
    if (wea) begin
        ram[addra] <= dina;
    end
end

always @(posedge clkb) begin
    if (enb) begin
        doutb <= ram[addrb];
    end
end


endmodule
