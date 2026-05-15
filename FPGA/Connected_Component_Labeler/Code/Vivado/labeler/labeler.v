`timescale 1ns/1ps

module labeler #(
    parameter                           FRONT_PIX                   = 1'b1  ,
    parameter                           IMG_ROWS                    = 361 ,
    parameter                           IMG_COLS                    = 478 ,
    parameter                           LABEL_WIDTH                 = 8     
)(
    input                                        clk                             ,// 20Mhz
    input                                        ce                              ,
    input                                        rst                             ,

    input                                        frame_vld                       ,
    input                                        line_vld                        ,// binary line valid
    input                                        bin_dat                         ,// binary data

    output                                       final_label_vld                 ,
    output             [LABEL_WIDTH-1: 0]        final_label                     ,
    output                                       num_label_vld                   ,
    output             [LABEL_WIDTH-1: 0]        num_label                        // total number of target area
);


// function called clogb2 that returns an integer which has the                      
// value of the ceiling of the log base 2.                                           
function integer clogb2 (input integer bit_depth);                                   
begin                                                                              
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
        bit_depth = bit_depth >> 1;
end                                                                                
endfunction

localparam                          PIX_POINT                   = IMG_ROWS*IMG_COLS;
localparam                          LABEL_RAM_AWIDTH            = clogb2(PIX_POINT);
localparam                          ROW_CNT_WIDTH               = clogb2(IMG_ROWS);
localparam                          COL_CNT_WIDTH               = clogb2(IMG_COLS);


reg                                          line_vld_0                         ;
reg                                          line_vld_1                         ;
reg                                          line_vld_2                         ;
reg                                          bin_dat_0                          ;
reg                                          bin_dat_1                          ;
reg                                          bin_dat_2                          ;
reg                                          pix_d                              ;
reg                                          pix_c                              ;
reg                                          pix_b                              ;
reg                                          pix_a                              ;
reg                [ROW_CNT_WIDTH-1: 0]      row_cnt_1                          ;
reg                [COL_CNT_WIDTH-1: 0]      col_cnt_1                          ;
reg                [LABEL_WIDTH-1: 0]        label_d                            ;
reg                [LABEL_WIDTH-1: 0]        label_c                            ;
reg                [LABEL_WIDTH-1: 0]        label_b                            ;
reg                [LABEL_WIDTH-1: 0]        label_a                            ;
reg                [LABEL_RAM_AWIDTH-1: 0]   first_label_wadd                   ;

wire                                         pix_x_vld                          ;
wire                                         d1l_dat_vld                        ;
wire                                         pix_x                              ;
wire                                         d1l_dat                            ;
wire                                         line_vld_f                         ;
wire                                         first_label_vld                    ;
wire               [LABEL_WIDTH-1: 0]        first_label                        ;
wire               [LABEL_WIDTH-1: 0]        label_x                            ;
wire               [LABEL_WIDTH-1: 0]        d1l_label                          ;
wire                                         init                               ;
wire               [LABEL_WIDTH-1: 0]        new_label                          ;
wire               [LABEL_WIDTH-1: 0]        max_label                          ;
wire                                         equal                              ;
wire               [LABEL_WIDTH-1: 0]        label_1                            ;
wire               [LABEL_WIDTH-1: 0]        label_2                            ;
wire                                         table_1_sel                        ;
wire                                         table_2_sel                        ;
wire                                         eq_table_rd                        ;
wire               [LABEL_WIDTH-1: 0]        eq_table_radd                      ;
wire               [LABEL_WIDTH-1: 0]        eq_table_rdat                      ;
wire                                         eq_table_arr_done                  ;
wire                                         first_label_rd                     ;
wire               [LABEL_RAM_AWIDTH-1: 0]   first_label_radd                   ;
wire               [LABEL_WIDTH-1: 0]        first_label_rdat                   ;


pix_line_buffer #(
    .DEPTH                              (IMG_COLS                  ) 
) U_pix_line_buffer (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .line_vld                           (line_vld                  ),
    .bin_dat                            (bin_dat                   ),

    .d1l_dat_vld                        (d1l_dat_vld               ),
    .d1l_dat                            (d1l_dat                   ) 
);

always @(posedge clk) begin
    if (rst) begin
        line_vld_0 <= 'b0;
        line_vld_1 <= 'b0;
        line_vld_2 <= 'b0;
    end
    else begin
        line_vld_0 <= line_vld;
        line_vld_1 <= line_vld_0;
        line_vld_2 <= line_vld_1;
    end
end

assign                              line_vld_f                  = ~line_vld_0 & line_vld_1;

assign                              pix_x_vld                   = line_vld_2;

always @(posedge clk) begin
    bin_dat_0 <= bin_dat;
    bin_dat_1 <= bin_dat_0;
    bin_dat_2 <= bin_dat_1;
end

assign                              pix_x                       = bin_dat_2;

always @(posedge clk) begin
    pix_d <= pix_x;
end

always @(posedge clk) begin
    pix_c <= d1l_dat;
    pix_b <= pix_c;
    pix_a <= pix_b;
end

always @(posedge clk) begin
    if (rst) begin
        row_cnt_1 <= 'd0;
    end
    else if (line_vld_f && (row_cnt_1 == (IMG_ROWS - 1))) begin
        row_cnt_1 <= 'd0;
    end
    else if (line_vld_f) begin
        row_cnt_1 <= row_cnt_1 + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        col_cnt_1 <= 'd0;
    end
    else if (col_cnt_1 == (IMG_COLS - 1)) begin
        col_cnt_1 <= 'd0;
    end
    else if (line_vld_1) begin
        col_cnt_1 <= col_cnt_1 + 1;
    end
end

first_label #(
    .FRONT_PIX                          (FRONT_PIX                 ),
    .LABEL_WIDTH                        (LABEL_WIDTH               ),
    .IMG_COLS                           (IMG_COLS                  ),
    .ROW_CNT_WIDTH                      (ROW_CNT_WIDTH             ),
    .COL_CNT_WIDTH                      (COL_CNT_WIDTH             )
) U_first_label (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .pix_x_vld                          (pix_x_vld                 ),
    .pix_x                              (pix_x                     ),
    .pix_d                              (pix_d                     ),
    .pix_c                              (pix_c                     ),
    .pix_b                              (pix_b                     ),
    .pix_a                              (pix_a                     ),
    .row_cnt                            (row_cnt_1                 ),
    .col_cnt                            (col_cnt_1                 ),
    .label_d                            (label_d                   ),
    .label_c                            (label_c                   ),
    .label_b                            (label_b                   ),
    .label_a                            (label_a                   ),
    .frame_vld                          (frame_vld                 ),

    .label_x                            (label_x                   ),
    .first_label_vld                    (first_label_vld           ),
    .first_label                        (first_label               ),
    .init                               (init                      ),
    .new_label                          (new_label                 ),
    .max_label                          (max_label                 ),
    .equal                              (equal                     ),
    .label_1                            (label_1                   ),
    .label_2                            (label_2                   ) 
);

always @(*) begin
    label_d = label_x;
end

always @(posedge clk) begin
    label_c <= d1l_label;
    label_b <= label_c;
    label_a <= label_b;
end

label_line_buffer #(
    .LABEL_WIDTH                        (LABEL_WIDTH               ),
    .DEPTH                              (IMG_COLS                  ) 
)U_label_line_buffer (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .first_label_vld                    (first_label_vld           ),
    .first_label                        (first_label               ),
    .buffer_rd                          (line_vld                  ),

    .d1l_label                          (d1l_label                 )
);

eq_ctrl u_eq_ctrl (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .frame_vld                          (frame_vld                 ),

    .table_1_sel                        (table_1_sel               ),
    .table_2_sel                        (table_2_sel               ) 
);

eq_relation #(
    .LABEL_WIDTH                        (LABEL_WIDTH               ) 
) u_eq_relation (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .frame_vld                          (frame_vld                 ),
    .table_1_sel                        (table_1_sel               ),
    .table_2_sel                        (table_2_sel               ),
    .init                               (init                      ),
    .new_label                          (new_label                 ),
    .max_label                          (max_label                 ),
    .equal                              (equal                     ),
    .label_1                            (label_1                   ),
    .label_2                            (label_2                   ),

    .eq_table_rd                        (eq_table_rd               ),
    .eq_table_radd                      (eq_table_radd             ),
    .eq_table_rdat                      (eq_table_rdat             ),

    .num_label_vld                      (num_label_vld             ),
    .num_label                          (num_label                 ),
    .eq_table_arr_done                  (eq_table_arr_done         )
);

always @(posedge clk) begin
    if (rst) begin
        first_label_wadd <= 'd0;
    end
    else if (first_label_wadd == (PIX_POINT - 1)) begin
        first_label_wadd <= 'd0;
    end
    else if (first_label_vld) begin
        first_label_wadd <= first_label_wadd + 1;
    end
end

ram_sdp #(
    .AWIDTH                             (LABEL_RAM_AWIDTH          ),
    .DWIDTH                             (LABEL_WIDTH               ) 
) first_label_ram (
    .clka                               (clk                       ),
    .wea                                (first_label_vld           ),
    .addra                              (first_label_wadd          ),
    .dina                               (first_label               ),

    .clkb                               (clk                       ),
    .enb                                (first_label_rd            ),
    .addrb                              (first_label_radd          ),
    .doutb                              (first_label_rdat          ) 
);

relabel #(
    .LABEL_RAM_AWIDTH                   (LABEL_RAM_AWIDTH          ),
    .PIX_POINT                          (PIX_POINT                 ),
    .LABEL_WIDTH                        (LABEL_WIDTH               ) 
) u_relabel (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .eq_table_arr_done                  (eq_table_arr_done         ),
    .first_label_rd                     (first_label_rd            ),
    .first_label_radd                   (first_label_radd          ),
    .first_label_rdat                   (first_label_rdat          ),
    .eq_table_rd                        (eq_table_rd               ),
    .eq_table_radd                      (eq_table_radd             ),
    .eq_table_rdat                      (eq_table_rdat             ),

    .final_label_vld                    (final_label_vld           ),
    .final_label                        (final_label               ) 
);


endmodule
