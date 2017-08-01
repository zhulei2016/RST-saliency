function salimg_opt = saliencyDetection(sourceim, model, net, descPara)
if ischar(sourceim), I_org = imread( sourceim );
else
    I_org = sourceim;
end
% [ hsum, wsum, I] = ImageCrop( I );
[imh_org, imw_org, c] = size(I_org);
if c ~= 3
    %     error('only rgb image is accepted');
    I_org = cat(3, I_org, I_org, I_org);
end

if imh_org < descPara.minImsize || imw_org < descPara.minImsize
    s = descPara.minImsize / min(imh_org, imw_org); I = imResample(I_org, s);
else
    I = I_org;
end
pSz = descPara.patchSize;
alignment = descPara.cnnOpt.alignment;

%% Get the candidate regions by FCN prediction
Ifcn = refinenetPredict(net, I); Ifcn = double(Ifcn);
assert(max(Ifcn(:)) <= 1 && min(Ifcn(:)) == 0);
Imsk = imResample(Ifcn * 255, [imh_org, imw_org]); % only for intermediate result saving

%% predict saliency in multiscale manner
layers = length(descPara.shrink); sal = cell(layers, 1);
foremask = cell(layers, 1);

mask_roi = cell(layers, 1);
for ii = 1 : layers
    %% rescale and pad the image
    ratio = descPara.shrink(ii); I_s = imResample(I, ratio);
    Ifcn_s = imResample(Ifcn, ratio);
    nStride = ceil(descPara.nstride_test * ratio); [imh_s, imw_s, ~] = size(I_s);
    assert(imh_s == size(Ifcn_s, 1)); assert(imw_s == size(Ifcn_s, 2));
    
    p = (pSz - 1) * ones(1, 4); I_p = imPad(I_s, p, 'symmetric'); % T/B/L/R
    Ifcn_p = imPad(Ifcn_s, p, 'symmetric');
    [imh_p, imw_p, ~] = size(I_p); bb_I = [p(3) + 1, p(1) + 1, imw_s, imh_s];
    
    %% get regional features
    tic;
    chns = extr_feat_plane(I_p, descPara);
    imsegs = im2superpixels(I_p, 'SLIC', [200, 15] );
    %     [colourIm, ~] = Image2ColourSpace(I_p, 'Hsv');
    %     [imsegs.segimage, ~, imsegs.adjmat] = mexFelzenSegmentIndex(colourIm, 0.8, 200, 200);
    %     imsegs.nseg = max(imsegs.segimage(:));
    
    if descPara.cnnOpt.propagation == 1
        [foremask{ii}, ~] = labelPropagation(...
            im2double(I_p), imsegs, Ifcn_p, chns.edgemap, 0.5, 0);
    else
        foremask{ii} = Ifcn_p;
    end
    
    %     foremask{ii} = double(foremask{ii} | Ifcn_p);
    [roi, grids, pts_ds] = ...
        getDetectionRegion(logical(foremask{ii}), bb_I, pSz, nStride, alignment);
    feat_bkg = extr_feat_background(chns, imh_s, imw_s, pSz, descPara.bw);
    feat = extr_feat_channel(chns, feat_bkg, grids, pts_ds,...
        pSz, descPara.surroundingWidth, nStride);
    
    [grids, ia] = unique(grids, 'rows','stable' );
    feat = feat(ia, :);
    
    elt = toc; fprintf('...feature extraction at scale %d: %.2f s\n', ii, elt);
 
    %% predict the struct labels
    tic;
    para.imh = imh_p; para.imw = imw_p; para.split = descPara.split;
    para.en_sal = 0; para.use2d = 0;
    [slabel, ~] = saliencyPredict(feat, grids, model, para);
    if any(foremask{ii}(:))
        s2 = treeRankingCandicate(double(foremask{ii}),...
            grids, slabel, pSz, pSz, descPara.ssprank);
    else
        s2 = treeRankingSegment(I_p, grids, slabel, pSz, pSz);
    end
    %     para.imh = imh_p; para.imw = imw_p; para.split = descPara.split;
    %     para.en_sal = 0; para.use2d = 1;
    %     [slabel2d, ~] = saliencyPredict(feat, grids, model, para);
    %     s22 = treesOptimization2(double(Ifcn_p), grids, slabel2d, pSz, pSz);
    %     assert(isempty(find(s2 - s22, 1)));
    
    if any(s2(:))
        mask_rect = false(imh_p, imw_p);
        for i = 1 : size(roi, 1)
            mask_rect(roi(i, 2) : (roi(i, 2) + roi(i, 4) - 1),...
                roi(i, 1) : (roi(i, 1) + roi(i, 3) - 1)) = 1;
        end
        s2(mask_rect) = my_Normalize(s2(mask_rect), 0, 1); s2(~mask_rect) = 0;
    else
        mask_rect = true(imh_p, imw_p);
    end
    
    % crop to original size
    sal{ii} = imPad(s2, -p, 'symmetric');
    sal{ii} = imResample(sal{ii}, [imh_org, imw_org]);
    %         foremask{ii} = imPad(foremask{ii}, -p, 'symmetric');
    %         foremask{ii} = imResample(foremask{ii}, [imh_org, imw_org]);
    
    mask_rect = imPad(double(mask_rect), -p, 'symmetric');
    mask_roi{ii} = imResample(mask_rect, [imh_org, imw_org]);

    elt = toc; fprintf('...struct label prediction at scale %d: %.2f s\n', ii, elt);
end


%% refine the result using superpixels
tic
salimg = zeros(imh_org, imw_org); mask = false(imh_org, imw_org);
for ii = 1 : layers
    salimg = salimg + sal{ii};
    mask = mask | logical(mask_roi{ii});
end
salimg = my_Normalize(salimg, 0, 1);

imsegs_org = im2superpixels(I_org, 'SLIC', [descPara.salprop.spNum, 15] );

maskimg = double(logical(Imsk)); 
if descPara.cnnOpt.mask == 1
    salimg_opt = saliencyPropagation(im2double(I_org), imsegs_org, salimg,...
        descPara.salprop.beta, descPara.salprop.gamma, descPara.salprop.sigma, mask, maskimg, []);
else
    [salimg_opt, ~] = saliencyPropagation(im2double(I_org), imsegs_org, salimg,...
        descPara.salprop.beta, descPara.salprop.gamma, descPara.salprop.sigma, [], maskimg, []);
end

elt = toc; fprintf('...refinemant at scale %d: %.2f s\n', ii, elt);
end





