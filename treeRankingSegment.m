function sal_opt = treeRankingSegment(I_p, grids, slabel, sc, sr)
[imh_p, imw_p, ~] = size(I_p);
[~, blobIndIm, ~, hierarchy] = getHierarchicalsuperpixels(I_p);
% if 0, imshow(showGrid_DownSamplingImage(I_p, blobIndIm)); end

if isempty(hierarchy),
    sal_opt = zeros(imh_p, imw_p);
    return;
end

if ndims(slabel) == 4,
    [sc, sr, pixNum, treeNum] = size(slabel);
    slabel_d = double(reshape(slabel, [sc * sr, pixNum, treeNum]));
elseif ndims(slabel) == 3,
    [sz, pixNum, treeNum] = size(slabel); assert(sz == sc * sr);
    slabel_d = double(slabel);
end
cat = length(hierarchy); spNum = max(blobIndIm(:));

lblAvg = mean(slabel_d, 3); % compute the average label;
lossLA = abs(slabel_d - repmat(lblAvg, 1, 1, treeNum)); % loss of each predict to the averaged predicts
lossLA = squeeze(sum(lossLA, 1));

% get all the segmentations
sz_p = sr * sc; sz_img = imh_p * imw_p; sz_cb = spNum * cat;
ssmap = uint32(zeros(imh_p, imw_p, sz_cb)); % 2 * spNum - 1 - spNum + 1
for k = 1 : cat,
    hierk = hierarchy{k}; t =max(hierk(:)); segk = blobIndIm; sid = (k - 1) * spNum;
    ssmap(:, :, 1 + sid) = segk; idx = 2 + sid;
    for kk = spNum + 1 : t,
        spNo = find(hierk == kk); segk(segk == spNo(1)) = kk; segk(segk == spNo(2)) = kk;
        ssmap(:, :, idx) = segk; idx = idx + 1;
    end
end

gridX = grids(:, 1); gridY = grids(:, 2);
va = zeros(pixNum, treeNum);
[~, vari] = calcVariance(ssmap, gridX, gridY, [sr, sc]);
ssmap_id = reshape(ssmap, [sz_img, sz_cb]); alpha = 0.7;
ttt1 = 0; ttt2 = 0;
for s = 1 : pixNum,
    x_lo = gridX(s); x_hi = gridX(s) + sr - 1; y_lo = gridY(s); y_hi = gridY(s) + sc - 1;
    [xx, yy] = meshgrid( x_lo : x_hi, y_lo : y_hi); pixIdx = (xx - 1) * imh_p + yy;
    
    seginfo = zeros(cat, sz_p);
    for k = 1 : cat,
        ind2 = (k - 1) * spNum; sid = 1 + ind2; eid = ind2 + spNum;
        s1 = ssmap_id(pixIdx(:), sid : eid);
        [~, id1, ~] = unique(vari(s, sid : eid)); c = length(id1); % used to speed up
        if c == 1, seginfo = []; break; % test if initially flat region
        else
            for h = 2 : c, % h == 1 must be flat region
                [~, ~, s2] = unique(s1(:, id1(h)), 'stable'); sm = max(s2);
                if sm == 2, seginfo(k, :) = s2'; break; end
            end
            if ~any(seginfo(k, :)), % hardly happen, have to recompute
                for h = 1 : spNum,
                    if vari(s, h + ind2) ~= 0,
                        [~, ~, s2] = unique(s1(:, h),'stable'); sm = max(s2);
                        if sm == 2, seginfo(k, :) = s2'; break; end
                    end
                end
            end
        end
    end
    
    lbl = slabel_d(:, s, :); lbl = squeeze(lbl); lbl_t = lblAvg(:, s);
    
    l1 = sum(lbl_t); l0 = sz_p - l1; [lossAF, f] = min([l1, l0]); % loss of average label to the flat region
    l1 = sum(lbl, 1); l0 = sz_p - l1; lossLF = [l1;l0]; lossAB = 256;
    
    if ~isempty(seginfo),
        seginfo = unique(seginfo, 'rows');
        %         l1 = sum(lbl_t); l0 = 256 - l1; lossAS1 = min(l0, l1); % loss of average label to the flat region
        candiSegNum = size(seginfo, 1);
        la = zeros(2, candiSegNum);
        for h = 1 : candiSegNum,    % loss of average label to the binary region
            lbl_t2 = abs(lbl_t - 1);
            la(1, h) = sum(lbl_t2(seginfo(h, :) == 1)) + sum(lbl_t(seginfo(h, :) == 2));
            la(2, h) = sum(lbl_t(seginfo(h, :) == 1)) + sum(lbl_t2(seginfo(h, :) == 2));
        end
        [lossAB, m] = min(la(:)); [m1, m2] = ind2sub([2, candiSegNum], m); % choose the optimal one from all binary regions
        %             m2 = floor(m / 2); m1 = rem(m - 1, 2);
        if lossAF > lossAB
            lbl2 = abs(lbl - 1);
            if m1 == 1, % change pixel labeled 1 in seginfo to 1
                lossLB = sum(lbl2(seginfo(m2, :) == 1, :), 1) + sum(lbl(seginfo(m2, :) == 2, :), 1);
            else % change pixel labeled 1 in seginfo to 0
                lossLB = sum(lbl(seginfo(m2, :) == 1, :), 1) + sum(lbl2(seginfo(m2, :) == 2, :), 1);
            end
        end
    end
    
    [~, lc] = min([lossAF, lossAB]);
    if lc == 1,
        va(s, :) = (1 - alpha) * lossLA(s, :) + alpha * lossLF(f, :);
        ttt1 = ttt1 + 1;
    else
        va(s, :) = (1 - alpha) * lossLA(s, :) + alpha * lossLB;
        ttt2 = ttt2 + 1;
    end
end

sigma = var(va, 0, 2); va1 = va.* va;
wt = exp(-va1 ./ repmat(sigma + eps, 1, treeNum));
% wt = wt ./ repmat(max(wt,[], 2) + eps, 1, size(wt, 2));
wt = wt ./ repmat(sum(wt, 2) + eps, 1, size(wt, 2));
assert(isempty(find(isnan(wt), 1)))

para.imh = imh_p; para.imw = imw_p; para.sz_r = sr; para.sz_c = sc;
grids = uint32([gridX, gridY]);
if ndims(slabel) == 4,
    [sal_opt,ht] = segsMergingMex_wt(slabel, wt, grids - 1, para);
elseif ndims(slabel) == 3,
    [sal_opt,ht] = segsMergingMex1d_wt(slabel, wt, grids - 1, para);
end
sal_opt = double(sal_opt) ./ (double(ht) + eps);
end

