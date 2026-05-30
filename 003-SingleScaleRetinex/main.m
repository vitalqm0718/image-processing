%% 对图像执行单尺度 Retinex 图像增强，支持灰度和彩色图像
clc;clear;close all;
%% 导入待去雾图像
[fileName, pathName] = uigetfile({'*.jpg;*.png'}, 'Select image');
img = imread([pathName, fileName]);
%% 调用 freeScaleRetinex 函数处理
sigma = 100;
img_ssr = singleScaleRetinex(img, sigma);
imshow(img_ssr);title('结果');
