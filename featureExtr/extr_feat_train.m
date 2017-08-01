function [feat, label] = extr_feat_train(im, imgt, descPara)

%% make grid sampling
[imh, imw, c] = size(im); if c ~= 3, error('only rgb image is accepted'); end
nStride = descPara.nstride_train;
patchSize = descPara.patchSize;

s = [imw, imh]; nxy = floor((s - patchSize) / nStride) + 1; 
% s1 = patchSize - s + (ceil(s/nStride) - 1) * nStride;
[gridX,gridY] = meshgrid(1 : nStride : (nxy(1) - 1) * nStride + 1,...
    1 : nStride : (nxy(2) - 1) * nStride + 1); grids = [gridX(:), gridY(:)];
% get dense-sift computation region
pts = [grids(1, 1) + 2, grids(1, 2) + 2, ...
    grids(end, 1) + patchSize - 1, grids(end, 2) + patchSize - 1]; % [xmin, ymin, xmax, ymax];

if 0,
    im4show = im; grid_1d = (grids(:, 1) - 1) * imh + grids(:, 2); sz = imh * imw;
    im4show(grid_1d) = 255; im4show(grid_1d + sz) = 0; im4show(grid_1d + 2 * sz) = 0;
    imshow(im4show);
end

%% get structure labeling
nPatch = size(grids, 1); label = cell(nPatch, 1);
xc_tl = grids(:, 1); xc_br = xc_tl + patchSize - 1;
yc_tl = grids(:, 2); yc_br = yc_tl + patchSize - 1;
for i = 1 : nPatch,
    label{i} = uint8(imgt(yc_tl(i) : yc_br(i), xc_tl(i) : xc_br(i)));
end

% check some result
if 0,
    for kk = 450 : nPatch,
        [x_cent,y_cent] = meshgrid(xc_tl(kk):xc_br(kk),yc_tl(kk):yc_br(kk));
        pix_cent = (x_cent - 1) * imh + y_cent;
        im3d = highlightRegions(im2uint8(imgt), pix_cent, [255, 0, 0]);
        subplot(1, 2, 1), imshow(im3d);
        subplot(1, 2, 2), imshow(255 * label{kk});
    end
end

%% extract features
% get feature planes for the whole image
chns = extr_feat_plane(im, descPara);
% extract the background features for the whole image
feat_bkg = extr_feat_background(chns, imh, imw, 1, descPara.bw);
% extract inner attributes, center-surround and contrast-based features
feat = extr_feat_channel(chns, feat_bkg, grids, pts, ...
    patchSize, descPara.surroundingWidth, nStride);
end





