function similarity = BlobSimBoW(a, b, image, simParams)

% Calculate textureHistogram intersection for similarity measure
% We abuused texture for Bag of Words histogram
bowSim = sum(min(a.textureHist, b.textureHist));

% We also want a size similarity
imSize = size(image,1) * size(image,2);
sizeSim = (imSize - a.size - b.size) / imSize;

similarity = simParams.weightBow * bowSim + ...
             simParams.weightSim * sizeSim;