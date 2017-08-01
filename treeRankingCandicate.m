function sal_opt = treeRankingCandicate(I_fcn, grids, slabel, sc, sr, ssprank)

[imh_p, imw_p, ~] = size(I_fcn);
if ndims(slabel) == 4
    [sc, sr, pixNum, treeNum] = size(slabel);
    slabel_d = double(reshape(slabel, [sc * sr, pixNum, treeNum]));
elseif ndims(slabel) == 3
    [sz, pixNum, treeNum] = size(slabel); assert(sz == sc * sr);
    slabel_d = double(slabel);
end

if ssprank.alpha < 1
    lblAvg = mean(slabel_d, 3); % compute the average label;
    lossLA = abs(slabel_d - repmat(lblAvg, 1, 1, treeNum));
    lossLA = squeeze(sum(lossLA, 1));
else
    lossLA = zeros(pixNum, treeNum);
end

% normalize to [0, 1]
if ssprank.isnorm
    minV = min(lossLA, [], 2); maxV = max(lossLA, [], 2);
    tmp1 = lossLA - repmat(minV, 1, treeNum);
    tmp2 = (maxV - minV) + eps;
    lossLA = tmp1 ./ repmat(tmp2, 1, treeNum);
end

% refine the segs by fcn result
gridX = grids(:, 1); gridY = grids(:, 2);
va = zeros(pixNum, treeNum);

for s = 1 : pixNum
    x_lo = gridX(s); x_hi = gridX(s) + sr - 1;
    y_lo = gridY(s); y_hi = gridY(s) + sc - 1;
    [xx, yy] = meshgrid( x_lo : x_hi, y_lo : y_hi); pixIdx = (xx - 1) * imh_p + yy;
    lbl_fcn = I_fcn(pixIdx(:));
    
    lbl = slabel_d(:, s, :); lbl = squeeze(lbl); 
    lossLF = abs(lbl - repmat(lbl_fcn, 1, treeNum));
    
    tmp = sum(lossLF, 1); 
    %     minV = min(tmp); maxV = max(tmp); tmp = (tmp - minV) ./ (maxV - minV + eps);
    va(s, :) = (1 - ssprank.alpha) * lossLA(s, :) + ssprank.alpha * tmp;
end

sigma = ssprank.k * var(va, 0, 2); va1 = va.* va; 
wt = exp(-va1 ./ repmat(sigma + eps, 1, treeNum));
% wt = wt ./ repmat(max(wt,[], 2) + eps, 1, size(wt, 2));
wt = wt ./ repmat(sum(wt, 2) + eps, 1, size(wt, 2));
assert(isempty(find(isnan(wt), 1)))

para.imh = imh_p; para.imw = imw_p; para.sz_r = sr; para.sz_c = sc; 
grids = uint32([gridX, gridY]);
if ndims(slabel) == 4
    [sal_opt,ht] = segsMergingMex_wt(slabel, wt, grids - 1, para);
elseif ndims(slabel) == 3
    [sal_opt,ht] = segsMergingMex1d_wt(slabel, wt, grids - 1, para);
end
sal_opt = double(sal_opt) ./ (double(ht) + eps);
end

