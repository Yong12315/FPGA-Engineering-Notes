`timescale 1ns/1ps

module eq_relation #(
    parameter                           LABEL_WIDTH                 = 4     
) (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        frame_vld                       ,
    input                                        table_1_sel                     ,
    input                                        table_2_sel                     ,
    input                                        init                            ,
    input              [LABEL_WIDTH-1: 0]        new_label                       ,
    input              [LABEL_WIDTH-1: 0]        max_label                       ,
    input                                        equal                           ,
    input              [LABEL_WIDTH-1: 0]        label_1                         ,
    input              [LABEL_WIDTH-1: 0]        label_2                         ,

    input                                        eq_table_rd                     ,
    input              [LABEL_WIDTH-1: 0]        eq_table_radd                   ,
    output             [LABEL_WIDTH-1: 0]        eq_table_rdat                   ,

    output reg                                   num_label_vld                   ,
    output reg         [LABEL_WIDTH-1: 0]        num_label                       ,
    output                                       eq_table_arr_done               
);


wire                                         table_1_arr_done                   ;
wire                                         table_2_arr_done                   ;
wire               [LABEL_WIDTH-1: 0]        table_1_num_label                  ;
wire               [LABEL_WIDTH-1: 0]        table_2_num_label                  ;
wire                                         eq_table_1_rd                      ;
wire                                         eq_table_2_rd                      ;
wire               [LABEL_WIDTH-1: 0]        eq_table_1_rdat                    ;
wire               [LABEL_WIDTH-1: 0]        eq_table_2_rdat                    ;

reg                                          table_rd_sel                       ;


eq_table #(
    .LABEL_WIDTH                        (LABEL_WIDTH               ) 
) u0_eq_table (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .frame_vld                          (frame_vld                 ),
    .table_sel                          (table_1_sel               ),
    .init                               (init                      ),
    .new_label                          (new_label                 ),
    .max_label                          (max_label                 ),
    .equal                              (equal                     ),
    .label_1                            (label_1                   ),
    .label_2                            (label_2                   ),

    .table_rd                           (eq_table_1_rd             ),
    .table_radd                         (eq_table_radd             ),
    .table_rdat                         (eq_table_1_rdat           ),

    .arr_done                           (table_1_arr_done          ),
    .num_label                          (table_1_num_label         ) 
);

eq_table #(
    .LABEL_WIDTH                        (LABEL_WIDTH               ) 
) u1_eq_table (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .frame_vld                          (frame_vld                 ),
    .table_sel                          (table_2_sel               ),
    .init                               (init                      ),
    .new_label                          (new_label                 ),
    .max_label                          (max_label                 ),
    .equal                              (equal                     ),
    .label_1                            (label_1                   ),
    .label_2                            (label_2                   ),

    .table_rd                           (eq_table_2_rd             ),
    .table_radd                         (eq_table_radd             ),
    .table_rdat                         (eq_table_2_rdat           ),

    .arr_done                           (table_2_arr_done          ),
    .num_label                          (table_2_num_label         ) 
);

always @(posedge clk) begin
    if (rst) begin
        num_label_vld <= 'b0;
    end
    else begin
        num_label_vld <= table_1_arr_done || table_2_arr_done;
    end
end

always @(posedge clk) begin
    if (rst) begin
        num_label <= 'd0;
    end
    else if (table_1_arr_done) begin
        num_label <= table_1_num_label;
    end
    else if (table_2_arr_done) begin
        num_label <= table_2_num_label;
    end
end

always @(posedge clk) begin
    if (rst) begin
        table_rd_sel <= 'b0;
    end
    else if (table_1_arr_done) begin
        table_rd_sel <= 'b1;
    end
    else if (table_2_arr_done) begin
        table_rd_sel <= 'b0;
    end
end

assign                              eq_table_1_rd               = table_rd_sel && eq_table_rd;
assign                              eq_table_2_rd               = ~table_rd_sel && eq_table_rd;
assign                              eq_table_arr_done           = table_1_arr_done || table_2_arr_done;
assign                              eq_table_rdat               = table_rd_sel? eq_table_1_rdat : eq_table_2_rdat;


endmodule