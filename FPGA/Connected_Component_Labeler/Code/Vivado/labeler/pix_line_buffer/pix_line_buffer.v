`timescale 1ns/1ps

module pix_line_buffer #(
    parameter                           DEPTH                       = 'd351 
) (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        line_vld                        ,
    input                                        bin_dat                         ,

    output reg                                   d1l_dat_vld                     ,
    output                                       d1l_dat                         
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


reg                                          line_vld_0                         ;
reg                                          bin_dat_0                          ;
reg                [RAM_AWIDTH-1: 0]         d1l_ram_wadd                       ;
reg                [RAM_AWIDTH-1: 0]         d1l_ram_radd                       ;

wire                                         d1l_ram_wr                         ;
wire                                         d1l_ram_rd                         ;
wire                                         d1l_ram_rdat                       ;


always @(posedge clk) begin
    if (rst) begin
        line_vld_0 <= 'b0;
    end
    else begin
        line_vld_0 <= line_vld;
    end
end

always @(posedge clk) begin
    bin_dat_0 <= bin_dat;
end

assign                              d1l_ram_wr                  = line_vld_0;

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

assign                              d1l_ram_wdat                = bin_dat_0;

/*************************************************************************************************************************************/
assign                              d1l_ram_rd                  = line_vld;

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

always @(posedge clk) begin
    if (rst) begin
        d1l_dat_vld <= 'b0;
    end
    else begin
        d1l_dat_vld <= d1l_ram_rd;
    end
end

assign                              d1l_dat                     = d1l_ram_rdat;

ram_sdp #(
    .AWIDTH                             (RAM_AWIDTH                ),
    .DWIDTH                             (1                         ) 
) d1l_ram (
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