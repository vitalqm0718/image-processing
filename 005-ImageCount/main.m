%% MATLAB 图像处理之图像内物体计数仿真
clc; clear; close all;
%% 图 1：原始图像
image = imread('img.jpg');  % 读取输入图像
figure;
imshow(image);
title('Original Image');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig1.jpg', '-djpeg', '-r600');
%% 图 2：灰度图像
grayImage = rgb2gray(image);  % 彩色转灰度
figure;
imshow(grayImage);
title('Grayscale Image');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig2.jpg', '-djpeg', '-r600');
%% 图 3：中值滤波后图像
filteredImage = medfilt2(grayImage, [3 3]);  % 3x3 中值滤波去噪
figure;
imshow(filteredImage);
title('Filtered Image (Median 3x3)');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig3.jpg', '-djpeg', '-r600');
%% 图 4：二值图像
threshold = graythresh(filteredImage);  % Otsu 阈值
binaryImage = imbinarize(filteredImage, threshold);
figure;
imshow(binaryImage);
title('Binary Image (Otsu)');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig4.jpg', '-djpeg', '-r600');
%% 图 5：腐蚀后图像
se = strel('disk', 50);  % 圆形结构元素，半径 50
erodedImage = imerode(binaryImage, se);
figure;
imshow(erodedImage);
title('Eroded Image');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig5.jpg', '-djpeg', '-r600');
%% 图 6：膨胀后图像
se1 = strel('diamond', 5);  % 菱形结构元素，5x5
dilatedImage = imdilate(erodedImage, se1);
figure;
imshow(dilatedImage);
title('Dilated Image');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig6.jpg', '-djpeg', '-r600');
%% 图 7：最终结果（边界框与计数）
[labeledImage, numObjects] = bwlabel(dilatedImage);
boundingBoxes = regionprops(labeledImage, 'BoundingBox');
centroids = regionprops(labeledImage, 'Centroid');
figure;
imshow(image);
hold on;
for i = 1:numObjects
    rectangle('Position', boundingBoxes(i).BoundingBox, ...
        'EdgeColor', 'b', 'LineWidth', 2);
    text(centroids(i).Centroid(1), centroids(i).Centroid(2), ...
        num2str(i), 'Color', 'b', 'FontSize', 15, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end
hold off;
title(['Object Count: ', num2str(numObjects)]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10); set(gca, 'LineWidth', 1);
set(gcf, 'Renderer', 'OpenGL');
print(gcf, 'fig7.jpg', '-djpeg', '-r600');
