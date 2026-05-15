`timescale 1ns/1ps

module relabel #(
    parameter                           LABEL_RAM_AWIDTH            = 16    ,
    parameter                           PIX_POINT                   = 50000 ,
    parameter                           LABEL_WIDTH                 = 8     
) (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        eq_table_arr_done               ,

    output reg                                   first_label_rd                  ,
    output reg         [LABEL_RAM_AWIDTH-1: 0]   first_label_radd                ,
    input              [LABEL_WIDTH-1: 0]        first_label_rdat                ,

    output reg                                   eq_table_rd                     ,
    output reg         [LABEL_WIDTH-1: 0]        eq_table_radd                   ,
    input              [LABEL_WIDTH-1: 0]        eq_table_rdat                   ,

    output reg                                   final_label_vld                 ,
    output reg         [LABEL_WIDTH-1: 0]        final_label                     
);


reg                                          eq_table_arr_done_0                ;
reg                                          relabel_start                      ;
reg                                          first_label_rd_0                   ;
reg                                          eq_table_rd_0                      ;
reg                                          back_pix_label                     ;


always @(posedge clk) begin
    if (rst) begin
        first_label_rd <= 'b0;
    end
    else if (first_label_radd == (PIX_POINT - 1)) begin
        first_label_rd <= 'b0;
    end
    else if (eq_table_arr_done) begin
        first_label_rd <= 'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        first_label_radd <= 'd0;
    end
    else if (first_label_radd == (PIX_POINT - 1)) begin
        first_label_radd <= 'd0;
    end
    else if (first_label_rd) begin
        first_label_radd <= first_label_radd + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        eq_table_arr_done_0 <= 'b0;
        relabel_start <= 'b0;
    end
    else begin
        eq_table_arr_done_0 <= eq_table_arr_done;
        relabel_start <= eq_table_arr_done_0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        eq_table_radd <= 'd0;
    end
    else begin
        eq_table_radd <= first_label_rdat;
    end
end

always @(posedge clk) begin
    if (rst) begin
        first_label_rd_0 <= 'b0;
        eq_table_rd <= 'b0;
    end
    else begin
        first_label_rd_0 <= first_label_rd;
        eq_table_rd <= first_label_rd_0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        eq_table_rd_0 <= 'b0;
        final_label_vld <= 'b0;
    end
    else begin
        eq_table_rd_0 <= eq_table_rd;
        final_label_vld <= eq_table_rd_0;
    end
end

always @(posedge clk) begin
    if (eq_table_radd == 'd0) begin
        back_pix_label <= 'b1;
    end
    else begin
        back_pix_label <= 'b0;
    end
end

always @(posedge clk) begin
    final_label <= back_pix_label? 'd0 : eq_table_rdat;
end


endmodule