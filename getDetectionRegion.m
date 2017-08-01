% get the optimal rectangles for bounding boxes that can perfectly enclose
% sliding window and corresponding dense sift bins
% assume that the outlier of bbs can be entirely obtained
function [roi, grids, pts_ds] = getDetectionRegion(I_pred, bb_I, patchSize, nStride, alignment)

% superpixel segmentation
% imsegs = im2superpixels(I_p, 'SLIC', [300, 15] );
% [colourIm, ~] = Image2ColourSpace(I_p, 'Hsv');
% [imsegs.segimage, ~, imsegs.adjmat] = mexFelzenSegmentIndex(colourIm, 0.8, 200, 200);
% imsegs.nseg = max(imsegs.segimage(:));

% [colourHist, ~] = BlobStructColourHist(double(imsegs.segimage), colourIm);
% textureHist = BlobStructTextureHist(double(imsegs.segimage), colourIm);
% imsegs.colourHist = colourHist'; imsegs.textureHist = textureHist';

if ~isempty(I_pred)
    if alignment == 1
        pred_ali = false(size(I_pred)); % align foreground to fill the whole superpixel
    else
        pred_ali = I_pred;
    end
    if ~any(pred_ali(:)) % check if prior map is empty
        roi = bb_I;
    else
        % generate grids surrounding the candidate regions
        b = regionprops(pred_ali,'BoundingBox'); nc = length(b); roi = zeros(nc, 4);
        for i = 1 : nc, roi(i, :) = round(b(i).BoundingBox); end
        roi = bbApply( 'intersect', roi, repmat(bb_I, nc, 1));
        roi(roi(:, 3) == 0 | roi(:, 4) == 0, :) = [];
    end
else
    roi = bb_I;
end

nc = size(roi, 1);
pts = zeros(nc, 4); ngx = zeros(nc, 1); ngy = zeros(nc, 1);
for i = 1 : nc
    bb = roi(i, :); xbr = bb(1) + bb(3) - 1; ybr = bb(2) + bb(4) - 1;
    %     pt = patchSize - 1; pl = pt; s = [bb(4) + pt, bb(3) + pl];
    pl = patchSize - 1; pt = pl; s = [bb(3) + pl, bb(4) + pt];
    s1 = patchSize - s + (ceil(s / nStride) - 1) * nStride; % compute the optimal padding size (bottom and right)
    pts(i, :) = [bb(1) - pl, bb(2) - pt, xbr + s1(1), ybr + s1(2)]; % [xmin, ymin, xmax, ymax];
    ngx(i) = ceil((pts(i, 3) - pts(i, 1) + 2 - patchSize) / nStride);
    ngy(i) = ceil((pts(i, 4) - pts(i, 2) + 2 - patchSize) / nStride);
end
grids = zeros(sum(ngx .* ngy), 2); st = 1;
for i = 1 : nc
    [gx, gy] = meshgrid(pts(i, 1) : nStride : pts(i, 3)- patchSize + 1,...
        pts(i, 2) : nStride : pts(i, 4)- patchSize + 1);
    assert(ngx(i) == size(gx, 2)); assert(ngy(i) == size(gx, 1));
    n = length(gx(:)); ed = st + n - 1;
    grids(st : ed, 1) = gx(:); grids(st : ed, 2) = gy(:); st = ed + 1;
end
pts_ds = pts; hfbin = floor(patchSize / 8);
pts_ds(:, 1 : 2) = pts_ds(:, 1 : 2) + hfbin; % the actual top-left bin center


if 0 % test bounding boxes, align boxes, and grids
    [imh_p, imw_p, ~] = size(I_pred);
    tmp = uint8(my_Normalize(pred_ali, 0, 255)); im4show = uint8(zeros(imh_p, imw_p));
    im4show(:, :, 1) = tmp; im4show(:, :, 2) = tmp; im4show(:, :, 3) = tmp;
    im4show = bbApply( 'embed', im4show, bb_I, 'col',[255 255 255], 'lw', 1);
    for i = 1 : nc
        im4show = bbApply( 'embed', im4show, roi(i, :), 'col',[0 0 255], 'lw', 1);
        im4show = bbApply( 'embed', im4show, [pts(i, 1), pts(i, 2), ...
            pts(i, 3) - pts(i, 1) + 1, pts(i, 4) - pts(i, 2) + 1], 'col',[255 0 0], 'lw', 1);
        im4show = bbApply( 'embed', im4show, [pts_ds(i, 1), pts_ds(i, 2), ...
            pts_ds(i, 3) - pts_ds(i, 1) + 1, pts_ds(i, 4) - pts_ds(i, 2) + 1],...
            'col',[0 255 0], 'lw', 1);
    end
    imshow(im4show);
end
end
    

