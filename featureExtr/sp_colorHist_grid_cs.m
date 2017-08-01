%----FUNCTION:
% extract statistical color histogram using integral histogram(RGB, HSV, LAB, Opponent color space)

function [colorArr_c, colorArr_s] = sp_colorHist_grid_cs(chns, grid_x, grid_y, patch_size, surrWidth)

nPatch = numel(grid_x);
[imh, imw, ~] = size(chns.rgb);
colorArr_c.RGBHist = zeros(nPatch, chns.nRGBHist);
colorArr_c.LABHist = zeros(nPatch, chns.nLABHist);
colorArr_c.HSVHist = zeros(nPatch, chns.nHSVHist);
colorArr_c.OPPHist = zeros(nPatch, chns.nOPPHist);

inthist_rgb = vl_inthist(uint32(chns.Q_rgb), 'NUMLABELS', chns.nRGBHist);
inthist_lab = vl_inthist(uint32(chns.Q_lab), 'NUMLABELS', chns.nLABHist);
inthist_hsv = vl_inthist(uint32(chns.Q_hsv), 'NUMLABELS', chns.nHSVHist);
inthist_opp = vl_inthist(uint32(chns.Q_opp), 'NUMLABELS', chns.nOPPHist);

xc_lo = grid_x; xc_hi = grid_x + patch_size - 1;
yc_lo = grid_y; yc_hi = grid_y + patch_size - 1;
boxes_c = uint32([yc_lo, xc_lo, yc_hi, xc_hi]');

xs_lo = max(1, grid_x - surrWidth + 1); ys_lo = max(1, grid_y - surrWidth + 1);
xs_hi = min(imw, grid_x + patch_size - 1 + surrWidth); ys_hi = min(imh, grid_y + patch_size - 1 + surrWidth);
boxes_s = uint32([ys_lo, xs_lo, ys_hi, xs_hi]');

rgbHist_c = vl_sampleinthist(inthist_rgb, boxes_c);
rgbHist_s = vl_sampleinthist(inthist_rgb, boxes_s) - rgbHist_c;
rgbHist_c = double(rgbHist_c) ./ repmat(max( sum(rgbHist_c, 1), eps ), chns.nRGBHist, 1);
rgbHist_s = double(rgbHist_s) ./ repmat(max( sum(rgbHist_s, 1), eps ), chns.nRGBHist, 1);
colorArr_c.RGBHist = rgbHist_c;
colorArr_s.RGBHist = rgbHist_s;

labHist_c = vl_sampleinthist(inthist_lab, boxes_c);
labHist_s = vl_sampleinthist(inthist_lab, boxes_s) - labHist_c;
labHist_c = double(labHist_c) ./ repmat(max( sum(labHist_c, 1), eps ), chns.nLABHist, 1);
labHist_s = double(labHist_s) ./ repmat(max( sum(labHist_s, 1), eps ), chns.nLABHist, 1);
colorArr_c.LABHist = labHist_c;
colorArr_s.LABHist = labHist_s;

hsvHist_c = vl_sampleinthist(inthist_hsv, boxes_c);
hsvHist_s = vl_sampleinthist(inthist_hsv, boxes_s) - hsvHist_c;
hsvHist_c = double(hsvHist_c) ./ repmat(max( sum(hsvHist_c, 1), eps ), chns.nHSVHist, 1);
hsvHist_s = double(hsvHist_s) ./ repmat(max( sum(hsvHist_s, 1), eps ), chns.nHSVHist, 1);
colorArr_c.HSVHist = hsvHist_c;
colorArr_s.HSVHist = hsvHist_s;

oppHist_c = vl_sampleinthist(inthist_opp, boxes_c);
oppHist_s = vl_sampleinthist(inthist_opp, boxes_s) - oppHist_c;
oppHist_c = double(oppHist_c) ./ repmat(max( sum(oppHist_c, 1), eps ), chns.nOPPHist, 1);
oppHist_s = double(oppHist_s) ./ repmat(max( sum(oppHist_s, 1), eps ), chns.nOPPHist, 1);
colorArr_c.OPPHist = oppHist_c;
colorArr_s.OPPHist = oppHist_s;

% xc_tl = grid_x;
% yc_tl = grid_y;
% xc_br = grid_x + patch_size - 1;
% yc_br = grid_y + patch_size - 1;
% 
% xs_tl = max(1, grid_x - surrWidth + 1);
% ys_tl = max(1, grid_y - surrWidth + 1);
% xs_br = min(imw, grid_x + patch_size - 1 + surrWidth);
% ys_br = min(imh, grid_y + patch_size - 1 + surrWidth);

% for i = 1 : length(grid_x),
%     [x_cent,y_cent] = meshgrid(xc_tl(i) : xc_br(i), yc_tl(i) : yc_br(i));
%     [x_surr,y_surr] = meshgrid(xs_tl(i) : xs_br(i), ys_tl(i) : ys_br(i));
%     
%     pix_cent = (x_cent - 1) * imh + y_cent;
%     pix_surr = (x_surr - 1) * imh + y_surr;
%     pix_surr = setdiff(pix_surr, pix_cent);
%     
%     LABHist = hist( chns.Q_lab(pix_surr), 1:chns.nLABHist )';
%     LABHist = LABHist / max( sum(LABHist), eps );
% end







