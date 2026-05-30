%% 对图像执行伽马矫正，支持灰度和彩色图像
clc;clear;close all;
%% 导入待去雾图像
[fileName, pathName] = uigetfile({'*.jpg;*.png'}, 'Select image');
img = imread([pathName, fileName]);
%% 调用 gammaCorrection 函数处理
gamma = 0.4;
img_gc = gammaCorrection(img, gamma);
imshow(img_gc);title('结果');
