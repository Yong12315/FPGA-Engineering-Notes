`timescale 1ns/1ps

module label_line_buffer #(
    parameter                           LABEL_WIDTH                 = 8     ,
    parameter                           DEPTH                       = 'd351 
) (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        first_label_vld                 ,
    input              [LABEL_WIDTH-1: 0]        first_label                     ,

    input                                        buffer_rd                       ,
    output             [LABEL_WIDTH-1: 0]        d1l_label                       
);

// function called clogb2 that returns an integer which has the                      
// value of the ceiling of the log base 2.                                           
function integer clogb2 (input integer bit_depth);                                   
begin                                                                              
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
        bit_depth = bit_depth >> 1;
end                                                                                
endfunction

localparam RAM_AWIDTH = clogb2(DEPTH);


reg                [RAM_AWIDTH-1: 0]         d1l_ram_wadd                       ;
reg                [RAM_AWIDTH-1: 0]         d1l_ram_radd                       ;

wire                                         d1l_ram_wr                         ;
wire               [RAM_AWIDTH-1: 0]         d1l_ram_wdat                       ;
wire                                         d1l_ram_rd                         ;
wire               [RAM_AWIDTH-1: 0]         d1l_ram_rdat                       ;


assign                              d1l_ram_wr                  = first_label_vld;

always @(posedge clk) begin
    if (rst) begin
        d1l_ram_wadd <= 'd0 ;
    end
    else if (d1l_ram_wadd == (DEPTH - 1)) begin
        d1l_ram_wadd <= 'd0;
    end
    else if (d1l_ram_wr) begin
        d1l_ram_wadd <= d1l_ram_wadd + 1'b1 ;
    end
end

assign                              d1l_ram_wdat                = first_label;

assign                              d1l_ram_rd                  = buffer_rd;

always @(posedge clk) begin
    if (rst) begin
        d1l_ram_radd <= 0 ;
    end
    else if (d1l_ram_radd == (DEPTH - 1)) begin
        d1l_ram_radd <= 'd0;
    end
    else if(d1l_ram_rd) begin
        d1l_ram_radd <= d1l_ram_radd + 1'b1 ;
    end
end

assign                              d1l_label                   = d1l_ram_rdat;

ram_sdp #(
    .AWIDTH                             (RAM_AWIDTH                ),
    .DWIDTH                             (LABEL_WIDTH               ) 
) U_ram_sdp (
    .clka                               (clk                       ),
    .wea                                (d1l_ram_wr                ),
    .addra                              (d1l_ram_wadd              ),
    .dina                               (d1l_ram_wdat              ),

    .clkb                               (clk                       ),
    .enb                                (d1l_ram_rd                ),
    .addrb                              (d1l_ram_radd              ),
    .doutb                              (d1l_ram_rdat              ) 
);

endmodule