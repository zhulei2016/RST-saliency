%----FUNCTION:
% extract statistical color histogram using integral histogram(RGB, HSV, LAB, Opponent color space)

function [colorArr] = sp_find_colorHist_grid(chns, grid_x, grid_y, patch_size)

nPatch = numel(grid_x);
colorArr.RGBHist = zeros(nPatch, chns.nRGBHist);
colorArr.LABHist = zeros(nPatch, chns.nLABHist);
colorArr.HSVHist = zeros(nPatch, chns.nHSVHist);
colorArr.OPPHist = zeros(nPatch, chns.nOPPHist);

inthist_rgb = vl_inthist(uint32(chns.Q_rgb), 'NUMLABELS', chns.nRGBHist);
inthist_lab = vl_inthist(uint32(chns.Q_lab), 'NUMLABELS', chns.nLABHist);
inthist_hsv = vl_inthist(uint32(chns.Q_hsv), 'NUMLABELS', chns.nHSVHist);
inthist_opp = vl_inthist(uint32(chns.Q_opp), 'NUMLABELS', chns.nOPPHist);

x_lo = grid_x; x_hi = grid_x + patch_size - 1;
y_lo = grid_y; y_hi = grid_y + patch_size - 1;
boxes = uint32([y_lo, x_lo, y_hi, x_hi]');

rgbHist = vl_sampleinthist(inthist_rgb, boxes);
rgbHist = double(rgbHist) ./ repmat(max( sum(rgbHist, 1), eps ), chns.nRGBHist, 1);
colorArr.RGBHist = rgbHist';

labHist = vl_sampleinthist(inthist_lab, boxes);
labHist = double(labHist) ./ repmat(max( sum(labHist, 1), eps ), chns.nLABHist, 1);
colorArr.LABHist = labHist';

hsvHist = vl_sampleinthist(inthist_hsv, boxes);
hsvHist = double(hsvHist) ./ repmat(max( sum(hsvHist, 1), eps ), chns.nHSVHist, 1);
colorArr.HSVHist = hsvHist';

oppHist = vl_sampleinthist(inthist_opp, boxes);
oppHist = double(oppHist) ./ repmat(max( sum(oppHist, 1), eps ), chns.nOPPHist, 1);
colorArr.OPPHist = oppHist';

% % for all patches
% for ii = 1:nPatch
%     % find window of pixels that contributes to this descriptor
%     x_lo = grid_x(ii);
%     x_hi = grid_x(ii) + patch_size - 1;
%     y_lo = grid_y(ii);
%     y_hi = grid_y(ii) + patch_size - 1;
%     
%     patch = chns.Q_rgb(y_lo:y_hi,x_lo:x_hi);
%     RGBHist = hist(patch(:), 1:chns.nRGBHist );
%     colorArr.RGBHist(ii, :) = RGBHist / max( sum(RGBHist), eps );
%     
%     patch = chns.Q_lab(y_lo:y_hi,x_lo:x_hi);
%     LABHist = hist(patch(:), 1:chns.nLABHist );
%     colorArr.LABHist(ii, :) = LABHist / max( sum(LABHist), eps );
%     
%     patch = chns.Q_hsv(y_lo:y_hi,x_lo:x_hi);
%     HSVHist = hist(patch(:), 1:chns.nHSVHist );
%     colorArr.HSVHist(ii, :) = HSVHist / max( sum(HSVHist), eps );
%     
%     patch = chns.Q_opp(y_lo:y_hi,x_lo:x_hi);
%     OPPHist = hist(patch(:), 1:chns.nOPPHist );
%     colorArr.OPPHist(ii, :) = OPPHist / max( sum(OPPHist), eps );
% end







