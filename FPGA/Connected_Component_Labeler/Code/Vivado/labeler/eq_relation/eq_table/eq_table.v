`timescale 1ns/1ps

module eq_table #(
    parameter                           LABEL_WIDTH                 = 4     
) (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        frame_vld                       ,
    input                                        table_sel                       ,
    input                                        init                            ,
    input              [LABEL_WIDTH-1: 0]        new_label                       ,
    input              [LABEL_WIDTH-1: 0]        max_label                       ,
    input                                        equal                           ,
    input              [LABEL_WIDTH-1: 0]        label_1                         ,
    input              [LABEL_WIDTH-1: 0]        label_2                         ,

    input                                        table_rd                        ,
    input              [LABEL_WIDTH-1: 0]        table_radd                      ,
    output reg         [LABEL_WIDTH-1: 0]        table_rdat                      ,

    output reg                                   arr_done                        ,
    output reg         [LABEL_WIDTH-1: 0]        num_label                       
);

localparam                          TABEL_SIZE                  = 2**LABEL_WIDTH;
localparam                          ST_REC_IDLE                 = 3'b001;
localparam                          ST_REC_PROCESS              = 3'b010;
localparam                          ST_REC_DONE                 = 3'b100;

(* ram_style = "registers" *) 
reg                [LABEL_WIDTH-1: 0]        eq_table[TABEL_SIZE:1]             ;
reg                                          table_init_wr                      ;
reg                [LABEL_WIDTH-1: 0]        table_init_wadd                    ;
reg                [LABEL_WIDTH-1: 0]        table_init_wdat                    ;
reg                                          table_eq_wr                        ;
reg                [LABEL_WIDTH-1: 0]        table_eq_wadd                      ;
reg                [LABEL_WIDTH-1: 0]        table_eq_wdat                      ;
reg                                          table_rec_wr                       ;
reg                [LABEL_WIDTH-1: 0]        table_rec_wadd                     ;
reg                [LABEL_WIDTH-1: 0]        table_rec_wdat                     ;
reg                [   2: 0]                 rec_state                          ;
reg                [LABEL_WIDTH-1: 0]        rec_b                              ;
reg                [LABEL_WIDTH-1: 0]        rec_a                              ;
reg                [LABEL_WIDTH-1: 0]        rec_b2                             ;
reg                [LABEL_WIDTH-1: 0]        rec_a1                             ;
reg                                          rec_b_done                         ;
reg                                          rec_a_done                         ;
reg                                          frame_vld_0                        ;
reg                                          arr_1th                            ;
reg                [LABEL_WIDTH-1: 0]        arr_1th_cnt                        ;
reg                                          arr_1th_wr                         ;
reg                [LABEL_WIDTH-1: 0]        arr_1th_wadd                       ;
reg                [LABEL_WIDTH-1: 0]        arr_1th_wdat                       ;
reg                                          arrange_r_0                        ;
reg                                          arrange_r_1                        ;
reg                                          arr_2th_start                      ;
reg                                          arr_2th                            ;
reg                                          arr_2th_0                          ;
reg                [LABEL_WIDTH-1: 0]        arr_2th_cnt                        ;
reg                                          arr_2th_wr                         ;
reg                [LABEL_WIDTH-1: 0]        arr_2th_wadd                       ;
reg                [LABEL_WIDTH-1: 0]        arr_2th_wdat                       ;
reg                [LABEL_WIDTH-1: 0]        arr_2th_n                          ;
reg                [LABEL_WIDTH-1: 0]        arr_2th_m                          ;
reg                                          arr_2th_wr_0                       ;
reg                                          equal_reg                          ;
reg                [LABEL_WIDTH-1: 0]        label_1_reg                        ;
reg                [LABEL_WIDTH-1: 0]        label_2_reg                        ;
reg                                          arrange                            ;
reg                                          arrange_0                          ;
reg                [LABEL_WIDTH-1: 0]        max_label_reg                      ;
reg                [LABEL_WIDTH: 0]          max_label_mul2                     ;

wire                                         arr_2th_done                       ;
wire                                         rec_done                           ;
wire                                         frame_vld_f                        ;
wire                                         arrange_r                          ;
wire                                         eq_tabel_wr                        ;


initial begin
    
end


always @(posedge clk) begin
    if (rst) begin
        table_init_wr <= 'b0;
    end
    else begin
        table_init_wr <= (init & table_sel);
    end
end

always @(posedge clk) begin
    if (rst) begin
        table_init_wadd <= 'd1;
    end
    else if (table_sel && init) begin
        table_init_wadd <= new_label;
    end
end

always @(posedge clk) begin
    if (table_sel && init) begin
        table_init_wdat <= new_label;
    end
end

always @(posedge clk) begin
    if (rst) begin
        equal_reg <= 'b0;
    end
    else begin
        equal_reg <= equal;
    end
end

always @(posedge clk) begin
    if (equal) begin
        label_1_reg <= label_1;
        label_2_reg <= label_2;
    end
end

always @(posedge clk) begin
    if (rst) begin
        table_eq_wr <= 'b0;
    end
    else if (table_sel && equal_reg && ((eq_table[label_2_reg] == label_2_reg) || (eq_table[label_2_reg] == label_1_reg))) begin
        table_eq_wr <= 'b1;
    end
    else begin
        table_eq_wr <= 'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        table_eq_wadd <= 'd1;
    end
    else if (table_sel && equal_reg && ((eq_table[label_2_reg] == label_2_reg) || (eq_table[label_2_reg] == label_1_reg))) begin
        table_eq_wadd <= label_2_reg;
    end
end

always @(posedge clk) begin
    if (table_sel && equal_reg && ((eq_table[label_2_reg] == label_2_reg) || (eq_table[label_2_reg] == label_1_reg))) begin
        table_eq_wdat <= eq_table[label_1_reg];
    end
end

// recursion FSM
always @(posedge clk) begin
    if (rst) begin
        rec_state <= ST_REC_IDLE;
    end
    else begin
        case (rec_state)
            ST_REC_IDLE:        begin
                                    if (table_sel && equal_reg && (eq_table[label_2_reg] != label_2_reg) && (eq_table[label_2_reg] != label_1_reg)) begin
                                        rec_state <= ST_REC_PROCESS;
                                    end
                                end
            ST_REC_PROCESS:     begin
                                    if (rec_done) begin
                                        rec_state <= ST_REC_DONE;
                                    end
                                end
            ST_REC_DONE:        begin
                                    if (table_rec_wr && ~table_eq_wr) begin
                                        rec_state <= ST_REC_IDLE;
                                    end
                                end
            default:            begin
                                    rec_state <= ST_REC_IDLE;
                                end
        endcase
    end
end

always @(posedge clk) begin
    if (rst) begin
        rec_b <= 'd0;
        rec_a <= 'd0;
        rec_b_done <= 'b0;
        rec_a_done <= 'b0;
        table_rec_wadd <= 'd1;
        table_rec_wdat <= 'd0;
        table_rec_wr <= 'b0;
    end
    else begin
        case (rec_state)
            ST_REC_IDLE:        begin
                                    table_rec_wr <= 'b0;

                                    if (table_sel && equal_reg && (eq_table[label_2_reg] != label_2_reg) && (eq_table[label_2_reg] != label_1_reg)) begin
                                        rec_b <= eq_table[label_2_reg];
                                        rec_a <= eq_table[label_1_reg];
                                        table_rec_wadd <= label_2_reg;
                                    end
                                end
            ST_REC_PROCESS:     begin
                                    if (eq_table[rec_b] != rec_b) begin
                                        rec_b <= eq_table[rec_b];
                                    end
                                    else begin
                                        rec_b2 <= rec_b;
                                    end

                                    if (rec_done) begin
                                        rec_b_done <= 'b0;
                                    end
                                    else if (eq_table[rec_b] == rec_b) begin
                                        rec_b_done <= 'b1;
                                    end

                                    if (eq_table[rec_a] != rec_a) begin
                                        rec_a <= eq_table[rec_a];
                                    end
                                    else begin
                                        rec_a1 <= rec_a;
                                        rec_a_done <= 'b1;
                                    end

                                    if (rec_done) begin
                                        rec_a_done <= 'b0;
                                    end
                                    else if (eq_table[rec_a] == rec_a) begin
                                        rec_a_done <= 'b1;
                                    end
                                end
            ST_REC_DONE:        begin
                                    if (table_rec_wr == 'b0) begin
                                        table_rec_wr <= 'b1;
                                    end
                                    else if (table_rec_wr == 'b1) begin
                                        table_rec_wr <= 'b0;
                                    end

                                    if (rec_a1 < rec_b2) begin
                                        table_rec_wdat <= rec_a1;
                                    end
                                    else begin
                                        table_rec_wdat <= rec_b2;
                                    end
                                end
            default:            begin
                                    rec_b <= 'd0;
                                    rec_a <= 'd0;
                                    rec_a_done <= 'b0;
                                    rec_b_done <= 'b0;
                                    table_rec_wadd <= 'd1;
                                    table_rec_wdat <= 'd0;
                                    table_rec_wr <= 'b0;
                                end
        endcase
    end
end

assign rec_done = rec_b_done & rec_a_done;

/****************************************************************step one of arrangement****************************************************************/
always @(posedge clk) begin
    frame_vld_0 <= frame_vld;
end

assign frame_vld_f = ~frame_vld & frame_vld_0;

always @(posedge clk) begin
    if (rst) begin
        max_label_reg <= 'd0;
    end
    else if (frame_vld_f) begin
        max_label_reg <= max_label;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arrange <= 'b0;
    end
    else if (frame_vld_f && table_sel) begin
        arrange <= 'b1;
    end
    else if (arr_done) begin
        arrange <= 'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arrange_0 <= 'b0;
    end
    else begin
        arrange_0 <= arrange;
    end
end

assign arrange_r = arrange & ~arrange_0;

always @(posedge clk) begin
    if (rst) begin
        arr_1th <= 'b0;
    end
    else if (arr_1th_cnt >= max_label_reg) begin
        arr_1th <= 'b0;
    end
    else if (arrange_r) begin
        arr_1th <= 'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_1th_cnt <= 'd1;
    end
    else if (arr_1th_cnt >= max_label_reg) begin
        arr_1th_cnt <= 'd1;
    end
    else if (arr_1th) begin
        arr_1th_cnt <= arr_1th_cnt + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_1th_wr <= 'b0;
    end
    else if (arr_1th && (eq_table[arr_1th_cnt] != arr_1th_cnt)) begin
        arr_1th_wr <= 'b1;
    end
    else begin
        arr_1th_wr <= 'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_1th_wadd <= 'd1;
    end
    else if (arr_1th && (eq_table[arr_1th_cnt] != arr_1th_cnt)) begin
        arr_1th_wadd <= arr_1th_cnt;
    end
end

always @(posedge clk) begin
    if (arr_1th && (eq_table[arr_1th_cnt] != arr_1th_cnt)) begin
        arr_1th_wdat <= eq_table[eq_table[arr_1th_cnt]];
    end
end

/****************************************************************step two of arrangement****************************************************************/
always @(posedge clk) begin
    if (rst) begin
        arrange_r_0 <= 'b0;
        arrange_r_1 <= 'b0;
        arr_2th_start <= 'b0;
    end
    else begin
        arrange_r_0 <= arrange_r;
        arrange_r_1 <= arrange_r_0;
        arr_2th_start <= arrange_r_1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        max_label_mul2 <= 'd0;
    end
    else begin
        max_label_mul2 <= (max_label_reg << 1);
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_2th <= 'b0;
    end
    else if (arr_2th_cnt >= max_label_mul2) begin
        arr_2th <= 'b0;
    end
    else if (arr_2th_start) begin
        arr_2th <= 'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_2th_0 <= 'b0;
    end
    else begin
        arr_2th_0 <= arr_2th;
    end
end

assign arr_2th_done = ~arr_2th & arr_2th_0;

always @(posedge clk) begin
    if (rst) begin
        arr_2th_cnt <= 'd1;
    end
    else if (arr_2th_cnt >= max_label_mul2) begin
        arr_2th_cnt <= 'd1;
    end
    else if (arr_2th) begin
        arr_2th_cnt <= arr_2th_cnt + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_2th_wr <= 'b0;
    end
    else if (~arr_2th_wr && arr_2th) begin
        arr_2th_wr <= 'b1;
    end
    else begin
        arr_2th_wr <= 'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_2th_wadd <= 'd1;
    end
    else if (arr_2th_done) begin
        arr_2th_wadd <= 'd1;
    end
    else if (arr_2th_wr) begin
        arr_2th_wadd <= arr_2th_wadd + 1;
    end
end

always @(posedge clk) begin
    if (eq_table[arr_2th_m] == arr_2th_m) begin
        arr_2th_wdat <= arr_2th_n;
    end
    else begin
        arr_2th_wdat <= eq_table[eq_table[arr_2th_m]];
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_2th_n <= 'd1;
    end
    else if (arr_2th_done) begin
        arr_2th_n <= 'd1;
    end
    else if ((eq_table[arr_2th_wadd] == arr_2th_wadd) && arr_2th_wr) begin
        arr_2th_n <= arr_2th_n + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_2th_m <= 'd1;
    end
    else if (arr_2th_done) begin
        arr_2th_m <= 'd1;
    end
    else if (arr_2th_wr) begin
        arr_2th_m <= arr_2th_m + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        num_label <= 'd0;
    end
    else if (arr_2th_start && (max_label_reg == 'd0)) begin
        num_label <= 'd0;
    end
    else if (arr_2th_done) begin
        num_label <= arr_2th_n - 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        arr_done <= 'b0;
    end
    else if (((arr_2th_start && (arr_2th_cnt >= max_label_reg)) || arr_2th_done)) begin
        arr_done <= 'b1;
    end
    else begin
        arr_done <= 'b0;
    end
end

always @(posedge clk) begin
    if (table_init_wr) begin
        eq_table[table_init_wadd] <= table_init_wdat;
    end
    else if (table_eq_wr) begin
        eq_table[table_eq_wadd] <= table_eq_wdat;
    end
    else if (table_rec_wr) begin
        eq_table[table_rec_wadd] <= table_rec_wdat;
        eq_table[rec_b2] <= table_rec_wdat;
    end
    else if (arr_1th_wr && arr_2th_wr) begin
        eq_table[arr_1th_wadd] <= arr_1th_wdat;
        eq_table[arr_2th_wadd] <= arr_2th_wdat;
    end
    else if (arr_1th_wr) begin
        eq_table[arr_1th_wadd] <= arr_1th_wdat;
    end
    else if (arr_2th_wr) begin
        eq_table[arr_2th_wadd] <= arr_2th_wdat;
    end
end

always @(posedge clk) begin
    if (table_rd) begin
        table_rdat <= eq_table[table_radd];
    end
end


endmodule