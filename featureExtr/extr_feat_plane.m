% get feature planes for the whole image
function chns = extr_feat_plane(I, descPara)
[imh, imw, imc] = size(I);
if imc ~= 3
    error('only rgb image is accepted');
end

chns.imh = imh;
chns.imw = imw;

% transform rgb image to other color spaces (all in the range of [0,1])
[chns.rgb, ~] = Image2ColourSpace(I, 'Rgb');
[chns.lab, ~] = Image2ColourSpace(I, 'Lab');
[chns.hsv, ~] = Image2ColourSpace(I, 'Hsv');
[chns.opp, ~] = Image2ColourSpace(I, 'Opp');
grayim = rgb2gray(I); chns.gray = im2double(grayim);

% transform rgb image to gradient space
p.shrink = 1; p.pColor.enabled = 0; 
g=chnsCompute(I,p); 
chns.gradm = my_Normalize(g.data{1}, 0, 1); 
chns.gradh = my_Normalize(g.data{2}, 0, 1); 
% [M,O] = gradientMag( I1, 0, opts.normRad, .01 );
% H = gradientHist( M, O, max(1,shrink/s), 4, 0 );
    
% generate the 1 dimensional color labels
[chns.Q_rgb, chns.nRGBHist] = colorLabeling(chns.rgb, 5);
[chns.Q_lab, chns.nLABHist] = colorLabeling(chns.lab, 5);
[chns.Q_hsv, chns.nHSVHist] = colorLabeling(chns.hsv, 5);
[chns.Q_opp, chns.nOPPHist] = colorLabeling(chns.opp, 5);

% texture - response of filter bank
ntexthist = 15;
nloc = 8;
filtext = makeLMfilters;
ntext = size(filtext, 3);

chns.ntexthist = ntexthist;
chns.nloc = nloc;

chns.ntext = ntext;

chns.nlbp = 256;

imtext = zeros([imh imw ntext]);
for f = 1:ntext
    response = abs(imfilter(im2single(grayim), filtext(:, :, f), 'same'));
    response = (response - min(response(:))) / (max(response(:)) - min(response(:)) + eps);
    imtext(:, :, f) = response;
end
[~, texthist] = max(imtext, [], 3);
chns.imtext = imtext;
chns.texthist = texthist;

% texture - LBP
imlbp = mexLBP( grayim );
chns.imlbp = double( imlbp );

% DoG space
dog = FbApply2d( im2double(grayim), descPara.Fdog, 'same');
chns.dog = my_Normalize(dog, 0, 1);
% Gabor space
gabor = FbApply2d( im2double(grayim), descPara.Fgabor, 'same');
chns.gabor = my_Normalize(gabor, 0, 1);
% get dollar's edge map
E = edgesDetect( I, descPara.edgeModel); chns.edgemap = my_Normalize(E, 0, 1);
% get focusness map
[chns.cannymap,~] = edge(grayim, 'canny'); 
scalemap=CalScale(grayim);
chns.scalemap = chns.cannymap ./ scalemap;

focusmap = SVF(grayim);
chns.focusmap = my_Normalize(focusmap, 0, 1);
end



