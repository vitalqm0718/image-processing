%% 对图像执行直方图均衡化，支持灰度和彩色图像
function outputImages = histogramEqualization(image, levels)
% 输入:
%   image    - 输入图像，灰度(uint8)或彩色(uint8 RGB)，通常由 imread 读入
%   levels   - 目标灰度级数，可以为标量或向量
%              例如: 256, 或 [32, 64, 128, 256, 512]
% 输出:
%   outputImages - 均衡化后的图像。若 levels 为标量，返回一张图像
%                  若 levels 为向量，返回 cell 数组，每个 cell 对应一个 level 的均衡结果
%                  当 levels <= 256 时输出为 uint8 类型
%                  当 levels > 256 时输出为 uint16 类型（以支持更多灰度级）
% 参数检查与尺寸获取
[height, width, channels] = size(image);
if ~isa(image, 'uint8')
    error('输入图像必须为 uint8 类型，通常由 imread 直接获得。');
end
% 如果需要处理多个 levels，递归/循环处理每个 level，结果存入 cell
if numel(levels) > 1
    outputImages = cell(1, numel(levels));
    for idx = 1:numel(levels)
        outputImages{idx} = histogramEqualization(image, levels(idx)); % 递归调用自身
    end
    return;  % 递归调用结束后返回
end
% 单个 levels 的处理
numBins = 256; % 输入图像始终有 256 个可能的灰度值 (uint8)
% 分通道处理
if channels == 1
    outputImages = equalizeChannel(image, levels, numBins, height, width);
elseif channels == 3
    R = image(:,:,1);
    G = image(:,:,2);
    B = image(:,:,3);
    R_eq = equalizeChannel(R, levels, numBins, height, width);
    G_eq = equalizeChannel(G, levels, numBins, height, width);
    B_eq = equalizeChannel(B, levels, numBins, height, width);
    outputImages = cat(3, R_eq, G_eq, B_eq);
else
    error('不支持的图像通道数：%d', channels);
end
end
%% 单通道均衡处理
function eqChannel = equalizeChannel(channel, levels, numBins, height, width)
    % 计算直方图 (每个灰度级的像素个数)
    pixelCounts = zeros(1, numBins);
    for i = 1:height
        for j = 1:width
            val = channel(i,j);
            pixelCounts(val + 1) = pixelCounts(val + 1) + 1;  % uint8 值 +1 转为 MATLAB 索引
        end
    end
    % 计算概率
    totalPixels = height * width;
    probabilities = pixelCounts / totalPixels;
    % 累积分布函数 (CDF)
    cdf = cumsum(probabilities);
    % 映射表：将原始灰度值映射到 [0, levels-1]，并四舍五入
    map = (levels - 1) * cdf;
    map = round(map);  % 等价于 +0.5 后取整，但更清晰
    % 生成均衡化通道
    eqChannel = zeros(height, width, 'like', channel); % 保持相同数据类型，稍后转换
    if levels <= 256
        % 输出 uint8：映射值在 0~255 内，直接转换
        for i = 1:height
            for j = 1:width
                eqChannel(i,j) = uint8(map(channel(i,j) + 1));
            end
        end
    else
        % 输出 uint16：映射值可能达 levels-1 (如 511)
        eqChannel = zeros(height, width, 'uint16');
        for i = 1:height
            for j = 1:width
                eqChannel(i,j) = uint16(map(channel(i,j) + 1));
            end
        end
    end
end
