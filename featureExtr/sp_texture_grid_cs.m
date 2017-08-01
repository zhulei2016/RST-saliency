% extract statistical texture histogram using integral histogram(texture and lbp features)
function [featArr_c, featArr_s] = sp_texture_grid_cs(chns, grid_x, grid_y, patch_size, surrWidth)
[imh, imw, ~] = size(chns.imtext);
% [featArr.texture, ~] = calcMeanandVariance(chns.imtext, grid_x, grid_y, [patch_size, patch_size], 0);
[featArr_c.texture, ~, featArr_s.texture, ~] = ...
    calcMeanandVariance_cs(chns.imtext, grid_x, grid_y, [patch_size, patch_size], surrWidth, 0);

xc_lo = grid_x; xc_hi = grid_x + patch_size - 1;
yc_lo = grid_y; yc_hi = grid_y + patch_size - 1;
boxes_c = uint32([yc_lo, xc_lo, yc_hi, xc_hi]');

xs_lo = max(1, grid_x - surrWidth + 1); ys_lo = max(1, grid_y - surrWidth + 1);
xs_hi = min(imw, grid_x + patch_size - 1 + surrWidth); ys_hi = min(imh, grid_y + patch_size - 1 + surrWidth);
boxes_s = uint32([ys_lo, xs_lo, ys_hi, xs_hi]');

inthist_texture = vl_inthist(uint32(chns.texthist), 'NUMLABELS', chns.ntext);
textureHist_c = vl_sampleinthist(inthist_texture, boxes_c);
textureHist_s = vl_sampleinthist(inthist_texture, boxes_s) - textureHist_c;
textureHist_c = double(textureHist_c) ./ repmat(max( sum(textureHist_c, 1), eps ), chns.ntext, 1);
textureHist_s = double(textureHist_s) ./ repmat(max( sum(textureHist_s, 1), eps ), chns.ntext, 1);
featArr_c.textureHist = textureHist_c;
featArr_s.textureHist = textureHist_s;

inthist_lbp = vl_inthist(uint32(chns.imlbp), 'NUMLABELS', 256);
lbpHist_c = vl_sampleinthist(inthist_lbp, boxes_c);
lbpHist_s = vl_sampleinthist(inthist_lbp, boxes_s) - lbpHist_c;
lbpHist_c = double(lbpHist_c) ./ repmat(max( sum(lbpHist_c, 1), eps ), 256, 1);
lbpHist_s = double(lbpHist_s) ./ repmat(max( sum(lbpHist_s, 1), eps ), 256, 1);
featArr_c.lbpHist = lbpHist_c;
featArr_s.lbpHist = lbpHist_s;

% xc_tl = grid_x;
% yc_tl = grid_y;
% xc_br = grid_x + patch_size - 1;
% yc_br = grid_y + patch_size - 1;
% 
% xs_tl = max(1, grid_x - surrWidth + 1);
% ys_tl = max(1, grid_y - surrWidth + 1);
% xs_br = min(imw, grid_x + patch_size - 1 + surrWidth);
% ys_br = min(imh, grid_y + patch_size - 1 + surrWidth);
% 
% for i = 1 : length(grid_x),
%     [x_cent,y_cent] = meshgrid(xc_tl(i) : xc_br(i), yc_tl(i) : yc_br(i));
%     [x_surr,y_surr] = meshgrid(xs_tl(i) : xs_br(i), ys_tl(i) : ys_br(i));
%     
%     pix_cent = (x_cent - 1) * imh + y_cent; pix_cent = pix_cent(:);
%     pix_surr = (x_surr - 1) * imh + y_surr;
%     pix_surr = setdiff(pix_surr, pix_cent);
% 
%     textureHistcc = hist( chns.texthist(pix_cent), 1:chns.ntext )';
%     textureHistcc = textureHistcc / max( sum(textureHistcc), eps );
%     textureHistss = hist( chns.texthist(pix_surr), 1:chns.ntext )';
%     textureHistss = textureHistss / max( sum(textureHistss), eps );
% end


