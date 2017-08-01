function feat = extr_feat_channel(chns, feat_bkg, grids, pts, patchSize, surroundingWidth, nStride)

imh = chns.imh; imw = chns.imw; surrWidth = ceil(surroundingWidth * patchSize); 
nPatch = size(grids, 1); gridX = grids(:, 1); gridY = grids(:, 2);

%% extract sift features (gray-channel)
% binSize = floor(patchSize / 4);
% Is = vl_imsmooth(chns.gray, sqrt((binSize / 3) ^ 2 - .25));
% feat_prop.siftArr = zeros(nPatch, 128); st = 1; ed = 0;
% for i = 1 : size(pts, 1),
%     [cen, siftArr] = vl_dsift(single(Is), 'size', binSize, 'Step', nStride, 'Bounds', pts(i, :), 'FloatDescriptors') ;
%     xmax = pts(i, 3) - 8; ymax = pts(i, 4) - 8; siftArr(:, ((cen(1, :) > xmax) | (cen(2, :) > ymax))) = [];
%     ed = st + size(siftArr, 2) - 1; feat_prop.siftArr(st : ed, :) = double(siftArr'); st = ed + 1;
% end
% feat_prop.siftArr = feat_prop.siftArr ./ repmat((max(feat_prop.siftArr,[], 2) + eps), 1, size(siftArr, 1));
% assert(ed == length(gridX)); clear siftArr;

% [f, siftArr] = vl_dsift(single(Is), 'size', binSize, 'Step', nStride, 'FloatDescriptors') ;
% t = patchSize - 1 - 3 * binSize / 2; f1 = find((f(1, :) + t) > imw); f2 = find((f(2, :) + t) > imh);
% siftArr(:, unique([f1, f2])) = []; feat_prop.siftArr = double(siftArr');
% assert(size(siftArr, 2) == length(gridX));
% clear siftArr;

%% extract all averaged feature (multi-channels)
[c, s, num_c, num_s] = getSurroundings( gridX, gridY, imh, imw, [patchSize, patchSize], surrWidth );
 % color features (variance required)
chn_tmp = cat(3, chns.rgb, chns.hsv, chns.lab, chns.opp);
feat_prop.colorArr = zeros(nPatch, 24); feat_surr.colorArr = zeros(nPatch, 24);
[feat_prop.colorArr(:, 1:2:23), feat_prop.colorArr(:, 2:2:24), ...
    feat_surr.colorArr(:, 1:2:23), feat_surr.colorArr(:, 2:2:24)] = ...
    intMeanStd(chn_tmp, c, s, num_c, num_s, 1);

feat_prop.gradm = zeros(nPatch, 2); feat_surr.gradm = zeros(nPatch, 2);
[feat_prop.gradm(:, 1), feat_prop.gradm(:, 2), feat_surr.gradm(:, 1), feat_surr.gradm(:, 2)] = ...
    intMeanStd(chns.gradm, c, s, num_c, num_s, 1); 

% texture, gradient and multiscale features (no variance)
[feat_prop.texture, ~, feat_surr.texture, ~] = intMeanStd(chns.imtext, c, s, num_c, num_s, 0); 
[feat_prop.gradh, ~, feat_surr.gradh, ~] = intMeanStd(chns.gradh, c, s, num_c, num_s, 0); 
[feat_prop.dog, ~, feat_surr.dog, ~] = intMeanStd(chns.dog, c, s, num_c, num_s, 0); 
[feat_prop.gabor, ~, feat_surr.gabor, ~] = intMeanStd(chns.gabor, c, s, num_c, num_s, 0); 

% [feat_prop.edgeStr, ~, feat_surr.edgeStr, ~] = intMeanStd(chns.edgemap, c, s, num_c, num_s, 0); 
[feat_prop.edgeStr, feat_prop.edgeStr_std, feat_surr.edgeStr, ~] = intMeanStd(chns.edgemap, c, s, num_c, num_s, 1); 

% [feat_prop.focusness, ~, feat_surr.focusness, ~] = intMeanStd(chns.focusmap, c, s, num_c, num_s, 0); 

feat_prop.focusness = zeros(size(c, 1), 1); feat_surr.focusness = zeros(size(s, 1), 1);
feat_prop.focusness_std = zeros(size(c, 1), 1);
% [canny_c, ~, canny_s, ~] = intMeanStd(chns.cannymap, c, s, num_c, num_s, 0); 
% [scale_c, ~, scale_s, ~] = intMeanStd(chns.scalemap, c, s, num_c, num_s, 0); 
[canny_c, cannystd_c, canny_s, ~] = intMeanStd(chns.cannymap, c, s, num_c, num_s, 1); 
[scale_c, scalestd_c, scale_s, ~] = intMeanStd(chns.scalemap, c, s, num_c, num_s, 1); 

ind = find(canny_c ~= 0); feat_prop.focusness(ind) = scale_c(ind) ./ canny_c(ind);
ind = find(canny_s ~= 0); feat_surr.focusness(ind) = scale_s(ind) ./ canny_s(ind);

ind = find(cannystd_c ~= 0); feat_prop.focusness_std(ind) = scalestd_c(ind) ./ cannystd_c(ind);

%% extract all histogramed feature (multi-channels)
[boxes_c, boxes_s] = getSurroundings2(gridX, gridY, imh, imw, [patchSize, patchSize], surrWidth);
% rgb lab hsv opp color hitogram
inthist_rgb = vl_inthist(uint32(chns.Q_rgb), 'NUMLABELS', chns.nRGBHist);
inthist_lab = vl_inthist(uint32(chns.Q_lab), 'NUMLABELS', chns.nLABHist);
inthist_hsv = vl_inthist(uint32(chns.Q_hsv), 'NUMLABELS', chns.nHSVHist);
inthist_opp = vl_inthist(uint32(chns.Q_opp), 'NUMLABELS', chns.nOPPHist);

rgbHist_c = vl_sampleinthist(inthist_rgb, boxes_c);
rgbHist_s = vl_sampleinthist(inthist_rgb, boxes_s) - rgbHist_c;
rgbHist_c = double(rgbHist_c) ./ repmat(max( sum(rgbHist_c, 1), eps ), chns.nRGBHist, 1);
rgbHist_s = double(rgbHist_s) ./ repmat(max( sum(rgbHist_s, 1), eps ), chns.nRGBHist, 1);
feat_prop.RGBHist = rgbHist_c;
feat_surr.RGBHist = rgbHist_s;

labHist_c = vl_sampleinthist(inthist_lab, boxes_c);
labHist_s = vl_sampleinthist(inthist_lab, boxes_s) - labHist_c;
labHist_c = double(labHist_c) ./ repmat(max( sum(labHist_c, 1), eps ), chns.nLABHist, 1);
labHist_s = double(labHist_s) ./ repmat(max( sum(labHist_s, 1), eps ), chns.nLABHist, 1);
feat_prop.LABHist = labHist_c;
feat_surr.LABHist = labHist_s;

hsvHist_c = vl_sampleinthist(inthist_hsv, boxes_c);
hsvHist_s = vl_sampleinthist(inthist_hsv, boxes_s) - hsvHist_c;
hsvHist_c = double(hsvHist_c) ./ repmat(max( sum(hsvHist_c, 1), eps ), chns.nHSVHist, 1);
hsvHist_s = double(hsvHist_s) ./ repmat(max( sum(hsvHist_s, 1), eps ), chns.nHSVHist, 1);
feat_prop.HSVHist = hsvHist_c;
feat_surr.HSVHist = hsvHist_s;

oppHist_c = vl_sampleinthist(inthist_opp, boxes_c);
oppHist_s = vl_sampleinthist(inthist_opp, boxes_s) - oppHist_c;
oppHist_c = double(oppHist_c) ./ repmat(max( sum(oppHist_c, 1), eps ), chns.nOPPHist, 1);
oppHist_s = double(oppHist_s) ./ repmat(max( sum(oppHist_s, 1), eps ), chns.nOPPHist, 1);
feat_prop.OPPHist = oppHist_c;
feat_surr.OPPHist = oppHist_s;

% rgb la lb hu sat histogram
nbins = 25;
hu = round(chns.hsv(:, :, 1) .* (nbins-1) + 1);
sat = round(chns.hsv(:, :, 2) .* (nbins-1) + 1);
inthist_hu = vl_inthist(uint32(hu), 'NUMLABELS', nbins);
inthist_sat = vl_inthist(uint32(sat), 'NUMLABELS', nbins);
huHist_c = vl_sampleinthist(inthist_hu, boxes_c);
satHist_c = vl_sampleinthist(inthist_sat, boxes_c);
feat_prop.huHist = double(huHist_c) ./ repmat(max( sum(huHist_c, 1), eps ), nbins, 1);
feat_prop.satHist = double(satHist_c) ./ repmat(max( sum(satHist_c, 1), eps ), nbins, 1);

% la = round(chns.lab(:, :, 2) .* (nbins-1) + 1);
% lb = round(chns.lab(:, :, 3) .* (nbins-1) + 1);
% inthist_la = vl_inthist(uint32(la), 'NUMLABELS', nbins);
% inthist_lb = vl_inthist(uint32(lb), 'NUMLABELS', nbins);
% laHist_c = vl_sampleinthist(inthist_la, boxes_c);
% lbHist_c = vl_sampleinthist(inthist_lb, boxes_c);
% feat_prop.laHist = double(laHist_c) ./ repmat(max( sum(laHist_c, 1), eps ), nbins, 1);
% feat_prop.lbHist = double(lbHist_c) ./ repmat(max( sum(lbHist_c, 1), eps ), nbins, 1);

rr = round(chns.rgb(:, :, 1) .* (nbins-1) + 1);
gg = round(chns.rgb(:, :, 2) .* (nbins-1) + 1);
bb = round(chns.rgb(:, :, 3) .* (nbins-1) + 1);
inthist_rr = vl_inthist(uint32(rr), 'NUMLABELS', nbins);
inthist_gg = vl_inthist(uint32(gg), 'NUMLABELS', nbins);
inthist_bb = vl_inthist(uint32(bb), 'NUMLABELS', nbins);
rrHist_c = vl_sampleinthist(inthist_rr, boxes_c);
ggHist_c = vl_sampleinthist(inthist_gg, boxes_c);
bbHist_c = vl_sampleinthist(inthist_bb, boxes_c);
feat_prop.rrHist = double(rrHist_c) ./ repmat(max( sum(rrHist_c, 1), eps ), nbins, 1);
feat_prop.ggHist = double(ggHist_c) ./ repmat(max( sum(ggHist_c, 1), eps ), nbins, 1);
feat_prop.bbHist = double(bbHist_c) ./ repmat(max( sum(bbHist_c, 1), eps ), nbins, 1);

% lbp 
inthist_lbp = vl_inthist(uint32(chns.imlbp), 'NUMLABELS', 256);
lbpHist_c = vl_sampleinthist(inthist_lbp, boxes_c);
lbpHist_s = vl_sampleinthist(inthist_lbp, boxes_s) - lbpHist_c;
lbpHist_c = double(lbpHist_c) ./ repmat(max( sum(lbpHist_c, 1), eps ), 256, 1);
lbpHist_s = double(lbpHist_s) ./ repmat(max( sum(lbpHist_s, 1), eps ), 256, 1);
feat_prop.lbpHist = lbpHist_c;
feat_surr.lbpHist = lbpHist_s;

% extract geometric features
feat_prop.x = (gridX + patchSize/2 - 0.5) / imw;    feat_prop.y = (gridY + patchSize/2 - 0.5) / imh;
feat_prop.width = imw;    feat_prop.height = imh;

%% contrast to the pesudo background
feat_contr.bkg_colorArr = abs(feat_prop.colorArr' - repmat(feat_bkg.colorArr, [1 nPatch])); % color vector

feat_contr.bkg_RGBHist = hist_dist( feat_prop.RGBHist, repmat(feat_bkg.RGBHist, [1 nPatch]), 'x2' );   % color histogram contrast
feat_contr.bkg_LABHist = hist_dist( feat_prop.LABHist, repmat(feat_bkg.LABHist, [1 nPatch]), 'x2' );
feat_contr.bkg_HSVHist = hist_dist( feat_prop.HSVHist, repmat(feat_bkg.HSVHist, [1 nPatch]), 'x2' );
feat_contr.bkg_OPPHist = hist_dist( feat_prop.OPPHist, repmat(feat_bkg.OPPHist, [1 nPatch]), 'x2' );

feat_contr.bkg_texture = abs(feat_prop.texture' - repmat(feat_bkg.texture, [1 nPatch])); % texture contrast
% feat_contr.bkg_textureHist = hist_dist( feat_prop.textureHist, repmat(feat_bkg.textureHist, [1 nPatch]), 'x2' );   
feat_contr.bkg_lbpHist = hist_dist( feat_prop.lbpHist, repmat(feat_bkg.lbpHist, [1 nPatch]), 'x2' );   

feat_contr.bkg_gradm = abs(feat_prop.gradm' - repmat(feat_bkg.gradm, [1 nPatch])); % gradient contrast
feat_contr.bkg_gradh = abs(feat_prop.gradh' - repmat(feat_bkg.gradh, [1 nPatch]));

feat_contr.bkg_dog = abs(feat_prop.dog' - repmat(feat_bkg.dog, [1 nPatch])); % multiscale contrast
feat_contr.bkg_gabor = abs(feat_prop.gabor' - repmat(feat_bkg.gabor, [1 nPatch]));

feat_contr.bkg_edgeStr = abs(feat_prop.edgeStr' - repmat(feat_bkg.edgeStr, [1 nPatch])); % edge strenth contrast

feat_contr.bkg_focusness = abs(feat_prop.focusness' - repmat(feat_bkg.focusness, [1 nPatch]));

%% contrast to the surroundings
feat_contr.cs_colorArr = abs(feat_prop.colorArr' - feat_surr.colorArr');

feat_contr.cs_RGBHist = hist_dist( feat_prop.RGBHist, feat_surr.RGBHist, 'x2' );   % color histogram contrast
feat_contr.cs_LABHist = hist_dist( feat_prop.LABHist, feat_surr.LABHist, 'x2' );
feat_contr.cs_HSVHist = hist_dist( feat_prop.HSVHist, feat_surr.HSVHist, 'x2' );
feat_contr.cs_OPPHist = hist_dist( feat_prop.OPPHist, feat_surr.OPPHist, 'x2' );

feat_contr.cs_texture = abs(feat_prop.texture' - feat_surr.texture');
% feat_contr.cs_textureHist = hist_dist( feat_prop.textureHist, feat_surr.textureHist, 'x2' );   
feat_contr.cs_lbpHist = hist_dist( feat_prop.lbpHist, feat_surr.lbpHist, 'x2' );   

feat_contr.cs_gradm = abs(feat_prop.gradm' - feat_surr.gradm'); % gradient contrast
feat_contr.cs_gradh = abs(feat_prop.gradh' - feat_surr.gradh');

feat_contr.cs_dog = abs(feat_prop.dog' - feat_surr.dog'); % multiscale contrast
feat_contr.cs_gabor = abs(feat_prop.gabor' - feat_surr.gabor');

feat_contr.cs_edgeStr = abs(feat_prop.edgeStr' - feat_surr.edgeStr'); % edge strenth contrast
feat_contr.cs_focusness = abs(feat_prop.focusness' - feat_surr.focusness'); % edge strenth contrast

%% reconstruct all the candidate from uniqued ones

% 499 dim features
feat = [feat_prop.colorArr,...
    feat_prop.huHist', feat_prop.satHist',...
    feat_prop.rrHist', feat_prop.ggHist', feat_prop.bbHist',...
    feat_prop.gradm, feat_prop.gradh, feat_prop.dog, feat_prop.gabor,...
    feat_prop.x, feat_prop.y,...
    feat_prop.edgeStr, feat_prop.edgeStr_std,...
    feat_prop.focusness, feat_prop.focusness_std,... % inner attributes
    feat_contr.bkg_colorArr', feat_contr.bkg_RGBHist', feat_contr.bkg_LABHist', ...
    feat_contr.bkg_HSVHist', feat_contr.bkg_OPPHist', feat_contr.bkg_texture', ...
    feat_contr.bkg_lbpHist', feat_contr.bkg_gradm', feat_contr.bkg_gradh', ...
    feat_contr.bkg_dog', feat_contr.bkg_gabor', feat_contr.bkg_edgeStr', ...
    feat_contr.bkg_focusness'...% contrast to background 
    feat_contr.cs_colorArr', feat_contr.cs_RGBHist', feat_contr.cs_LABHist', ...
    feat_contr.cs_HSVHist', feat_contr.cs_OPPHist', feat_contr.cs_texture', ...
    feat_contr.cs_lbpHist', feat_contr.cs_gradm', feat_contr.cs_gradh', ...
    feat_contr.cs_dog', feat_contr.cs_gabor', feat_contr.cs_edgeStr', ...
    feat_contr.cs_focusness'];        % contrast to surroundings

% % 422 dim features
% feat = [feat_prop.colorArr, feat_prop.huHist', ...
%     feat_prop.satHist', feat_prop.gradm, feat_prop.gradh, feat_prop.dog, feat_prop.gabor,...
%     feat_prop.x, feat_prop.y, feat_prop.edgeStr, feat_prop.focusness...             % inner attributes
%     feat_contr.bkg_colorArr', feat_contr.bkg_RGBHist', feat_contr.bkg_LABHist', ...
%     feat_contr.bkg_HSVHist', feat_contr.bkg_OPPHist', feat_contr.bkg_texture', ...
%     feat_contr.bkg_lbpHist', feat_contr.bkg_gradm', feat_contr.bkg_gradh', ...
%     feat_contr.bkg_dog', feat_contr.bkg_gabor', feat_contr.bkg_edgeStr', ...
%     feat_contr.bkg_focusness'...% contrast to background 
%     feat_contr.cs_colorArr', feat_contr.cs_RGBHist', feat_contr.cs_LABHist', ...
%     feat_contr.cs_HSVHist', feat_contr.cs_OPPHist', feat_contr.cs_texture', ...
%     feat_contr.cs_lbpHist', feat_contr.cs_gradm', feat_contr.cs_gradh', ...
%     feat_contr.cs_dog', feat_contr.cs_gabor', feat_contr.cs_edgeStr', ...
%     feat_contr.cs_focusness'];        % contrast to surroundings

% % 550 dim features
% feat = [feat_prop.siftArr, feat_prop.colorArr, feat_prop.huHist', ...
%     feat_prop.satHist', feat_prop.gradm, feat_prop.gradh, feat_prop.dog, feat_prop.gabor,...
%     feat_prop.x, feat_prop.y, feat_prop.edgeStr, feat_prop.focusness...             % inner attributes
%     feat_contr.bkg_colorArr', feat_contr.bkg_RGBHist', feat_contr.bkg_LABHist', ...
%     feat_contr.bkg_HSVHist', feat_contr.bkg_OPPHist', feat_contr.bkg_texture', ...
%     feat_contr.bkg_lbpHist', feat_contr.bkg_gradm', feat_contr.bkg_gradh', ...
%     feat_contr.bkg_dog', feat_contr.bkg_gabor', feat_contr.bkg_edgeStr', ...
%     feat_contr.bkg_focusness'...% contrast to background 
%     feat_contr.cs_colorArr', feat_contr.cs_RGBHist', feat_contr.cs_LABHist', ...
%     feat_contr.cs_HSVHist', feat_contr.cs_OPPHist', feat_contr.cs_texture', ...
%     feat_contr.cs_lbpHist', feat_contr.cs_gradm', feat_contr.cs_gradh', ...
%     feat_contr.cs_dog', feat_contr.cs_gabor', feat_contr.cs_edgeStr', ...
%     feat_contr.cs_focusness'];        % contrast to surroundings

% % 806 dim features
% feat = [feat_prop.siftArr, feat_prop.lbpHist', feat_prop.colorArr, feat_prop.huHist', ...
%     feat_prop.satHist', feat_prop.gradm, feat_prop.gradh, feat_prop.dog, feat_prop.gabor,...
%     feat_prop.x, feat_prop.y, feat_prop.edgeStr, feat_prop.focusness...             % inner attributes
%     feat_contr.bkg_colorArr', feat_contr.bkg_RGBHist', feat_contr.bkg_LABHist', ...
%     feat_contr.bkg_HSVHist', feat_contr.bkg_OPPHist', feat_contr.bkg_texture', ...
%     feat_contr.bkg_lbpHist', feat_contr.bkg_gradm', feat_contr.bkg_gradh', ...
%     feat_contr.bkg_dog', feat_contr.bkg_gabor', feat_contr.bkg_edgeStr', ...
%     feat_contr.bkg_focusness'...% contrast to background 
%     feat_contr.cs_colorArr', feat_contr.cs_RGBHist', feat_contr.cs_LABHist', ...
%     feat_contr.cs_HSVHist', feat_contr.cs_OPPHist', feat_contr.cs_texture', ...
%     feat_contr.cs_lbpHist', feat_contr.cs_gradm', feat_contr.cs_gradh', ...
%     feat_contr.cs_dog', feat_contr.cs_gabor', feat_contr.cs_edgeStr', ...
%     feat_contr.cs_focusness'];        % contrast to surroundings

% 750 dim features
% feat = [feat_prop.siftArr, feat_prop.lbpHist', feat_prop.colorArr, ...
%     feat_prop.gradm, feat_prop.gradh, feat_prop.dog, feat_prop.gabor,...
%     feat_prop.x, feat_prop.y,...              % inner attributes
%     feat_contr.bkg_colorArr', feat_contr.bkg_RGBHist', feat_contr.bkg_LABHist', ...
%     feat_contr.bkg_HSVHist', feat_contr.bkg_OPPHist', feat_contr.bkg_texture', ...
%     feat_contr.bkg_lbpHist', feat_contr.bkg_gradm', feat_contr.bkg_gradh', ...
%     feat_contr.bkg_dog', feat_contr.bkg_gabor',...% contrast to background 
%     feat_contr.cs_colorArr', feat_contr.cs_RGBHist', feat_contr.cs_LABHist', ...
%     feat_contr.cs_HSVHist', feat_contr.cs_OPPHist', feat_contr.cs_texture', ...
%     feat_contr.cs_lbpHist', feat_contr.cs_gradm', feat_contr.cs_gradh', ...
%     feat_contr.cs_dog', feat_contr.cs_gabor'];        % contrast to surroundings

if 1 % check each feature (all 0, or equally)
    %     assert(sum(any(feat, 1)) == size(feat, 2));
    assert(sum(sum(isnan(feat))) == 0);
end
    
end

