%% 多尺度 Retinex 图像增强算法（MSR）
function outputImage = multiScaleRetinex(image, sigma, weights)
% 原理: R_MSR = Σ w_k × SSR(image, σ_k)
%       对每个尺度 σ_k 做单尺度 Retinex，再按权重加权求和，
%       兼顾小尺度细节和大尺度色彩保真度。
%       最后做全局 min-max 拉伸到 [0, 255]。
% 输入:
%   image    - 输入图像，uint8 类型，支持灰度和彩色 (RGB)
%              通常由 imread 直接读入
%   sigma    - 高斯核标准差向量，控制各尺度的平滑程度
%              例如: [15, 80, 250]
%              若为标量 (如 80)，退化为单尺度 Retinex
%   weights  - (可选) 各尺度的融合权重，默认等权
%              例如: [0.3, 0.3, 0.4]
%              长度必须与 sigma 相同
% 输出:
%   outputImage - 增强后的图像，uint8 类型，单张图像矩阵
% 参数检查
if ~isa(image, 'uint8')
    error('输入图像必须为 uint8 类型，通常由 imread 直接获得。');
end
[height, width, channels] = size(image);
% 确保 sigma 为行向量
sigma = sigma(:)';
numScales = length(sigma);
% 权重处理：未提供则等权
if nargin < 3 || isempty(weights)
    weights = ones(1, numScales) / numScales;
else
    weights = weights(:)' / sum(weights(:));  % 归一化
    if length(weights) ~= numScales
        error('weights 的长度必须与 sigma 相同。');
    end
end
% 转为 double 并归一化到 [0, 1]
imageDouble = im2double(image);
% 初始化 MSR 累加器
msrAccumulator = zeros(height, width, channels);
% 逐尺度、逐通道计算 SSR 并加权累加
for s = 1:numScales
    currentSigma = sigma(s);
    currentWeight = weights(s);
    % 计算高斯核（3-sigma 原则）
    kernelSize = 2 * ceil(3 * currentSigma) + 1;
    kernelSize = min(kernelSize, min(height, width));
    if mod(kernelSize, 2) == 0
        kernelSize = kernelSize + 1;
    end
    gaussianKernel = fspecial('gaussian', kernelSize, currentSigma);
    % 逐通道做 SSR
    for ch = 1:channels
        currentChannel = imageDouble(:, :, ch);
        % log(I)
        logChannel = log(currentChannel + eps);
        % log(I * G)
        illumination = imfilter(currentChannel, gaussianKernel, 'replicate');
        logIllumination = log(illumination + eps);
        % log(R) = log(I) - log(L)
        logReflectance = logChannel - logIllumination;
        % R = exp(log(R))，加权累加
        msrAccumulator(:, :, ch) = msrAccumulator(:, :, ch) + currentWeight * exp(logReflectance);
    end
end
% 后处理：全局 min-max 线性拉伸到 [0, 1]
minVal = min(msrAccumulator(:));
maxVal = max(msrAccumulator(:));
if maxVal > minVal
    msrAccumulator = (msrAccumulator - minVal) / (maxVal - minVal);
else
    msrAccumulator = zeros(height, width, channels);
end
% 转回 uint8 输出
outputImage = uint8(msrAccumulator * 255);
end
