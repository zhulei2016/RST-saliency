function [similarity indSim] = SSSimTexture(a, b, blobStruct)
% Calculate similarity for a single edge.
% a is blob a. 
% b is blob b. 
% blobStruct is the list of blobStruct

% Histogram intersection
similarity = sum(bsxfun(@min, blobStruct.textureHist(:,a), blobStruct.textureHist(:,b)));

indSim = similarity;