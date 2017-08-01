function [textureHist blobSizes] = BlobStructTextureHist(blobIndIm, colourIm, tBin)

if ~exist('tBin', 'var')
    tBin = 10;
end

maxVal = 0.43; % semi arbitrary parameter denoting maximum value of gradient

% Get oriented gradients for each colour space
ogImT = cell(1, size(colourIm,3));
for i=1:size(colourIm,3)
    ogImT{i} = Image2OrientedGradients(colourIm(:,:,1), 0.8);
end

ogIm = cat(3, ogImT{:});

% ogImA = Image2OrientedGradients(colourIm(:,:,1), 0.8);
% ogImB = Image2OrientedGradients(colourIm(:,:,2), 0.8);
% ogImC = Image2OrientedGradients(colourIm(:,:,3), 0.8);
% ogIm = cat(3, ogImA, ogImB, ogImC);

% For-loop which transforms gradient values to bin indices
textureBinIds = zeros(size(ogIm));
for i=1:size(ogIm,3)
    textureBinIds(:,:,i) = round(ogIm(:,:,i) .* ((tBin-1) / maxVal) + 1 + (i-1) * tBin);
end

% Count bin indices
numBlobs = max(blobIndIm(:));
[textureHist blobSizes] = CountVisualWordsIndex(blobIndIm, textureBinIds, numBlobs, tBin * size(ogIm,3));
textureHist = NormalizeRows(textureHist);
blobSizes = blobSizes ./ size(textureBinIds,3);