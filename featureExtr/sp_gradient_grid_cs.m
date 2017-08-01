%----FUNCTION:
% extract statistical color features (mean and standard deviation) from various of color spaces (RGB, HSV, LAB, Opponent color space)

function [gradArr_c, gradArr_s] = sp_gradient_grid_cs(chns, grid_x, grid_y, patch_size, surrWidth)
nPatch = numel(grid_x); nDims = size(chns.dog, 3) + size(chns.gabor, 3);
chn_grad = cat(chns.dog, chns.gabor, 3);

[gradArr_c, ~, gradArr_s, ~] = calcMeanandVariance_cs(chn_grad, grid_x, grid_y, [patch_size, patch_size], surrWidth, 0);
