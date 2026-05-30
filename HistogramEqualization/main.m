%% 对图像执行直方图均衡化，支持灰度和彩色图像
clc;clear;close all;
%% 导入待去雾图像
[fileName, pathName] = uigetfile({'*.jpg;*.png'}, 'Select image');
img = imread([pathName, fileName]);
%% 调用 histogramEqualization 函数处理
img_eq = histogramEqualization(img, 256);
%% 绘图
figure;
subplot(2,2,1);imshow(img);title('原图');
subplot(2,2,3);imhist(img);title('原图直方图');
subplot(2,2,2);imshow(img_eq);title('结果');
subplot(2,2,4);imhist(img_eq);title('结果直方图');
