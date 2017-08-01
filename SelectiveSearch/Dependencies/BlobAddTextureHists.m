function blobs = BlobAddTextureHists(blobs, textureSpace, numBins, min, max)
% blobs = BlobAddWHists(blobs, textureSpace, numBins, min, max) 
% adds textureHist fields to each blob
%
% blobs is a struct with blobs
% textureSpace is the image representation in texture.
%   It is common to have an invariant textureSpace such as W-space.
% numBins is the number of bins.
% min is the lowest value of the histogram range.
% max is the highest value of the histogram range.

for i = 1:size(blobs,1)
    v = Blob2Vector(blobs{i}, textureSpace);
    hist = Vector2Hist(v, numBins, min, max);
    blobs{i}.textureHist = reshape(hist, 1, []) / size(hist, 1);
end

