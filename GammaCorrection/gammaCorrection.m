%% 对图像执行伽马矫正，支持灰度和彩色图像
function outputImages = gammaCorrection(image, gamma)
% 输入:
%   image    - 输入图像，灰度(uint8)或彩色(uint8 RGB)，通常由 imread 读入
%   gamma    - 伽马值，标量或向量，例如: 0.5, 2.2, [0.5, 1, 1.5, 2, 2.5]
%              伽马值小于1会使图像变亮，大于1会使图像变暗
% 输出:
%   outputImages - 矫正后的图像。若 gamma 为标量，返回一张图像；
%                  若 gamma 为向量，返回 cell 数组，每个 cell 对应一个 gamma 值的矫正结果。
%                  输入输出均为 uint8 类型。
% 参数检查
if ~isa(image, 'uint8')
    error('输入图像必须为 uint8 类型，通常由 imread 直接获得。');
end
% 如果需要处理多个 gamma 值，递归/循环处理每个值，结果存入 cell
if numel(gamma) > 1
    outputImages = cell(1, numel(gamma));
    for idx = 1:numel(gamma)
        outputImages{idx} = gammaCorrection(image, gamma(idx)); % 递归调用
    end
    return;
end
% 将图像转换为 double 类型，归一化到 [0, 1]
imageDouble = double(image) / 255.0;
% 执行伽马变换
correctedDouble = imageDouble .^ gamma;
% 缩放到 [0, 255] 并转换回 uint8
outputImages = uint8(correctedDouble * 255);
end
