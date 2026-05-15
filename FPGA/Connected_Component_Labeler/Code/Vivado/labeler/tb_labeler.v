`timescale 1ns/1ps

module tb_labeler;

//==================== Image buffer ===============
// 修改 ROWS/COLS 以匹配图像大小
localparam                          ROWS                        = 361   ;
localparam                          COLS                        = 478   ;
localparam                          FRONT_PIX                   = 1'b1  ;
localparam                          LABEL_WIDTH                 = 8     ;

localparam                          IMG_SRC_PATH                = "E:/prj/labeler/MATLAB/bin_2_txt/binaryImg.txt";
localparam                          IMG_DST_PATH                = "E:/prj/labeler/MATLAB/labeled_Img/labeled_Img.txt";

reg                                          clk                                ;
reg                                          rst                                ;
reg                                          frame_vld                          ;
reg                                          line_vld                           ;
reg                                          bin_dat                            ;

wire                                         final_label_vld                    ;
wire               [LABEL_WIDTH-1: 0]        final_label                        ;
wire                                         num_label_vld                      ;
wire               [LABEL_WIDTH-1: 0]        num_label                          ;

reg                                          bin_mem_1[0:ROWS*COLS-1]           ;
reg                                          bin_mem_2[0:ROWS*COLS-1]           ;
reg                                          bin_mem_3[0:ROWS*COLS-1]           ;
reg                                          bin_mem_4[0:ROWS*COLS-1]           ;
reg                                          bin_mem_7[0:ROWS*COLS-1]           ;
reg                                          bin_mem_9[0:ROWS*COLS-1]           ;

reg                                          last_frame_flag                    ;

labeler #(
    .FRONT_PIX                          (FRONT_PIX                 ),
    .IMG_ROWS                           (ROWS                      ),
    .IMG_COLS                           (COLS                      ),
    .LABEL_WIDTH                        (LABEL_WIDTH               ) 
) U_labeler (
    .clk                                (clk                       ),
    .rst                                (rst                       ),
    .frame_vld                          (frame_vld                 ),
    .line_vld                           (line_vld                  ),
    .bin_dat                            (bin_dat                   ),

    .final_label_vld                    (final_label_vld           ),
    .final_label                        (final_label               ),
    .num_label                          (num_label                 ),
    .num_label_vld                      (num_label_vld             ) 
);


localparam CLK_PERIOD = 25.0;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    //$readmemb("binaryImg_1.txt", bin_mem_1);
    //$readmemb("binaryImg_2.txt", bin_mem_2);
    //$readmemb("binaryImg_3.txt", bin_mem_3);
    //$readmemb("binaryImg_4.txt", bin_mem_4);
    //$readmemb("binaryImg_9.txt", bin_mem_9);
    $readmemb(IMG_SRC_PATH, bin_mem_7);
end

//---------------------------------------------------------------------
//  (2)  打开 TXT 文件
//---------------------------------------------------------------------
integer fp_out;
initial begin
    fp_out = $fopen(IMG_DST_PATH, "w");   // 追加用 "a"
    if(fp_out == 0) begin
        $display("###  无法创建输出文件 !");
        $finish;
    end
end


integer r, c;
initial begin
    #1 rst<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst<=0;
    #(CLK_PERIOD*3) rst<=1;clk<=0;
    repeat(5) @(posedge clk);
    rst<=0;
    line_vld = 0;
    bin_dat = 0;
    frame_vld = 'b0;
    last_frame_flag = 'b0;

    ///**********************************************************************************************/
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_2[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)

    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = 'b1;
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_2[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_1[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_2[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_3[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_4[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_1[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_2[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_3[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    ///**********************************************************************************************/
    //@(posedge clk);
    //#(CLK_PERIOD*3)
    //frame_vld = 'b1;
    //#(CLK_PERIOD*3)
    //@(posedge clk);
    //repeat(2) @(posedge clk);
    //#1
    //
    //// 送整幅图
    //for (r = 0; r < ROWS; r = r + 1) begin
    //    line_vld = 1;
//
    //    for (c = 0; c < COLS; c = c + 1) begin
    //        bin_dat = bin_mem_4[r*COLS + c];
    //        #(CLK_PERIOD);
    //    end
//
    //    
    //    line_vld = 0;                                                     // 行结束
    //    #(10*CLK_PERIOD);                    
    //end
//
    //#(CLK_PERIOD*3)
    //frame_vld = 'b0;
    //#(CLK_PERIOD*50)
//
    /**********************************************************************************************/
    @(posedge clk);
    #(CLK_PERIOD*3)
    frame_vld = 'b1;
    #(CLK_PERIOD*3)
    @(posedge clk);
    repeat(2) @(posedge clk);
    #1
    
    // 送整幅图
    for (r = 0; r < ROWS; r = r + 1) begin
        line_vld = 1;

        for (c = 0; c < COLS; c = c + 1) begin
            bin_dat = bin_mem_7[r*COLS + c];
            #(CLK_PERIOD);
        end

        
        line_vld = 0;                                                     // 行结束
        #(10*CLK_PERIOD);                    
    end

    #(CLK_PERIOD*3)
    frame_vld = 'b0;
    last_frame_flag = 'b1;
    #(CLK_PERIOD*50)

    // 观察若干拍
    repeat (1000000) @(posedge clk);

    $finish(2);

end

// 
integer row_cnt, col_cnt;

always @(posedge clk) begin
    if (rst) begin
        row_cnt <= 0; col_cnt <= 0;
    end
    else if (last_frame_flag) begin
        if (final_label_vld) begin
            // 写文件：列之间写空格，行末写换行
            if (col_cnt == COLS-1)
                $fwrite(fp_out, "%0d\n" , final_label);
            else
                $fwrite(fp_out, "%0d "  , final_label);

            // 列计数递增
            col_cnt <= (col_cnt == COLS-1) ? 0 : col_cnt + 1;

            // 行计数在列回到 0 时递增
            if (col_cnt == COLS-1)
                row_cnt <= row_cnt + 1;
        end
    end
end


endmodule

