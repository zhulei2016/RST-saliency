function salopt = saliencyPropagation(im_d, imsegs, inimap,...
    alpha, gamma, sigma, mask, maskmap, imgplane)
%% get segments info
nseg = imsegs.nseg; adjcMatrix = imsegs.adjmat;
pixelList = imsegs.pixelList;

%% get features an annotated labels
fgWeight = zeros(nseg, 1); mskweight = zeros(nseg, 1);
for i = 1 : nseg
    fgWeight(i) = mean(inimap(imsegs.segimage == i));
    if ~isempty(maskmap)
        mskweight(i) = mean(maskmap(imsegs.segimage == i));
    end
end
fgWeight = my_Normalize(fgWeight, 0, 1);
mskweight = my_Normalize(mskweight, 0, 1);

% compute feature distance matrix
[h, w, c] = size(im_d);
im_lab = colorspace('Lab<-', im_d);
tmpImg=reshape(im_lab, h*w, c);
meanLabCol=zeros(nseg, c);
for i=1:nseg
    meanLabCol(i, :)=mean(tmpImg(pixelList{i},:), 1);
end

%% build adjacent graph
adjcMatrix_nn = (adjcMatrix * adjcMatrix + adjcMatrix) > 0;
% adjcMatrix_nn = adjcMatrix > 0;
adjcMatrix_nn = double(adjcMatrix_nn);
% adjcMatrix_nn(bdIds, bdIds) = 1;
DistM2 = zeros(nseg, nseg);
for n = 1:size(meanLabCol, 2)
    DistM2 = DistM2 + ( repmat(meanLabCol(:,n), [1, nseg]) -...
        repmat(meanLabCol(:,n)', [nseg, 1]) ).^2;
end
colDistM = sqrt(DistM2);
colDistM(adjcMatrix_nn == 0) = Inf;

% compute similarity matrix
if sigma > 0
    colDistM(colDistM > 3 * 10) = Inf;   %cut off > 3 * sigma distances
    Wn = exp(-colDistM.^2 ./ (2 * sigma * sigma));
else
    tmp = colDistM; tmp(colDistM == Inf) = 0;
    sigma_adpt = max(max(tmp)) / 3;
    %     Wn = exp(-colDistM.^2 ./ (2 * sigma_adpt * sigma_adpt));
    Wn = exp(-colDistM.^2 ./ (sigma_adpt * sigma_adpt));
end


mu = 0.1;                                                   %small coefficients for regularization term
W = Wn + adjcMatrix * mu;                                   %add regularization term

%% Manifold-based similarity adaptation (knn graph)
param.k = ceil(mean(sum(adjcMatrix - eye(nseg), 2)));
param.sigma = 'median'; % Kernel parameter heuristics 'median' or 'local-scaling'
param.max_iter = 100;
X = meanLabCol';

[W1, W0] = AEW(X,param);
if any(any(isnan(W1)))
    W1 = W0;
end

%% combination of two graphs
% for i = 1 : nseg, W(i, i) = 0;  W1(i, i) = 0; end
W = my_Normalize(W, 0, 1);
W1 = my_Normalize(W1, 0, 1);
W = (1 - alpha) * W + alpha * W1;
% W = W.* W1;
D = diag(sum(W));

%% Quadratic energymodels: Learning Optimal Seeds for Diffusion-Based Salient Object Detection
% solution: (K + lamda * L)^(-1) * (lamda * K) * s; L = D - W
% K = eye(nseg);    % identification case
K = D;              % D case
A = gamma * (K + gamma * (D - W));
if rcond(A) < 1e-10     % singluar judgement
    K = eye(nseg); A = gamma * (K + gamma * (D - W));
end
p2 = A \ K * fgWeight;
% subplot(1, 3, 1); imshow(superpixel2im(imsegs.segimage, p2));

%% manifold models: GraB : Visual Saliency via Novel Graph Model and Background Priors
% optimazie the foreground
% trY = zeros(nseg, 2);
% th = mean(mean(fgWeight));
% trY(:, 1) = fgWeight > th;   % foreground
% trY(:, 2) = fgWeight < th;   % background
% 
% bgLambda = 1;   %global weight for background term, bgLambda > 1 means we rely more on bg cue than fg cue.
% E_bg = diag(trY(:, 2) * bgLambda);       %background term
% E_fg = diag(trY(:, 1));          %foreground term
% 
% p2 =(D - W + E_bg + E_fg) \ (E_fg * ones(nseg, 1));
% p2 = my_Normalize(p2, 0, 1); subplot(1, 3, 2); imshow(superpixel2im(imsegs.segimage, p2));
% 
% % ranking use manifold
% p3 = (D - 0.99 * W)\ p2;
% p3 = my_Normalize(p3, 0, 1); subplot(1, 3, 3); imshow(superpixel2im(imsegs.segimage, p3));

%% get the enclosed superpixels
if ~isempty(mask)
    segimage = imsegs.segimage;
    segimage(~mask) = 0;
    validId = unique(segimage(:)); validId(validId == 0) = [];
    p3 = zeros(length(p2), 1); p3(validId) = p2(validId);
else
    p3 = p2;
end
p3 = my_Normalize(p3, 0, 1);

%% small trick, add mask to the saliency map
if ~isempty(maskmap)
    p3 = p3 + mskweight;
    p3 = my_Normalize(p3, 0, 1);
end

%% pixel-based refinement
if isempty(imgplane)    % only use lab color
    salopt = saliencyFilter(meanLabCol, imsegs, im_lab, p3);
else
    [h, w, c] = size(imgplane);
    tmpImg=reshape(imgplane, h*w, c);
    feat=zeros(nseg, c);
    for i=1:nseg
        feat(i, :)=mean(tmpImg(pixelList{i},:), 1);
    end
    salopt = saliencyFilter(feat, imsegs, imgplane, p3);
end

end


