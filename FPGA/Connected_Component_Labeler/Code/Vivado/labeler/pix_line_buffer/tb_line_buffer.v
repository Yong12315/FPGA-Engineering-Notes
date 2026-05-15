`timescale 1ns/1ps

module tb_line_buffer;
//==================== Image buffer ===============
// 修改 ROWS/COLS 以匹配图像大小
localparam integer ROWS = 240;
localparam integer COLS = 351;


reg                                          clk                                ;
reg                                          rst                                ;
reg                                          line_vld                           ;
reg                                          bin_dat                            ;

reg                                          bin_mem[0:ROWS*COLS-1]             ;

line_buffer #(
    .DEPTH                              (351                       ) 
) U_line_buffer (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .line_vld                           (line_vld                  ),
    .bin_dat                            (bin_dat                   ),

    .d1l_dat                            (d1l_dat                   ) 
);

localparam CLK_PERIOD = 50;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $readmemb("binaryImg.txt", bin_mem);                                // 只含 0/1 的文本文件
end

integer r, c;
initial begin
    #1 rst<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst<=0;
    #(CLK_PERIOD*3) rst<=1;clk<=0;
    repeat(5) @(posedge clk);
    rst<=0;
    line_vld = 0;
    @(posedge clk);
    repeat(2) @(posedge clk);
    #1
    // 送整幅图
    for (r = 0; r < ROWS; r = r + 1) begin
        line_vld = 1;

        for (c = 0; c < COLS; c = c + 1) begin
            bin_dat = bin_mem[r*COLS + c];
            #(CLK_PERIOD);
        end

        
        line_vld = 0;                                                     // 行结束
        #(CLK_PERIOD);                               // 行间一个空拍
    end

    // 观察若干拍后结束
    repeat (1000) @(posedge clk);
end

endmodule
