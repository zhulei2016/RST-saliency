function [textureHist blobSizes] = BlobStructTextureHistBetterEdges(blobIndIm, colourIm, tBin)
% Create histogram
%
% Unlike evenly spaced bins, does evenly filled bins (on everage, each bin
% has the same number of members)


if ~exist('tBin', 'var')
    tBin = 10;
end

% Get oriented gradients for each colour space
ogImT = cell(1, size(colourIm,3));
for i=1:size(colourIm,3)
    ogImT{i} = Image2OrientedGradients(colourIm(:,:,1), 0.8);
end

ogIm = cat(3, ogImT{:});

% Get edges of the bins
ogImNrs = ogIm(:);
ogImNrs = ogImNrs(ogImNrs > 0);
ogImNrs = sort(ogImNrs);

% Take 95% as good bin value
maxEdgeVal = ogImNrs(round(length(ogImNrs) * .95));
minEdgeVal = min(ogImNrs);
binEdges = (minEdgeVal:(maxEdgeVal-minEdgeVal)/(tBin-2):maxEdgeVal)';

binEdges = cat(1, 0, binEdges, max(ogImNrs) + eps); % A bin for all the zeros and the last bin

% Do the histogram assignment.
[histogram textureBinIds] = histc(ogIm(:), binEdges);

% Special check. Remove later
if(max(textureBinIds) ~= tBin)
    keyboard;
end

% Make sure that different layers of the ogIm/textureBinIds fall in
% different bins in the overall histogram.
textureBinIds = reshape(textureBinIds, size(ogIm));
for i=2:size(textureBinIds,3)
    textureBinIds(:,:,i) = textureBinIds(:,:,i) + (i-1) * tBin;
end

% % For-loop which transforms gradient values to bin indices
% textureBinIds = zeros(size(ogIm));
% for i=1:size(ogIm,3)
%     textureBinIds(:,:,i) = round(ogIm(:,:,i) .* ((tBin-1) / maxVal) + 1 + (i-1) * tBin);
% end

% Count bin indices
numBlobs = max(blobIndIm(:));
[textureHist blobSizes] = CountVisualWordsIndex(blobIndIm, textureBinIds, numBlobs, tBin * size(ogIm,3));
textureHist = NormalizeRows((textureHist));
blobSizes = blobSizes ./ size(textureBinIds,3);