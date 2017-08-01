function feat_contr = extr_lowLevl_contr( feat_prop, feat_bkg, feat_surr)

nPatch = size(feat_prop.x, 1);
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

end


