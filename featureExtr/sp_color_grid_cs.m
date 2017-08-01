%----FUNCTION:
% extract statistical color features (mean and standard deviation) from various of color spaces (RGB, HSV, LAB, Opponent color space)

function [colorArr_c, colorArr_s] = sp_color_grid_cs(chns, grid_x, grid_y, patch_size, surrWidth)
nPatch = numel(grid_x);
colorArr_c = zeros(nPatch, 24);
colorArr_s = zeros(nPatch, 24);

[imh, imw, ~] = size(chns.rgb);
imc = 12; chn_colors = zeros(imh, imw, imc);
chn_colors(:, :, 1:3) = chns.rgb; chn_colors(:, :, 4:6) = chns.hsv;
chn_colors(:, :, 7:9) = chns.lab; chn_colors(:, :, 10:12) = chns.opp;
[avg_c, var_c, avg_s, var_s] = calcMeanandVariance_cs(chn_colors, grid_x, grid_y, [patch_size, patch_size], surrWidth, 1);

colorArr_c(:, 1:2:23) = avg_c;
colorArr_c(:, 2:2:24) = abs(sqrt(var_c));
% colorArr_c(:, 2:2:24) = var_c > eps ? sqrt(var_c) : 0;
colorArr_s(:, 1:2:23) = avg_s;
colorArr_s(:, 2:2:24) = abs(sqrt(var_s));