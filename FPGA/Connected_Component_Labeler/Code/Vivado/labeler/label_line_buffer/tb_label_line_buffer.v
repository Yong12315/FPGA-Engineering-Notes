`timescale 1ns/1ps

module tb_label_line_buffer;

parameter                           LABEL_WIDTH                 = 8     ;
parameter                           DEPTH                       = 'd351 ;

reg                                          clk                                ;
reg                                          rst                                ;
reg                                          first_label_vld                    ;
reg                [LABEL_WIDTH-1: 0]        first_label                        ;
reg                                          buffer_rd                          ;

wire               [LABEL_WIDTH-1: 0]        d1l_label                          ;

reg                [   8: 0]                 cnt                                ;

label_line_buffer #(
    .LABEL_WIDTH                        (LABEL_WIDTH               ),
    .DEPTH                              (DEPTH                     ) 
)U_label_line_buffer (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .first_label_vld                    (first_label_vld           ),
    .first_label                        (first_label               ),
    .buffer_rd                          (buffer_rd                 ),

    .d1l_label                          (d1l_label                 )
);

localparam CLK_PERIOD = 20;
always #(CLK_PERIOD/2) clk=~clk;

always @(posedge clk) begin
    if (rst) begin
        cnt <= 'd0;
    end
    else begin
        cnt <= cnt + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        first_label_vld <= 'b0;
    end
    else if (cnt == 'd10) begin
        first_label_vld <= 'b1;
    end
    else if (cnt == ('d10 + DEPTH)) begin
        first_label_vld <= 'b0;
    end
end

always @(posedge clk) begin
    if (first_label_vld) begin
        first_label <= {$random} % 512;
    end
end
always @(posedge clk) begin
    if (rst) begin
        buffer_rd <= 'b0;
    end
    else if (cnt == 'd5) begin
        buffer_rd <= 'b1;
    end
    else if (cnt == ('d5 + DEPTH)) begin
        buffer_rd <= 'b0;
    end
end

initial begin
    #1 rst<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst<=0;
    #(CLK_PERIOD*3) rst<=1;clk<=0;
    repeat(5) @(posedge clk);
    rst<=0;
    @(posedge clk);
    repeat(2) @(posedge clk);

end

endmodule
