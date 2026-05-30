%% 对图像执行多尺度 Retinex 图像增强，支持灰度和彩色图像
clc;clear;close all;
%% 导入待去雾图像
[fileName, pathName] = uigetfile({'*.jpg;*.png'}, 'Select image');
img = imread([pathName, fileName]);
%% 调用 multiScaleRetinex 函数处理
sigma = [15, 80, 250];
img_msr = multiScaleRetinex(img, sigma);
imshow(img_msr);title('结果');
