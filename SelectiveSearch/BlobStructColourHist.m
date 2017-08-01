function [colourHist blobSizes] = BlobStructColourHist(blobIndIm, colourIm, cBin)
% function [colourHist blobSizes] = BlobStructColourHist(blobIndIm, colourIm, cBin)
%
% Creates colour histograms for the segments in blobIndIm
%
% blobIndIm:            Image with indexes denoting the segments 1...N
% colourIm:             The (colour) image in range [0,1]
% cBin (default 25):    Number of bins per colour channel
%
% colourHist:           N x M matrix with row for each segment in blobIndIm
% blobSizes:            Number of elements per segment in blobIndIm

if ~exist('cBin', 'var')
    cBin = 25;
end

% For-loop which transforms colour values to bin indices
colourBinIds = zeros(size(colourIm));
for i=1:size(colourIm,3)
    colourBinIds(:,:,i) = round(colourIm(:,:,i) .* (cBin-1) + 1 + (i-1) * cBin);
end

% Count bin indices
numBlobs = max(blobIndIm(:));
[colourHist blobSizes] = CountVisualWordsIndex(blobIndIm, colourBinIds, numBlobs, cBin * size(colourIm,3));
colourHist = NormalizeRows(colourHist);
blobSizes = blobSizes ./ size(colourBinIds,3);