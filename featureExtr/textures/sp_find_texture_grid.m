% extract statistical texture histogram using integral histogram(texture and lbp features)
function [featArr] = sp_find_texture_grid(chns, grid_x, grid_y, patch_size)

[featArr.texture, ~] = calcMeanandVariance(chns.imtext, grid_x, grid_y, [patch_size, patch_size], 0);

x_lo = grid_x; x_hi = grid_x + patch_size - 1;
y_lo = grid_y; y_hi = grid_y + patch_size - 1;
boxes = uint32([y_lo, x_lo, y_hi, x_hi]');

inthist_texture = vl_inthist(uint32(chns.texthist), 'NUMLABELS', chns.ntext);
textureHist = vl_sampleinthist(inthist_texture, boxes);
textureHist = double(textureHist) ./ repmat(max( sum(textureHist, 1), eps ), chns.ntext, 1);
featArr.textureHist = textureHist';

inthist_lbp = vl_inthist(uint32(chns.imlbp), 'NUMLABELS', 256);
lbpHist = vl_sampleinthist(inthist_lbp, boxes);
lbpHist = double(lbpHist) ./ repmat(max( sum(lbpHist, 1), eps ), 256, 1);
featArr.lbpHist = lbpHist';

% nPatch = numel(grid_x);
% 
% featArr.texture = zeros(nPatch, chns.ntext);
% featArr.textureHist = zeros(nPatch, chns.ntext);
% featArr.lbpHist = zeros(nPatch, chns.nlbp);
% imh = chns.imh;
% imw = chns.imw;
% 
% % for all patches
% for ii = 1:nPatch
%     % find window of pixels that contributes to this descriptor
%     x_lo = grid_x(ii);
%     x_hi = grid_x(ii) + patch_size - 1;
%     y_lo = grid_y(ii);
%     y_hi = grid_y(ii) + patch_size - 1;
%     
%     [x_cent,y_cent] = meshgrid(x_lo:x_hi,y_lo:y_hi);
%     pixels = (x_cent - 1) * imh + y_cent;
%     pixels = pixels(:);
%     
%     for ix = 1 : chns.ntext
%         featArr.texture(ii, ix) = mean( chns.imtext(pixels + (ix-1) * imw * imh) );
%     end
%     textureHist = hist( chns.texthist(pixels), 1:chns.ntext )';
%     featArr.textureHist(ii, :) = textureHist / max( sum(textureHist), eps );
%     
%     lbpHist = hist( chns.imlbp(pixels), 0:255 )';
%     featArr.lbpHist(ii, :) = lbpHist / max( sum(lbpHist), eps );
% end






