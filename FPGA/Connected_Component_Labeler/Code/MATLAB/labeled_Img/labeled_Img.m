% 读取连通域标记矩阵（假设 txt 以空格或制表符分隔）
label_img = readmatrix('labeled_Img.txt');   % 行×列，元素值 0,1,2,...

%生成颜色映射
num_label = max(label_img(:));               % 最大连通域编号
bg_color  = [0 0 0];                         % 背景黑
% 为 1:num_label 生成可区分的色条，这里用 HSV 色环，再打乱避免相邻颜色太近
hue       = linspace(0,1,num_label+1).';     % +1 是为了不含背景
cmap_lbl  = hsv(num_label);                  % size = num_label × 3
cmap_lbl  = cmap_lbl(randperm(num_label),:); % 打乱顺序
cmap      = [bg_color; cmap_lbl];            % 0→黑，其余映射到 cmap_lbl

% 显示
figure;
imagesc(label_img);
axis image off;
colormap(cmap);
caxis([0 num_label]);            % 固定映射范围
title('连通域着色显示');
colorbar('Ticks',0:num_label);   % 可选：显示色标
