function [boxes_c, boxes_s] = getSurroundings2(grid_x, grid_y, imh, imw, patch_size, surrWidth)
xc_lo = grid_x; xc_hi = grid_x + patch_size(1) - 1;
yc_lo = grid_y; yc_hi = grid_y + patch_size(2) - 1;
boxes_c = uint32([yc_lo, xc_lo, yc_hi, xc_hi]');

xs_lo = max(1, grid_x - surrWidth + 1); ys_lo = max(1, grid_y - surrWidth + 1);
xs_hi = min(imw, grid_x + patch_size(1) - 1 + surrWidth); ys_hi = min(imh, grid_y + patch_size(2) - 1 + surrWidth);
boxes_s = uint32([ys_lo, xs_lo, ys_hi, xs_hi]');
end

