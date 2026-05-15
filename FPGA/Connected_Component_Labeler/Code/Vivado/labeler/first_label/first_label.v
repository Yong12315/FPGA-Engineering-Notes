`timescale 1ns/1ps

module first_label #(
    parameter                           FRONT_PIX                   = 1'b0  ,
    parameter                           LABEL_WIDTH                 = 8     ,
    parameter                           IMG_COLS                    = 'd351 ,
    parameter                           ROW_CNT_WIDTH               = 16    ,
    parameter                           COL_CNT_WIDTH               = 16    
) (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        pix_x_vld                       ,
    input                                        pix_x                           ,
    input                                        pix_d                           ,
    input                                        pix_c                           ,
    input                                        pix_b                           ,
    input                                        pix_a                           ,
    input              [ROW_CNT_WIDTH-1: 0]      row_cnt                         ,
    input              [COL_CNT_WIDTH-1: 0]      col_cnt                         ,
    input              [LABEL_WIDTH-1: 0]        label_d                         ,
    input              [LABEL_WIDTH-1: 0]        label_c                         ,
    input              [LABEL_WIDTH-1: 0]        label_b                         ,
    input              [LABEL_WIDTH-1: 0]        label_a                         ,
    input                                        frame_vld                       ,

    output reg         [LABEL_WIDTH-1: 0]        label_x                         ,
    output reg                                   first_label_vld                 ,
    output reg         [LABEL_WIDTH-1: 0]        first_label                     ,
    output reg                                   init                            ,
    output reg         [LABEL_WIDTH-1: 0]        new_label                       ,
    output reg         [LABEL_WIDTH-1: 0]        max_label='d0                   ,
    output reg                                   equal                           ,
    output reg         [LABEL_WIDTH-1: 0]        label_1                         ,
    output reg         [LABEL_WIDTH-1: 0]        label_2                          
);


localparam                          SCENE_1                     = 5'b00001;
localparam                          SCENE_2                     = 5'b00010;
localparam                          SCENE_3                     = 5'b00100;
localparam                          SCENE_4                     = 5'b01000;
localparam                          SCENE_5                     = 5'b10000;


reg                [   4: 0]                 scene                              ;
//reg                [LABEL_WIDTH-1: 0]        label_x                            ;
reg                                          pix_x_vld_0                        ;
reg                                          pix_x_vld_1                        ;
reg                                          frame_vld_0                        ;

wire                                         frame_vld_f                        ;
wire                                         frame_vld_r                        ;


always @(posedge clk) begin
    if ((row_cnt == 'd0) && (col_cnt == 'd0)) begin
        scene <= SCENE_1;
    end
    else if (row_cnt == 'd0) begin
        scene <= SCENE_2;
    end
    else if (col_cnt == 'd0) begin
        scene <= SCENE_3;
    end
    else if (col_cnt == (IMG_COLS - 1)) begin
        scene <= SCENE_4;
    end
    else begin
        scene <= SCENE_5;
    end
end

always @(posedge clk) begin
    if (rst) begin
        frame_vld_0 <= 'b0;
    end
    else begin
        frame_vld_0 <= frame_vld;
    end
end

assign                              frame_vld_f                 = ~frame_vld & frame_vld_0;
assign                              frame_vld_r                 = frame_vld & ~frame_vld_0;

always @(posedge clk) begin
    if ((pix_x != FRONT_PIX) || ~pix_x_vld) begin
        label_x <= 'd0;
    end
    else begin
        case (scene)
            SCENE_1:        begin
                                label_x <= new_label;
                            end
            SCENE_2:        begin
                                if (label_d == 'd0) begin
                                    label_x <= new_label;
                                end
                                else begin
                                    label_x <= label_d;
                                end
                            end     
            SCENE_3:        begin
                                if (~(pix_b == FRONT_PIX) && ~(pix_c == FRONT_PIX)) begin
                                    label_x <= new_label;
                                end
                                else if (~(pix_b == FRONT_PIX) && (pix_c == FRONT_PIX)) begin
                                    label_x <= label_c;
                                end
                                else if ((pix_b == FRONT_PIX) && ~(pix_c == FRONT_PIX)) begin
                                    label_x <= label_b;
                                end
                                else if ((pix_b == FRONT_PIX) && (pix_c == FRONT_PIX)) begin
                                    label_x <= label_c;
                                end
                            end
            SCENE_4:        begin
                                if (~(pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    label_x <= new_label;
                                end
                                else if (~(pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_d == FRONT_PIX)) begin
                                    label_x <= label_d;
                                end
                                else if (~(pix_a == FRONT_PIX) && (pix_b == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    label_x <= label_b;
                                end
                                else if (~(pix_a == FRONT_PIX) && (pix_b == FRONT_PIX) && (pix_d == FRONT_PIX)) begin
                                    label_x <= label_d;
                                end
                                else if ((pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    label_x <= label_a;
                                end
                                else if ((pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_d == FRONT_PIX)) begin
                                    label_x <= label_d;
                                end
                                else if ((pix_a == FRONT_PIX) && (pix_b == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    label_x <= label_b;
                                end
                                else if ((pix_a == FRONT_PIX) && (pix_b == FRONT_PIX) && (pix_d == FRONT_PIX)) begin
                                    label_x <= label_d;
                                end
                            end
            SCENE_5:        begin
                                case ({(pix_a == FRONT_PIX), (pix_b == FRONT_PIX), (pix_c== FRONT_PIX), (pix_d == FRONT_PIX)})
                                    4'd0:   begin
                                                label_x <= new_label;
                                            end
                                    4'd1:   begin
                                                label_x <= label_d;
                                            end
                                    4'd2:   begin
                                                label_x <= label_c;
                                            end
                                    4'd3:   begin
                                                if (label_c <= label_d) begin
                                                    label_x <= label_c;
                                                end
                                                else begin
                                                    label_x <= label_d;
                                                end
                                            end
                                    4'd4:   begin
                                                label_x <= label_b;
                                            end

                                    4'd5:   begin
                                                label_x <= label_d;
                                            end
                                    4'd6:   begin
                                                label_x <= label_c;
                                            end
                                    4'd7:   begin
                                                if (label_c <= label_d) begin
                                                    label_x <= label_c;
                                                end
                                                else begin
                                                    label_x <= label_d;
                                                end
                                            end
                                    4'd8:   begin
                                                label_x <= label_a;
                                            end
                                    4'd9:   begin
                                                label_x <= label_d;
                                            end
                                    4'd10:  begin
                                                if (label_a <= label_c) begin
                                                    label_x <= label_a;
                                                end
                                                else begin
                                                    label_x <= label_c;
                                                end
                                            end
                                    4'd11:  begin
                                                if (label_c <= label_d) begin
                                                    label_x <= label_c;
                                                end
                                                else begin
                                                    label_x <= label_d;
                                                end
                                            end
                                    4'd12:  begin
                                                label_x <= label_b;
                                            end
                                    4'd13:  begin
                                                label_x <= label_d;
                                            end
                                    4'd14:  begin
                                                label_x <= label_c;
                                            end
                                    4'd15:  begin
                                                if (label_c <= label_d) begin
                                                    label_x <= label_c;
                                                end
                                                else begin
                                                    label_x <= label_d;
                                                end
                                            end
                                endcase
                            end
            default:        begin
                                label_x <= label_x;
                            end
        endcase
    end
end

always @(posedge clk) begin
    if (rst || frame_vld_r) begin
        max_label <= 'd0;
    end
    else if ((pix_x == FRONT_PIX) && pix_x_vld) begin
        case (scene)
            SCENE_1:        begin
                                max_label <= max_label + 1;
                            end 
            SCENE_2:        begin
                                if (label_d == 'd0) begin
                                    max_label <= max_label + 1;
                                end
                            end 
            SCENE_3:        begin
                                if (~(pix_b == FRONT_PIX) && ~(pix_c== FRONT_PIX)) begin
                                    max_label <= max_label + 1;
                                end
                            end 
            SCENE_4:        begin
                                if (~(pix_a== FRONT_PIX) && ~(pix_b == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    max_label <= max_label + 1;
                                end
                            end 
            SCENE_5:        begin
                                if (~(pix_a== FRONT_PIX) && ~(pix_b == FRONT_PIX) && ~(pix_c== FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    max_label <= max_label + 1;
                                end
                            end
        endcase
    end
end

always @(posedge clk) begin
    if (rst || (pix_x != FRONT_PIX) || ~pix_x_vld) begin
        init <= 'd0;
    end
    else begin
        init <= 'b0;

        case (scene)
            SCENE_1:        begin
                                init <= 'b1;
                            end 
            SCENE_2:        begin
                                if (label_d == 'd0) begin
                                    init <= 'b1;
                                end
                            end 
            SCENE_3:        begin
                                if (~(pix_b == FRONT_PIX) && ~(pix_c== FRONT_PIX)) begin
                                    init <= 'b1;
                                end
                            end 
            SCENE_4:        begin
                                if (~(pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    init <= 'b1;
                                end
                            end 
            SCENE_5:        begin
                                if (~(pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && ~(pix_c == FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
                                    init <= 'b1;
                                end
                            end
        endcase
    end
end

always @(posedge clk) begin
    if (rst || (pix_x != FRONT_PIX) || ~pix_x_vld) begin
        equal <= 'b0;
    end
    else if (scene == SCENE_5) begin
        equal <= 'b0;

        if ((pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_c == FRONT_PIX) && (label_c != label_d)) begin
            equal <= 'b1;
        end
        else if (~(pix_a == FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_c == FRONT_PIX) && (pix_d == FRONT_PIX) && (label_c != label_d)) begin
            equal <= 'b1;
        end
    end
    else begin
        equal <= 'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        label_1 <= 'd0;
        label_2 <= 'd0;
    end
    else if (scene == SCENE_5) begin
        if ((pix_a== FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_c== FRONT_PIX) && ~(pix_d == FRONT_PIX)) begin
            if (label_c < label_a) begin
                label_1 <= label_c;
                label_2 <= label_a;
            end
            else begin
                label_1 <= label_a;
                label_2 <= label_c;
            end
        end
        else if ((pix_a== FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_c== FRONT_PIX) && (pix_d == FRONT_PIX)) begin
            if (label_c < label_d) begin
                label_1 <= label_c;
                label_2 <= label_d;
            end
            else begin
                label_1 <= label_d;
                label_2 <= label_c;
            end
        end
        else if (~(pix_a== FRONT_PIX) && ~(pix_b == FRONT_PIX) && (pix_c== FRONT_PIX) && (pix_d == FRONT_PIX)) begin
            if (label_c < label_d) begin
                label_1 <= label_c;
                label_2 <= label_d;
            end
            else begin
                label_1 <= label_d;
                label_2 <= label_c;
            end
        end
    end
end

always @(posedge clk) begin
    new_label <= max_label + 1;
end

/*
always @(posedge clk) begin
    if (frame_vld_f) begin
        first_label_num <= max_label;
    end
end
*/

always @(posedge clk) begin
    if (rst) begin
        pix_x_vld_0 <= 'b0;
        pix_x_vld_1 <= 'b0;
    end
    else begin
        pix_x_vld_0 <= pix_x_vld;
        pix_x_vld_1 <= pix_x_vld_0;
    end
end

always @(*) begin
    first_label_vld = pix_x_vld_1;
end

always @(posedge clk) begin
    first_label <= label_x;
end


endmodule