function feat = extr_feat_arbitraryRegions(chns, pixels)

imsz = chns.imh * chns.imw;

feat.colorArr = zeros(24, 1);
feat.colorArr(1) = mean( chns.rgb(pixels) );   feat.colorArr(2) = std(chns.rgb(pixels), 1);
feat.colorArr(3) = mean(chns.rgb(pixels + imsz) );   feat.colorArr(4) = std(chns.rgb(pixels + imsz), 1);
feat.colorArr(5) = mean(chns.rgb(pixels + imsz * 2) ); feat.colorArr(6) = std(chns.rgb(pixels + imsz * 2), 1);
feat.RGBHist = hist( chns.Q_rgb(pixels), 1 : chns.nRGBHist )';
feat.RGBHist = feat.RGBHist / max( sum(feat.RGBHist), eps );

feat.colorArr(7) = mean( chns.lab(pixels) );   feat.colorArr(8) = std(chns.lab(pixels), 1);
feat.colorArr(9) = mean(chns.lab(pixels + imsz) );   feat.colorArr(10) = std(chns.lab(pixels + imsz), 1);
feat.colorArr(11) = mean(chns.lab(pixels + imsz * 2) ); feat.colorArr(12) = std(chns.lab(pixels + imsz * 2), 1);
feat.LABHist = hist( chns.Q_lab(pixels), 1:chns.nLABHist )';
feat.LABHist = feat.LABHist / max( sum(feat.LABHist), eps );

feat.colorArr(13) = mean( chns.hsv(pixels) );   feat.colorArr(14) = std(chns.hsv(pixels), 1);
feat.colorArr(15) = mean(chns.hsv(pixels + imsz) );   feat.colorArr(16) = std(chns.hsv(pixels + imsz), 1);
feat.colorArr(17) = mean(chns.hsv(pixels + imsz * 2) ); feat.colorArr(18) = std(chns.hsv(pixels + imsz * 2), 1);
feat.HSVHist = hist( chns.Q_hsv(pixels), 1:chns.nHSVHist )';
feat.HSVHist = feat.HSVHist / max( sum(feat.HSVHist), eps );

feat.colorArr(19) = mean( chns.opp(pixels) );   feat.colorArr(20) = std(chns.opp(pixels), 1);
feat.colorArr(21) = mean(chns.opp(pixels + imsz) );   feat.colorArr(22) = std(chns.opp(pixels + imsz), 1);
feat.colorArr(23) = mean(chns.opp(pixels + imsz * 2) ); feat.colorArr(24) = std(chns.opp(pixels + imsz * 2), 1);
feat.OPPHist = hist( chns.Q_opp(pixels), 1:chns.nOPPHist )';
feat.OPPHist = feat.OPPHist / max( sum(feat.OPPHist), eps );

feat.gradm = zeros(2, 1);
feat.gradm(1) = mean( chns.gradm(pixels) ); feat.gradm(2) = std( chns.gradm(pixels), 1);
gradh = reshape(chns.gradh, [imsz, size(chns.gradh, 3)]);
feat.gradh = mean(gradh(pixels, :))';

imtext = reshape(chns.imtext, [imsz, size(chns.imtext, 3)]);
feat.texture = mean(imtext(pixels, :))';

feat.textureHist = hist( chns.texthist(pixels), 1:chns.ntext )';
feat.textureHist = feat.textureHist / max( sum(feat.textureHist), eps );

feat.lbpHist = hist( chns.imlbp(pixels), 0:255 )';
feat.lbpHist = feat.lbpHist / max( sum(feat.lbpHist), eps );

dog = reshape(chns.dog, [imsz, size(chns.dog, 3)]);
feat.dog = mean(dog(pixels, :))';

gabor = reshape(chns.gabor, [imsz, size(chns.gabor, 3)]);
feat.gabor = mean(gabor(pixels, :))';

feat.edgeStr = mean( chns.edgemap(pixels) );
% feat.edgeStr_std = std( chns.edgemap(pixels) );

% feat.focusness = mean( chns.focusmap(pixels) );

mc = mean(chns.cannymap(pixels));
if mc == 0
    feat.focusness = 0;
%     feat.focusness_std = 0;
else
    feat.focusness = mean( chns.scalemap(pixels)) / mc;
%     feat.focusness_std = std( chns.scalemap(pixels)) / mc;
end



