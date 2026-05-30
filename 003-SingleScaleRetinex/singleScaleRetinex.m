%% 单尺度 Retinex 图像增强算法（SSR）
function outputImages = singleScaleRetinex(image, sigma)
% 原理: log(R) = log(I) - log(L)
%       其中 I 为原始图像，L 为高斯模糊估计的光照分量，R 为反射分量
%       最后对 R 做全局 min-max 拉伸，恢复视觉效果
% 输入:
%   image    - 输入图像，uint8 类型，支持灰度和彩色 (RGB)
%              通常由 imread 直接读入
%   sigma    - 高斯核标准差，控制光照估计的平滑程度
%              标量或向量，例如: 15, 80, [15, 80, 150, 250]
%              小 sigma 保留更多细节，大 sigma 光照更均匀
% 输出:
%   outputImages - 增强后的图像，uint8 类型
%                  若 sigma 为标量，返回一张图像矩阵
%                  若 sigma 为向量，返回 cell 数组，每个 cell 对应一个 sigma 的结果
% 参数检查
if ~isa(image, 'uint8')
    error('输入图像必须为 uint8 类型，通常由 imread 直接获得。');
end
[height, width, channels] = size(image);
% 多 sigma 处理：各自独立计算，结果存入 cell
if numel(sigma) > 1
    outputImages = cell(1, numel(sigma));
    for idx = 1:numel(sigma)
        outputImages{idx} = singleScaleRetinex(image, sigma(idx));
    end
    return;
end
% 单个 sigma 的核心算法
% 转为 double 并归一化到 [0, 1]，防止计算溢出
imageDouble = im2double(image);
% 初始化输出
retinexResult = zeros(height, width, channels);
% 计算高斯核
% 核大小由 sigma 决定：覆盖 99.7% 的高斯分布区域 (3-sigma 原则)
kernelSize = 2 * ceil(3 * sigma) + 1;
% 确保核大小为奇数且不超过图像尺寸
kernelSize = min(kernelSize, min(height, width));
if mod(kernelSize, 2) == 0
    kernelSize = kernelSize + 1;
end
gaussianKernel = fspecial('gaussian', kernelSize, sigma);
% 逐通道处理（灰度图仅循环一次）
for ch = 1:channels
    currentChannel = imageDouble(:, :, ch);
    % 步骤 A: 对原始通道取对数
    logChannel = log(currentChannel + eps);
    % 步骤 B: 用高斯滤波估计光照分量，再取对数
    illumination = imfilter(currentChannel, gaussianKernel, 'replicate');
    logIllumination = log(illumination + eps);
    % 步骤 C: 对数域的 Retinex 计算
    logRetinex = logChannel - logIllumination;
    % 步骤 D: 转回线性域
    retinexResult(:, :, ch) = exp(logRetinex);
end
% 后处理：全局 min-max 线性拉伸到 [0, 1]
minVal = min(retinexResult(:));
maxVal = max(retinexResult(:));
if maxVal > minVal
    retinexResult = (retinexResult - minVal) / (maxVal - minVal);
else
    % 常数图像，不做拉伸
    retinexResult = zeros(height, width, channels);
end
% 转回 uint8 输出
outputImages = uint8(retinexResult * 255);
end
