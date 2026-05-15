`timescale 1ns/1ps

module tb_ram_sdp;

localparam                          AWIDTH                      = 8     ;
localparam                          DWIDTH                      = 16    ;

reg                                          clka                               ;
reg                                          wea                              ='b0;
reg                [AWIDTH-1: 0]             addra                            ='d0;
reg                [DWIDTH-1: 0]             dina                             ='d0;

reg                                          clkb                               ;
reg                                          enb                              ='b0;
reg                [AWIDTH-1: 0]             addrb                            ='d0;

wire               [DWIDTH-1: 0]             doutb                              ;

reg                [   7: 0]                 cnt                              ='d0;

ram_sdp #(
    .AWIDTH                             (AWIDTH                    ),
    .DWIDTH                             (DWIDTH                    ) 
) U_ram_sdp (
    .clka                               (clka                      ),
    .wea                                (wea                       ),
    .addra                              (addra                     ),
    .dina                               (dina                      ),

    .clkb                               (clkb                      ),
    .enb                                (enb                       ),
    .addrb                              (addrb                     ),
    .doutb                              (doutb                     ) 
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clka=~clka;
always #(CLK_PERIOD/2) clkb=~clkb;

always @(posedge clka) begin
    cnt <= cnt + 1;
end

always @(posedge clka) begin
    if (cnt == 'd10) begin
        wea <= 'b1;
    end
    else if (cnt == 'd100) begin
        wea <= 'b0;
    end
end

always @(posedge clka) begin
    if (wea) begin
        addra <= addra + 1;
    end
end

always @(posedge clka) begin
    if (wea) begin
        dina <= {$random} % 65536;
    end
end

always @(posedge clkb) begin
    if (cnt == 'd110) begin
        enb <= 'b1;
    end
    else if (cnt == 'd200) begin
        enb <= 'b0;
    end
end

always @(posedge clkb) begin
    if (enb) begin
        addrb <= addrb + 1;
    end
end

initial begin
    #1 clka<=1'bx;
    clkb = 'bx;
    #(CLK_PERIOD*3) 
    #(CLK_PERIOD*3) clka<=0;
    clkb = 'b0;
    repeat(5) @(posedge clka);
    @(posedge clka);
    repeat(2) @(posedge clka);

end

endmodule
