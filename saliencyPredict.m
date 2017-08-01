function [slabel, sal] = saliencyPredict(feat, grids, model, para)

sal = zeros(para.imh, para.imw); hitTime = zeros(para.imh, para.imw);
if size(feat, 1) > para.split, % split the grids array for out of the memory problem
    re = n; st = 1; ed = para.split;
    while(re > 0)
        gs = uint32(grids(st : ed, :));
        if para.use2d == 1,
            if para.en_sal == 1,
                [~, sub_segs, sub_salmap,sub_hitTime] = ...
                    binaryStructPredictMex(model, feat(st : ed, :), gs - 1, para);
                sal = sal + double(sub_salmap); hitTime = hitTime + double(sub_hitTime);
            else
                [~, sub_segs] = binaryStructPredictMex(model, feat(st : ed, :), gs - 1, para);
            end
        else
            if para.en_sal == 1,
                [~, sub_segs, sub_salmap,sub_hitTime] = ...
                    binaryStructPredictMex1d(model, feat(st : ed, :), gs - 1, para);
                sal = sal + double(sub_salmap); hitTime = hitTime + double(sub_hitTime);
            else
                [~, sub_segs] = binaryStructPredictMex1d(model, feat(st : ed, :), gs - 1, para);
            end
        end
        slabel(:, :, st : ed, :) = sub_segs; st = ed + 1; re = n - ed;
        if re <= descPara.split, ed = st + re - 1;
        else ed = st + descPara.split - 1; end
    end
    if para.en_sal == 1, sal = sal ./ (hitTime + eps); end
else
    if para.use2d == 1,
        if para.en_sal == 1,
            [~, slabel, sal, hitTime] = binaryStructPredictMex(model, feat, uint32(grids) - 1, para);
            sal = double(sal) ./ (double(hitTime) + eps);
        else
            [~, slabel] = binaryStructPredictMex(model, feat, grids - 1, para);
        end
    else
        if para.en_sal == 1,
            [~, slabel, sal, hitTime] = binaryStructPredictMex1d(model, feat, uint32(grids) - 1, para);
            sal = double(sal) ./ (double(hitTime) + eps);
        else
            [~, slabel] = binaryStructPredictMex1d(model, feat, grids - 1, para);
        end
    end
end
end

