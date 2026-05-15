`timescale 1ns/1ps

module eq_ctrl (
    input                                        clk                             ,
    input                                        rst                             ,

    input                                        frame_vld                       ,

    output reg                                   table_1_sel                     ,
    output reg                                   table_2_sel                      
);


reg                                          frame_vld_0                        ;
reg                                          ping_pong                          ;
reg                                          ping_pong_0                        ;

wire                                         frame_vld_r                        ;
wire                                         frame_vld_f                        ;
wire                                         ping_pong_r                        ;
wire                                         ping_pong_f                        ;


always @(posedge clk) begin
    if (rst) begin
        frame_vld_0 <= 'b0;
    end
    else begin
        frame_vld_0 <= frame_vld;
    end
end

assign frame_vld_r = frame_vld & ~frame_vld_0;
assign frame_vld_f = ~frame_vld & frame_vld_0;

always @(posedge clk) begin
    if (rst) begin
        ping_pong <= 'b0;
    end
    else if (frame_vld_r) begin
        ping_pong <= ~ping_pong;
    end
end

always @(posedge clk) begin
    if (rst) begin
        ping_pong_0 <= 'b0;
    end
    else begin
        ping_pong_0 <= ping_pong;
    end
end

assign ping_pong_r = ping_pong & ~ping_pong_0;
assign ping_pong_f = ~ping_pong & ping_pong_0;

always @(posedge clk) begin
    if (rst) begin
        table_1_sel <= 'b0;
    end
    else if (ping_pong_r) begin
        table_1_sel <= 'b1;
    end
    else if (frame_vld_f) begin
        table_1_sel <= 'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        table_2_sel <= 'b0;
    end
    else if (ping_pong_f) begin
        table_2_sel <= 'b1;
    end
    else if (frame_vld_f) begin
        table_2_sel <= 'b0;
    end
end


endmodule