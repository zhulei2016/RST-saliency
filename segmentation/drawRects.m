function [ dest ] = drawRects( src, rectsnd, c )
%简介：
%将图像画上有颜色的框图，如果输入是灰度图，先转换为彩色图像，再画框图
%----------------------------------------------------------------------
[rim, cim, z] = size(src);

%如果是单通道的灰度图，转成3通道的图像
if 1==z, dest(:, : ,1) = src; dest(:, : ,2) = src; dest(:, : ,3) = src; else dest = src; end
[rn, pp] = size(rectsnd);
if pp == 3,
    rects = zeros(rn, 4);
    rects(:, 3 : 4) = rectsnd(:, 2 : 3);
    rects(:, 1 : 2) = ind2sub2([rim, cim],rectsnd(:, 1));
end
%开始画框图
for i = 1 : rn,
    y = rects(i, 1); x = rects(i, 2); w = rects(i, 3); h = rects(i, 4);
    x1 = x + w - 1; y1 = y + h -1;
    topl = ((x : x1) - 1) * rim + repmat(y, 1, w);
    leftl = repmat((x - 1) * rim, 1, w) + (y : y1);
    right = repmat((x1 - 1) * rim, 1, w) + (y : y1);
    botml = ((x : x1) - 1) * rim + repmat(y1, 1, w);
    anno = [topl, leftl, right, botml];
    dest(anno) = c(1); dest(anno + rim * cim) = c(2); 
    dest(anno + 2 * rim * cim) = c(3);
end
