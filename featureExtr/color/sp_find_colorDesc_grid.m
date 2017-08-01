%----FUNCTION:
% extract statistical color features (mean and standard deviation) from various of color spaces (RGB, HSV, LAB, Opponent color space)
%----INPUT:
% I - the raw RGB image
% gridX - x grid
% gridY - y grid
% patchSize - patch size
%----OUTPUT:
% colorArr - the statistical color features
%----AUTHOR:
% Yang Xiao @ AUTOMATION SCHOOL HUST (Yang_Xiao@hust.edu.cn)
% Created on 2014.10.30
% Last modified on 2014.10.30

function [colorArr] = sp_find_colorDesc_grid(chns, grid_x, grid_y, patch_size)
nPatch = numel(grid_x);
colorArr = zeros(nPatch, 24);

[imh, imw, ~] = size(chns.rgb);
chn_colors = zeros(imh, imw, 12);
chn_colors(:, :, 1:3) = chns.rgb; chn_colors(:, :, 4:6) = chns.hsv;
chn_colors(:, :, 7:9) = chns.lab; chn_colors(:, :, 10:12) = chns.opp;

[avg, var] = calcMeanandVariance(chn_colors, grid_x, grid_y, [patch_size, patch_size], 1);
colorArr(:, 1:2:23) = avg;
colorArr(:, 2:2:24) = sqrt(var);

% % for all patches
% rImg = double(chns.rgb(:, :, 1));    gImg = double(chns.rgb(:, :, 2));    bImg = double(chns.rgb(:, :, 3));
% hImg = double(chns.hsv(:, :, 1));    sImg = double(chns.hsv(:, :, 2));    vImg = double(chns.hsv(:, :, 3));
% lImg = double(chns.lab(:, :, 1));    aImg = double(chns.lab(:, :, 2));    bbImg = double(chns.lab(:, :, 3));
% o1Img = double(chns.opp(:, :, 1));    o2Img = double(chns.opp(:, :, 2));    o3Img = double(chns.opp(:, :, 3));
% for ii = 1:nPatch
%     % find window of pixels that contributes to this descriptor
%     x_lo = grid_x(ii);
%     x_hi = grid_x(ii) + patch_size - 1;
%     y_lo = grid_y(ii);
%     y_hi = grid_y(ii) + patch_size - 1;
%     
%     % RGB feature
%     rPatch = rImg(y_lo:y_hi,x_lo:x_hi);     gPatch = gImg(y_lo:y_hi,x_lo:x_hi);     bPatch = bImg(y_lo:y_hi,x_lo:x_hi);
%     colorArr(ii, 1) = mean(reshape(rPatch,[power(patch_size,2), 1]));   colorArr(ii, 2) = std(reshape(rPatch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 3) = mean(reshape(gPatch,[power(patch_size,2), 1]));   colorArr(ii, 4) = std(reshape(gPatch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 5) = mean(reshape(bPatch,[power(patch_size,2), 1]));   colorArr(ii, 6) = std(reshape(bPatch,[power(patch_size,2), 1]),1);
%     
%     %     rhist = hist(rPatch(:), 256);
%     
%     % HSV feature
%     hPatch = hImg(y_lo:y_hi,x_lo:x_hi);     sPatch = sImg(y_lo:y_hi,x_lo:x_hi);     vPatch = vImg(y_lo:y_hi,x_lo:x_hi);
%     colorArr(ii, 7) = mean(reshape(hPatch,[power(patch_size,2), 1]));   colorArr(ii, 8) = std(reshape(hPatch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 9) = mean(reshape(sPatch,[power(patch_size,2), 1]));   colorArr(ii, 10) = std(reshape(sPatch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 11) = mean(reshape(vPatch,[power(patch_size,2), 1]));   colorArr(ii, 12) = std(reshape(vPatch,[power(patch_size,2), 1]),1);
%     
%     % LAB feature
%     lPatch = lImg(y_lo:y_hi,x_lo:x_hi);     aPatch = aImg(y_lo:y_hi,x_lo:x_hi);     bPatch = bbImg(y_lo:y_hi,x_lo:x_hi);
%     colorArr(ii, 13) = mean(reshape(lPatch,[power(patch_size,2), 1]));   colorArr(ii, 14) = std(reshape(lPatch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 15) = mean(reshape(aPatch,[power(patch_size,2), 1]));   colorArr(ii, 16) = std(reshape(aPatch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 17) = mean(reshape(bPatch,[power(patch_size,2), 1]));   colorArr(ii, 18) = std(reshape(bPatch,[power(patch_size,2), 1]),1);
%     
%     % opponent feature
%     o1Patch = o1Img(y_lo:y_hi,x_lo:x_hi);     o2Patch = o2Img(y_lo:y_hi,x_lo:x_hi);     o3Patch = o3Img(y_lo:y_hi,x_lo:x_hi);
%     colorArr(ii, 19) = mean(reshape(o1Patch,[power(patch_size,2), 1]));   colorArr(ii, 20) = std(reshape(o1Patch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 21) = mean(reshape(o2Patch,[power(patch_size,2), 1]));   colorArr(ii, 22) = std(reshape(o2Patch,[power(patch_size,2), 1]),1);
%     colorArr(ii, 23) = mean(reshape(o3Patch,[power(patch_size,2), 1]));   colorArr(ii, 24) = std(reshape(o3Patch,[power(patch_size,2), 1]),1);
% end


