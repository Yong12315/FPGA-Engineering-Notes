% 读入测试图
img = imread('Binary_Test_Image.png');     % ← 替换为你的文件名

if size(img,3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

binaryImg = gray > 128;

% 导出为 TXT（空格分隔，按行写出 0/1）
writematrix(uint8(binaryImg), 'binaryImg.txt', 'Delimiter', ' ');

